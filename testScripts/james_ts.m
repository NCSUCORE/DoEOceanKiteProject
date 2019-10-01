clear

if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 20000*sqrt(lengthScaleFactor);

dynamicCalc = '';
 SPOOLINGCONTROLLER = 'intraSpoolingController';
% ZERO FOR MITCHELLS CONTROL ALLOCATION, ONE OLD CONTROL ALLOCATION MATRIX
controlAllocationBit = 0;

%% PLOT BITS
DAMPlot = false; % desired and achieved moments
CSDPlot = false; % control surface deflections
YMCTPlot = false; % yaw moment controller things
TRTPlot = false; % tangent roll things
%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High Level Con
loadComponent('constBoothLem')

%PATHGEOMETRY = 'ellipse';
PATHGEOMETRY = 'lemOfBooth';
% Ground station
loadComponent('pathFollowingGndStn');
% Winches 
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
%loadComponent('constXYZ_TvarSineWave');
%loadComponent('constXYZT');
loadComponent('constXY_ZTvarADCP');
%% Choose Path Shape and Set basis parameters for high level controller
%fltCtrl.setFcnName('ellipse','');
% fltCtrl.setFcnName('circleOnSphere','');
fltCtrl.setFcnName('lemOfBooth','');

% hiLvlCtrl.basisParams.setValue([60 10 0 30 150],'') % Lemniscate of Gerono
 % hiLvlCtrl.basisParams.setValue([1.1,.5,.4,0,200],'');% ellipse
  hiLvlCtrl.basisParams.setValue([1,1.4,.36,0.45,125,0.25,0.125],'')
 %hiLvlCtrl.basisParams.setValue([.73,1,.36,0,50],'');% Lemniscate of Booth
 %hiLvlCtrl.basisParams.setValue([pi/8,-3*pi/8,0,125],''); % Circle
%% Environment IC's and dependant properties
% Set Values
 flowspeed = 1.5;
 
 %env.water.flowVec.setValue([1.5,0,0],'m/s')

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .4,... % Initial path position
    fltCtrl.fcnName.Value,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    (11.5/2)*flowspeed) % Initial speed
vhcl.setAddedMISwitch(false,''); %true to have added mass on

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
thr.tether1.density.setValue(1000,'kg/m^3');
%% winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);
%% ALL Controller Properties
%General
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
fltCtrl.setStartControl(0,'s')

%Level 1, Velocity Angle Selection
    fltCtrl.setSearchSize(.5,'');
    fltCtrl.perpErrorVal.setValue(3*pi/180,'rad')

%Level 2, Tangent Roll Selection
    fltCtrl.maxBank.upperLimit.setValue(45*pi/180,'');
    fltCtrl.maxBank.lowerLimit.setValue(-45*pi/180,'');


fltCtrl.tanRoll.kp.setValue(.2,'(rad)/(rad)');
% fltCtrl.tanRoll.kp.setValue(0,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(.01,'s');

%Level 3 Moment Selection


fltCtrl.rollMoment.kp.setValue((1e4)/(10*pi/180),'(N*m)/(rad)')
% fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((2e4)/(10*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(.001,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');
% fltCtrl.yawMoment.ki.setValue(0,'(N*m)/(rad*s)');
% fltCtrl.yawMoment.kd.setValue(0,'(N*m)/(rad/s)');
% fltCtrl.yawMoment.tau.setValue(0.001,'s');

%Control Allocation
    allMat = zeros(4,3);
    allMat(1,1)=-1/(2*vhcl.portWing.GainCL.Value(2)*...
       vhcl.portWing.refArea.Value*abs(vhcl.portWing.aeroCentPosVec.Value(2)));
    allMat(2,1)=-1*allMat(1,1);
    allMat(3,2)=-1/(vhcl.hStab.GainCL.Value(2)*...
       vhcl.hStab.refArea.Value*abs(vhcl.hStab.aeroCentPosVec.Value(1)));
    allMat(4,3)= 1/(vhcl.vStab.GainCL.Value(2)*...
       vhcl.vStab.refArea.Value*abs(vhcl.vStab.aeroCentPosVec.Value(1)));
    % allMat = [-1.1584         0         0;
    %           1.1584         0         0;
    %           0             -2.0981    0;
    %           0              0         4.8067]; 
    fltCtrl.ctrlAllocMat.setValue(allMat,'(deg)/(m^3)');
    
    fltCtrl.controlSigMax.upperLimit.setValue(20,'')
    fltCtrl.controlSigMax.lowerLimit.setValue(-20,'')

%Winch Controller
    fltCtrl.traditionalBool.setValue(0,'')

    fltCtrl.winchSpeedIn.setValue(-flowspeed/3,'m/s')
    fltCtrl.winchSpeedOut.setValue(flowspeed/3,'m/s')

    fltCtrl.elevatorReelInDef.setValue(20,'deg')

    fltCtrl.setMinR(100,'m')
    fltCtrl.setMaxR(200,'m')

%      fltCtrl.outRanges.setValue([0.49   1.0000;
%                                  2.0000    2.0000],''); %circle
    fltCtrl.outRanges.setValue( [0         0.1250;%%%%%%%%%%%%%%lemOfBoot
                                 0.3450    0.6250;
                                 0.8500    1.0000;],'');
% 
%      fltCtrl.outRanges.setValue( [0.15    0.4;
%                                   0.6    .85;],'');
%% Scale
% scale environment
%env.scale(lengthScaleFactor,densityScaleFactor);
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
% kiteAxesPlot
%stopCallback
%% Desired And Achieved Moments
if DAMPlot
figure
subplot(3,1,1)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(1,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
title('Desired and Achieved Moments')
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,1),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Roll Moment [Nm]')
legend
subplot(3,1,2)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(2,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,2),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');xlabel('Time, [s]')
ylabel('Pitch Moment [Nm]')
legend
subplot(3,1,3)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(3,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,3),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Yaw Moment [Nm]')
legend

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)

end 
%% Control Surf Def
if CSDPlot
plotControlSurfaceDeflections
end
%% Plot yaw moment controller things
if YMCTPlot
figure
subplot(3,1,1)
tsc.betaRad.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual')
grid on
hold on
tsc.betaSP.plot('LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Setpoint')
xlabel('Time, t [s]')
ylabel('$\beta$,[rad]')
legend
title('Yaw controller breakdown')

subplot(3,1,2)
plot(tsc.ctrlSurfDeflection.Time,...
    squeeze(tsc.ctrlSurfDeflection.Data(4,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k')
grid on
xlabel('Time, t [s]')
ylabel({'Rudder Defl [deg]'})

subplot(3,1,3)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(3,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,3),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, t [s]')
ylabel('Moment, [N*m]')
legend

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)
end
%% Plot tangent roll tracking
if TRTPlot
figure
tsc.tanRoll.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual Tan Roll');
grid on
hold on
tsc.tanRollDes.plot('LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired Tan Roll');
legend
end
vhcl.animateSim(tsc,3,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',true,...
    'NavigationVecs',true,...
    'Pause',false)


hold off

% %% central angle
% figure
% tsc.central_angle.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
%     'DisplayName','Central Angle');
% grid on
% title('Central Angle vs. Time')
% ylabel('Central Angle (rad)')
% saveas(gcf,'CA.png')
%  savefig('CA.fig')
% %% Power 
% figure
%  timevec=tsc.velocityVec.Time;
%  ten=squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1)));
% plot(tsc.thrReleaseSpeeds.Time,tsc.thrReleaseSpeeds.data.*ten)
% xlabel('time (s)')
% ylabel('Power (Watts)')
%  [~,i1]=min(abs(timevec - 0));
%  [~,i2]=min(abs(timevec -100)); %(timevec(end)/2)));
%  [~,poweri1]=min(tsc.thrReleaseSpeeds.data(i1:i2).*ten(i1:i2));
% poweri1 = poweri1 + i1;
% [~,i3]=min(abs(timevec - (timevec(end)/2)));
% [~,i4]=min(abs(timevec - timevec(end)));
% i4=i4-1;
% [~,poweri2]=min(tsc.thrReleaseSpeeds.data(i3:i4).*ten(i3:i4));
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
%  meanPower = mean(tsc.thrReleaseSpeeds.data(poweri1:poweri2).*ten(poweri1:poweri2))
% title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',meanPower));
%  saveas(gcf,'power.png')
%  savefig('pow.fig')
% %% Flow Plot
% 
% figure
% tsc.flowVelocityVec.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
%     'DisplayName','Flow Velocity (x)');
% grid on
% title('Flow Velocity (x) vs. Time')
% ylabel('Flow Velocity (x)(m/s)')
%  
% %% tension vs sStar
% 
% plot(tsc.FThrNetBdy.Time,squeeze(-2+((1/10^5)*sqrt(sum(tsc.FThrNetBdy.Data.^2,1)))));
%     xlabel('time (s)')
%     ylabel('Tether Tension Magnitude on Body (N)')
%     title("Tether Tension")
% hold on
% tsc.sStar.plot