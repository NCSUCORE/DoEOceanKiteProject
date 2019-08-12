clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 500*sqrt(lengthScaleFactor);
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High Level Con
loadComponent('testConstBasisParams')
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

vhcl.setICsOnPath(...
    0.25,...
    fltCtrl.fcnName.Value,...
    hiLvlCtrl.basisParams.Value,...
    6)

% %% Vehicle IC's and dependant properties
% tetherLength = hiLvlCtrl.basisParams.Value(5);
% initVelMag = 6;
% onpath = true;
% 
% 
% if onpath
%     pathParamStart = 0;
%     pathParamVec = hiLvlCtrl.basisParams.Value;
%     [ini_Rcm,iniucm]=lemOfBooth(pathParamStart,pathParamVec);
%     iniVcm=initVelMag*iniucm;
%     [long,lat,~]=cart2sph(ini_Rcm(1),ini_Rcm(2),ini_Rcm(3));
%     tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
%                -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
%                cos(lat)            0          -sin(lat);];
% else
%     long = -1.9*pi/8;
%     lat = -pi/4;
%     initVelAng = 90;%degrees
%     
%     tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
%                -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
%                cos(lat)            0          -sin(lat);];
%     ini_Rcm = tetherLength*[cos(long).*cos(lat);
%                             sin(long).*cos(lat);
%                             sin(lat);];
%     iniVcm = initVelMag*tanToGr*[cosd(initVelAng);sind(initVelAng);0];
% end
% 
% ini_pitch = atan2(iniVcm(3),sqrt(iniVcm(1)^2+iniVcm(2)^2));
% ini_yaw   = atan2(-iniVcm(2),-iniVcm(1));
% 
% [bodyToGr,~]=rotation_sequence([0 ini_pitch ini_yaw]);
% bodyY_before_roll=bodyToGr*[0 1 0]';
% tanZ=tanToGr*[0 0 1]';
% 
% 
% ini_roll=((pi/2)+acos(dot(bodyY_before_roll,tanZ)/(norm(bodyY_before_roll)*norm(tanZ))));
% 
% 
% [ini_roll ini_pitch ini_yaw]*180/pi
% vhcl.initEulAng.Value*180/pi
% 
% iniVcm 
% vhcl.initVelVecGnd.Value

vhcl.plot('EulerAngles',vhcl.initEulAng.Value,'Position',vhcl.initPosVecGnd.Value)
hold on
pathPos = lemOfBooth(linspace(0,1),hiLvlCtrl.basisParams.Value);
plot3(pathPos(1,:),pathPos(2,:),pathPos(3,:))
quiver3(...
    vhcl.initPosVecGnd.Value(1),...
    vhcl.initPosVecGnd.Value(2),...
    vhcl.initPosVecGnd.Value(3),...
    vhcl.initVelVecGnd.Value(1),...
    vhcl.initVelVecGnd.Value(2),...
    vhcl.initVelVecGnd.Value(3));


ini_Vcm_body = [-initVelMag;0;0];
ini_eul=[ini_roll ini_pitch ini_yaw];

% % % initial conditions
vhcl.setInitPosVecGnd(ini_Rcm,'m');
vhcl.setInitVelVecGnd(ini_Vcm_body,'m/s');
vhcl.setInitEulAng(ini_eul,'rad');
vhcl.setInitAngVelVec([0;0;0],'rad/s');

% % % plot
% vhcl.plot
% vhcl.plotCoeffPolars

%% Environment IC's and dependant properties
% Set Values
flowspeed = 1.5; %m/s options are .1, .5, 1, 1.5, and 2
env.water.velVec.setValue([flowspeed 0 0],'m/s');

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%gndStn.thrAttch1.velVec.setValue([0 0 0]','m/s');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);

%% Controller User Def. Parameters and dependant properties
allMat = zeros(4,3);
allMat(1,1)=-1/(2*vhcl.portWing.GainCL.Value(2)*...
   vhcl.portWing.refArea.Value*abs(vhcl.portWing.aeroCentPosVec.Value(2)));
allMat(2,1)=-1*allMat(1,1);
allMat(3,2)=-1/(vhcl.hStab.GainCL.Value(2)*...
   vhcl.hStab.refArea.Value*abs(vhcl.hStab.aeroCentPosVec.Value(1)));
allMat(4,3)= 1/(vhcl.vStab.GainCL.Value(2)*...
   vhcl.vStab.refArea.Value*abs(vhcl.vStab.aeroCentPosVec.Value(1))); 
%pathCtrl.ctrlAllocMat.setValue(allMat,'(deg)/(m^3)');

fltCtrl.pathParams.setValue(pathParamVec,''); %Unscalable
% fltCtrl.outRanges.setValue([ 0.49   1.0000;
%     2.0000    2.0000],''); %circle
   
%fltCtrl.outRanges.setValue([0 .125;...
%                             .375 .625;...
%                             .875 1],''); %fig 8
fltCtrl.outRanges.setValue( [0    0.1250;
                        0.3450    0.6250;
                   0.8500    1.0000;],'');

fltCtrl.ctrlAllocMat.setValue([-1.1584         0         0;
                                1.1584         0         0;
                                0             -2.0981    0;
                                0              0         4.8067],'(deg)/(m^3)');
fltCtrl.winchSpeedIn.setValue(-flowspeed/3,'m/s')
fltCtrl.winchSpeedOut.setValue(flowspeed/3,'m/s')

fltCtrl.traditionalBool.setValue(0,'')
fltCtrl.pathParams.setValue(pathParamVec,''); %Unscalable
%% gain tuning based on flow speed 
switch norm(env.water.velVec.Value)
case 0.1
    fltCtrl.perpErrorVal.setValue(7*pi/180,'rad');
    fltCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
    fltCtrl.rollMoment.kd.setValue(.2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
case 0.5
    fltCtrl.perpErrorVal.setValue(4*pi/180,'rad');
    fltCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
    fltCtrl.rollMoment.kd.setValue(.6*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
case 1  
%     fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
%     fltCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)');
%     fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
     fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
     fltCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)');
     fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
     fltCtrl.velAng.tau.setValue(.8,'s');
    fltCtrl.rollMoment.tau.setValue (.8,'s');
    fltCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
fltCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');
case 1.5
%     fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
%     fltCtrl.rollMoment.kp.setValue(4e5,'(N*m)/(rad)');
%     fltCtrl.rollMoment.kd.setValue(2*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
%     fltCtrl.velAng.tau.setValue(.01,'s');
%     fltCtrl.rollMoment.tau.setValue (.01,'s');
    fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');
    fltCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)');
    fltCtrl.rollMoment.kd.setValue(150000,'(N*m)/(rad/s)');
    fltCtrl.velAng.tau.setValue(.01,'s');
    fltCtrl.rollMoment.tau.setValue (.01,'s');
case 2
    fltCtrl.perpErrorVal.setValue(3*pi/180,'rad');   
    fltCtrl.rollMoment.kp.setValue(5.9e5,'(N*m)/(rad)');
    fltCtrl.rollMoment.kd.setValue(4.5*fltCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
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
% fltCtrl.scale(lengthScaleFactor)

%% Run the simulation
traditionalBool = 0;
simWithMonitor('OCTModel')
parseLogsout;
%stopCallback
%% plots

figure
 timevec=tsc.velocityVec.Time;
 ten=squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1)));
plot(tsc.thrReleaseSpeeds.Time,tsc.thrReleaseSpeeds.Data.*ten)
xlabel('time (s)')
ylabel('Power (Watts)')
 [~,i1]=min(abs(timevec - 0));
 [~,i2]=min(abs(timevec -100)); %(timevec(end)/2)));
 [~,poweri1]=min(tsc.thrReleaseSpeeds.Data(i1:i2).*ten(i1:i2));
poweri1 = poweri1 + i1;
[~,i3]=min(abs(timevec - (timevec(end)/2)));
[~,i4]=min(abs(timevec - timevec(end)));
i4=i4-1;
[~,poweri2]=min(tsc.thrReleaseSpeeds.Data(i3:i4).*ten(i3:i4));
poweri2 = poweri2 + i3;
% Manual Override. Rerun with this to choose times
%            t1 = input("time for first measurement");
%             [~,poweri1]=min(abs(timevec - t1));
%              t2 = input("time for second measurement");
%              [~,poweri2]=min(abs(timevec - t2));
hold on
ylims=ylim;
plot([timevec(poweri1) timevec(poweri1)], [-1e6 1e6],'r--')
plot([timevec(poweri2) timevec(poweri2)], [-1e6 1e6],'r--')
ylim(ylims);
 meanPower = mean(tsc.thrReleaseSpeeds.Data(poweri1:poweri2).*ten(poweri1:poweri2));
title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',meanPower));
saveas(gcf,'power.png')
savefig('pow.fig')

plotVelocity
saveas(gcf,'velocity.png')
savefig('vel.fig')
plotTenVecMags
saveas(gcf,'tension.png')
kiteAxesPlot