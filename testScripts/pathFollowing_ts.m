 clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 300*sqrt(lengthScaleFactor);
dynamicCalc = '';
SPOOLINGCONTROLLER = 'nonTrad';
PATHGEOMETRY = 'lemOfBooth';
controlAllocationBit = 0;
%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High Level Con
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches 
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('pathFollowingEnv');

%% Choose Path Shape and Set basis parameters for high level controller
fltCtrl.setFcnName('lemOfBooth','');
% fltCtrl.setFcnName('circleOnSphere','');
% fltCtrl.setFcnName('lemOfGerono','');

% hiLvlCtrl.basisParams.setValue([60 10 0 30 150],'') % Lemniscate of Gerono
  hiLvlCtrl.basisParams.setValue([.73,.8,.36,0,125],'');% Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([1,1.4,.36,0,125],'');% Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([pi/8,-3*pi/8,0,125],''); % Circle

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .4,... % Initial path position
    fltCtrl.fcnName.Value,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    6) % Initial speed
vhcl.setAddedMISwitch(false,'');
%% Environment IC's and dependant properties
% Set Values
flowspeed = .5; %m/s options are .1, .5, 1, 1.5, and 2 ************************************************************************************************************Right Here*************************************************88
env.water.velVec.setValue([flowspeed 0 0],'m/s');

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%gndStn.thrAttch1.velVec.setValue([0 0 0]','m/s');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.density.setValue(1300,'kg/m^3');
%% winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);

%% Controller User Def. Parameters and dependant properties



fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
fltCtrl.setSearchSize(.5,'');
fltCtrl.setMinR(100,'m')
fltCtrl.setMaxR(200,'m')

fltCtrl.setStartControl(1,'s')

allMat = zeros(4,3);
allMat(1,1)=-1/(2*vhcl.portWing.GainCL.Value(2)*...
   vhcl.portWing.refArea.Value*abs(vhcl.portWing.aeroCentPosVec.Value(2)));
allMat(2,1)=-1*allMat(1,1);
allMat(3,2)=-1/(vhcl.hStab.GainCL.Value(2)*...
   vhcl.hStab.refArea.Value*abs(vhcl.hStab.aeroCentPosVec.Value(1)));
allMat(4,3)= 1/(vhcl.vStab.GainCL.Value(2)*...
   vhcl.vStab.refArea.Value*abs(vhcl.vStab.aeroCentPosVec.Value(1))); 
%fltCtrl.ctrlAllocMat.setValue(allMat,'(deg)/(m^3)');

% fltCtrl.outRanges.setValue([ 0.49   1.0000;
%     2.0000    2.0000],''); %circle
fltCtrl.outRanges.setValue( [0    0.1250;
                        0.3750    0.6250;
                   0.8750    1.0000;],'');

fltCtrl.ctrlAllocMat.setValue([-1.1584         0         0;
                                1.1584         0         0;
                                0             -2.0981    0;
                                0              0         4.8067],'(deg)/(m^3)');
fltCtrl.winchSpeedIn.setValue(-flowspeed/3,'m/s')
fltCtrl.winchSpeedOut.setValue(flowspeed/3,'m/s')

fltCtrl.tanRoll.kp.setValue(fltCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
fltCtrl.tanRoll.kd.setValue(1.5*fltCtrl.tanRoll.kp.Value,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(.01,'s');

% fltCtrl.perpErrorVal.setValue(10*pi/180,'rad');
% 
% % fltCtrl.rollMoment.kp.setValue(5e5,'(N*m)/(rad)');
% % fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
% fltCtrl.rollMoment.tau.setValue (.8,'s');

fltCtrl.traditionalBool.setValue(0,'')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
 fltCtrl.elevatorReelInDef.setValue(25,'deg')

fltCtrl.yawMoment.kp.setValue(0*5e5,'(N*m)/(rad)')%************************************************I made this zero. JR********************************
%% gain tuning based on flow speed 
switch norm(env.water.velVec.Value)
    case 0.1
       fltCtrl.perpErrorVal.setValue(3*pi*180,'rad');
        fltCtrl.rollMoment.kp.setValue(1e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.kd.setValue(.2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    case 0.5
        fltCtrl.perpErrorVal.setValue(7*pi/180,'rad');
        fltCtrl.rollMoment.kp.setValue(2e3,'(N*m)/(rad)');
        fltCtrl.rollMoment.kd.setValue(.5*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
         fltCtrl.rollMoment.tau.setValue (.01,'s');
    case 1  
    %    fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
    %    fltCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)');
    %    fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
        fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
        fltCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
        fltCtrl.tanRoll.tau.setValue(.8,'s');
        fltCtrl.rollMoment.tau.setValue (.8,'s');
        fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
        fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
    case 1.5
    %     fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
    %     fltCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
    %     fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    %     fltCtrl.tanRoll.tau.setValue(.01,'s');
    %     fltCtrl.rollMoment.tau.setValue (.01,'s');
        fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
        fltCtrl.rollMoment.kp.setValue(5.9e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.kd.setValue(4.5*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
        fltCtrl.tanRoll.tau.setValue(.8,'s');
        fltCtrl.rollMoment.tau.setValue (.8,'s');
    case 2
        fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');   
        fltCtrl.rollMoment.kp.setValue(5.9e5,'(N*m)/(rad)');
        fltCtrl.rollMoment.kd.setValue(4.5*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
    otherwise
            error('Controller tuning for that flow speed is not implemented')
end

%% Scale
% scale environment
env.scale(lengthScaleFactor,densityScaleFactor);
% scale vehicle
vhcl.scale(lengthScaleFactor,densityScaleFactor);
vhcl.calcFluidDynamicCoefffs;
% scale ground station
gndStn.scale(lengthScaleFactor,densityScaleFactor);
% scale tethers
thr.scale(lengthScaleFactor,densityScaleFactor);
% scale winches
wnch.scale(lengthScaleFactor,densityScaleFactor);
% scale controller
fltCtrl.scale(lengthScaleFactor,densityScaleFactor);

%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;
%kiteAxesPlot
%stopCallback
%% plots

% figure
%  timevec=tsc.velocityVec.Time;
%  ten=squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1)));
% plot(tsc.winchSpeeds.Time,tsc.winchSpeeds.Data.*ten)
% xlabel('time (s)')
% ylabel('Power (Watts)')
%  [~,i1]=min(abs(timevec - 0));
%  [~,i2]=min(abs(timevec -100)); %(timevec(end)/2)));
%  [~,poweri1]=min(tsc.winchSpeeds.Data(i1:i2).*ten(i1:i2));
% poweri1 = poweri1 + i1;
% [~,i3]=min(abs(timevec - (timevec(end)/2)));
% [~,i4]=min(abs(timevec - timevec(end)));
% i4=i4-1;
% [~,poweri2]=min(tsc.winchSpeeds.Data(i3:i4).*ten(i3:i4));
% poweri2 = poweri2 + i3;
% % Manual Override. Rerun with this to choose times
% %            t1 = input("time for first measurement");
% %             [~,poweri1]=min(abs(timevec - t1));
% %              t2 = input("time for second measurement");
% %              [~,poweri2]=min(abs(timevec - t2));
% hold on
% ylims=ylim;
% plot([timevec(poweri1) timevec(poweri1)], [-1e6 1e6],'r--')
% plot([timevec(poweri2) timevec(poweri2)], [-1e6 1e6],'r--')
% ylim(ylims);
%  meanPower = mean(tsc.winchSpeeds.Data(poweri1:poweri2).*ten(poweri1:poweri2));
% title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',meanPower));
% saveas(gcf,'power.png')
% savefig('pow.fig')
% 
% plotVelocity
% saveas(gcf,'velocity.png')
% savefig('vel.fig')
% plotTenVecMags
% saveas(gcf,'tension.png')
%  kiteAxesPlot


%tsc.FLiftBdy.plot


% figure (3)
%   lifta=tsc.FLiftBdy.Data(:,:,:);
%    liftaMag = sqrt(sum((lifta).^2,1));
%   draga=tsc.FDragBdy.Data(:,:,:);
%    dragaMag = sqrt(sum((draga).^2,1));
%    lVd = liftaMag./dragaMag;
%     plot(tsc.velocityVec.Time, squeeze(lVd));
%     
%     xlabel('time (s)')
%     ylabel('FLift/FDrag')
%     hold on
%     
%  figure (4)
%     plot(tsc.velocityVec.Time,squeeze(tsc.FFluidBdy.data(1,:,:)))
%     
%     xlabel('time (s)')
%     ylabel('FfluidX (N)')
%         
%     %thrust = liftaMag.*sin(squeeze((pi/180).*tsc.alphaLocal.Data(:,1,:)))-dragaMag.*cos(squeeze((pi/180).*tsc.alphaLocal.Data(:,1,:)))