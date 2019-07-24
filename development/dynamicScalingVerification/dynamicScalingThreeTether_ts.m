% clear;
clearvars logsout
clc
format compact
close all
scaleFactor = 1;
duration_s = 500;

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'threeTetherThreeSurfaceCtrl';


% Tether nodal forces
dragEnable = true;
springDamperEnable = true;
netBuoyEnable = true;

%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createThreeTetherThreeSurfaceCtrlBus;


%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.setValue([1 0 0],'m/s');


%% Vehicle
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(3,'');
vhcl.numTurbines.setValue(2,'');
vhcl.build('partDsgn1_hsIncAng_lookupTables.mat');

% Set Values
BF = 1.02;
vhcl.Ixx.setValue(6303.1,'kg*m^2');
vhcl.Iyy.setValue(2080.7,'kg*m^2');
vhcl.Izz.setValue(8320.4,'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(0.0,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.volume.setValue(945352023e-9,'m^3');
vhcl.mass.setValue(vhcl.volume.Value*1000/BF,'kg');

vhcl.centOfBuoy.setValue([ 0 0 0]','m');
vhcl.thrAttch1.posVec.setValue([-0.2254   -5.0000         0]','m');
vhcl.thrAttch2.posVec.setValue([ 6.3500         0         0]','m');
vhcl.thrAttch3.posVec.setValue([-0.2254    5.0000         0]','m');

vhcl.setICs('InitPos',[0 0 100],'InitEulAng',[0 7 0]*pi/180,'InitVel',[1 0 0]);

vhcl.turbine1.diameter.setValue(0,'m');
vhcl.turbine1.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine1.attachPtVec.setValue([-1.25 -5 0]','m');
vhcl.turbine1.powerCoeff.setValue(0.5,'');
vhcl.turbine1.dragCoeff.setValue(0.8,'');

vhcl.turbine2.diameter.setValue(0,'m');
vhcl.turbine2.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine2.attachPtVec.setValue([-1.25  5 0]','m');
vhcl.turbine2.powerCoeff.setValue(0.5,'');
vhcl.turbine2.dragCoeff.setValue(0.8,'');


%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.setValue(3,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad/s)');
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
gndStn.thrAttch1.posVec.setValue([-0.2254   -5.0000         0],'m');
gndStn.thrAttch2.posVec.setValue([ 6.3500         0         0],'m');
gndStn.thrAttch3.posVec.setValue([-0.2254    5.0000         0],'m');
gndStn.freeSpnEnbl.setValue(false,'');


%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(3,'');
thr.setNumNodes(2,'');
thr.build;

% Set parameter values
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:),'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(100e9,'Pa');
thr.tether1.diameter.setValue(0.015,'m');
thr.tether1.dampingRatio.setValue(0.05,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
thr.tether1.setDragEnable(dragEnable,'');
thr.tether1.setSpringDamperEnable(springDamperEnable,'');
thr.tether1.setNetBuoyEnable(netBuoyEnable,'');

thr.tether2.initGndNodePos.setValue(gndStn.thrAttch2.posVec.Value(:),'m');
thr.tether2.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch2.posVec.Value(:),'m');
thr.tether2.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether2.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether2.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether2.youngsMod.setValue(100e9,'Pa');
thr.tether2.diameter.setValue(0.015,'m');
thr.tether2.dampingRatio.setValue(0.05,'');
thr.tether2.dragCoeff.setValue(0.5,'');
thr.tether2.density.setValue(1300,'kg/m^3');
thr.tether2.setDragEnable(dragEnable,'');
thr.tether2.setSpringDamperEnable(springDamperEnable,'');
thr.tether2.setNetBuoyEnable(netBuoyEnable,'');

thr.tether3.initGndNodePos.setValue(gndStn.thrAttch3.posVec.Value(:),'m');
thr.tether3.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch3.posVec.Value(:),'m');
thr.tether3.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether3.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether3.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether3.youngsMod.setValue(100e9,'Pa');
thr.tether3.diameter.setValue(0.015,'m');
thr.tether3.dampingRatio.setValue(0.05,'');
thr.tether3.dragCoeff.setValue(0.5,'');
thr.tether3.density.setValue(1300,'kg/m^3');
thr.tether3.setDragEnable(dragEnable,'');
thr.tether3.setSpringDamperEnable(springDamperEnable,'');
thr.tether3.setNetBuoyEnable(netBuoyEnable,'');

%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(3,'');
wnch.build;
% Set values
wnch.winch1.maxSpeed.setValue(1,'m/s');
wnch.winch1.timeConst.setValue(1,'s');
wnch.winch1.maxAccel.setValue(10e10,'m/s^2');

wnch.winch2.maxSpeed.setValue(1,'m/s');
wnch.winch2.timeConst.setValue(1,'s');
wnch.winch2.maxAccel.setValue(10e10,'m/s^2');

wnch.winch3.maxSpeed.setValue(1,'m/s');
wnch.winch3.timeConst.setValue(1,'s');
wnch.winch3.maxAccel.setValue(10e10,'m/s^2');

wnch = wnch.setTetherInitLength(vhcl,env,thr);


%% Set up controller
% Create
ctrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
ctrl.add('FPIDNames',{'tetherAlti','tetherPitch','tetherRoll','elevators','ailerons','rudder'},...
    'FPIDErrorUnits',{'m','rad','rad','deg','deg','deg'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s','deg','deg','deg'});

% add control allocation matrix (implemented as a simple gain)
ctrl.add('GainNames',{'ctrlSurfAllocationMat','thrAllocationMat'},...
    'GainUnits',{'',''});

% add output saturation
ctrl.add('SaturationNames',{'outputSat'});

% add setpoints
ctrl.add('SetpointNames',{'altiSP','pitchSP','rollSP','yawSP'},...
    'SetpointUnits',{'m','deg','deg','deg'});

% tether controllers
ctrl.tetherAlti.kp.setValue(0,'(m/s)/(m)');
ctrl.tetherAlti.ki.setValue(0,'(m/s)/(m*s)');
ctrl.tetherAlti.kd.setValue(0,'(m/s)/(m/s)');
ctrl.tetherAlti.tau.setValue(0.5,'s');

ctrl.tetherPitch.kp.setValue(1,'(m/s)/(rad)');
ctrl.tetherPitch.ki.setValue(0,'(m/s)/(rad*s)');
ctrl.tetherPitch.kd.setValue(0,'(m/s)/(rad/s)');
ctrl.tetherPitch.tau.setValue(0.5,'s');

ctrl.tetherRoll.kp.setValue(0,'(m/s)/(rad)');
ctrl.tetherRoll.ki.setValue(0,'(m/s)/(rad*s)');
ctrl.tetherRoll.kd.setValue(0,'(m/s)/(rad/s)');
ctrl.tetherRoll.tau.setValue(0.5,'s');

ctrl.thrAllocationMat.setValue([1 .5 -.5; 1 -.5 0; 1 .5 .5],'');

% Set the values of the controller parameters
ctrl.ailerons.kp.setValue(1,'(deg)/(deg)');
ctrl.ailerons.ki.setValue(0,'(deg)/(deg*s)');
ctrl.ailerons.kd.setValue(0,'(deg)/(deg/s)');
ctrl.ailerons.tau.setValue(0.5,'s');

ctrl.elevators.kp.setValue(1,'(deg)/(deg)'); % do we really want to represent unitless values like this?
ctrl.elevators.ki.setValue(0,'(deg)/(deg*s)');
ctrl.elevators.kd.setValue(0,'(deg)/(deg/s)'); % Likewise, do we want (deg*s)/(deg) or just s?
ctrl.elevators.tau.setValue(0.01,'s');

ctrl.rudder.kp.setValue(0,'(deg)/(deg)');
ctrl.rudder.ki.setValue(0,'(deg)/(deg*s)');
ctrl.rudder.kd.setValue(0,'(deg)/(deg/s)');
ctrl.rudder.tau.setValue(0.5,'s');

ctrl.ctrlSurfAllocationMat.setValue([-1 0 0; 1 0 0; 0 -1 0; 0 0 1],'');


ctrl.outputSat.upperLimit.setValue(30,'');
ctrl.outputSat.lowerLimit.setValue(-30,'');

% Calculate setpoints
timeVec = 0:0.1:duration_s;
ctrl.altiSP.Value = timeseries(100*ones(size(timeVec)),timeVec);
ctrl.altiSP.Value.DataInfo.Units = 'm';

ctrl.pitchSP.Value = timeseries(8*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';

ctrl.rollSP.Value = timeseries(25*sign(sin(2*pi*timeVec/(120))),timeVec);
ctrl.rollSP.Value.Data(timeVec<120) = 0;
ctrl.rollSP.Value.DataInfo.Units = 'deg';

ctrl.yawSP.Value = timeseries(0*ones(size(timeVec)),timeVec);
ctrl.yawSP.Value.DataInfo.Units = 'deg';


%% Run first sim
try
    sim('OCTModel');
catch
end
tsc1 = parseLogsout;
clearvars logsout

%% Scaling
scaleFactor = 0.01;
duration_s = duration_s*sqrt(scaleFactor);
% Scale up/down
env.scale(scaleFactor);
% Scale up/down
vhcl.scale(scaleFactor);
% Scale up/down
gndStn.scale(scaleFactor);
% Scale up/down
thr.scale(scaleFactor);
% Scale up/down
wnch.scale(scaleFactor);
% Scale up/down
ctrl = ctrl.scale(scaleFactor);


%% Run second sim
try
    sim('OCTModel');
catch
end
tsc2 = parseLogsout;

%% Post Process
sigs = fieldnames(tsc2);
for ii = 1:length(sigs)
    try
        tsc2.(sigs{ii}).Time = tsc2.(sigs{ii}).Time/sqrt(scaleFactor);
    catch
        warning('Skipping %s',sigs{ii})
    end
end

%%
figure
subplot(3,2,1)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(1,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(1,:,:)),...
    'DisplayName','Roll, Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Roll, [rad]')

subplot(3,2,3)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(2,:,:)),...
    'DisplayName','Pitch, Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(2,:,:)),...
    'DisplayName','Pitch, Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Pitch, [rad]')

subplot(3,2,5)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(3,:,:)),...
    'DisplayName','Yaw, Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(3,:,:)),...
    'DisplayName','Yaw, Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Yaw, [rad]')


subplot(3,2,2)
plot(tsc1.positionVec.Time,squeeze(tsc1.positionVec.Data(1,:,:))*scaleFactor,...
    'DisplayName','Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.positionVec.Time,squeeze(tsc2.positionVec.Data(1,:,:)),...
    'DisplayName','Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('X Normed')

subplot(3,2,4)
plot(tsc1.positionVec.Time,squeeze(tsc1.positionVec.Data(2,:,:))*scaleFactor,...
    'DisplayName','Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.positionVec.Time,squeeze(tsc2.positionVec.Data(2,:,:)),...
    'DisplayName','Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Y Normed')

subplot(3,2,6)
plot(tsc1.positionVec.Time,squeeze(tsc1.positionVec.Data(3,:,:))*scaleFactor,...
    'DisplayName','Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.positionVec.Time,squeeze(tsc2.positionVec.Data(3,:,:)),...
    'DisplayName','Scaled','LineWidth',1.5,'Color','r','LineStyle','--')
xlabel('Normalized Time')
ylabel('Z Normed')
set(findall(gcf,'Type','axes'),'FontSize',24)


%% Plot moments breakdown
% figure
% subplot(3,1,1)
% plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Fluid')
% 
% subplot(3,1,2)
% plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Fluid')
% 
% subplot(3,1,3)
% plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Fluid')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')
% 
% figure
% subplot(3,1,1)
% plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Turb')
% 
% subplot(3,1,2)
% plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Turb')
% 
% subplot(3,1,3)
% plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Turb')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')
% 
% figure
% subplot(3,1,1)
% plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Thr')
% 
% subplot(3,1,2)
% plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Thr')
% 
% subplot(3,1,3)
% plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Thr')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')
% 
% figure
% subplot(3,1,1)
% plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Buoy')
% 
% subplot(3,1,2)
% plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('My Buoy')
% 
% subplot(3,1,3)
% plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mz Buoy')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')
