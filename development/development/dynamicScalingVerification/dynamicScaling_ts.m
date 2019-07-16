clear all;clc;close all

scaleFactor = 0.01;
duration_s  = 250;

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'oneTetherThreeSurfaceCtrl';
VARIANTSUBSYSTEM = 'NNodeTether';


%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createOneTetherThreeSurfaceCtrlBus;


%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.setValue([1 0 0],'m/s');

%% Vehicle
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(2,'');
vhcl.build('partDsgn1_lookupTables.mat');

% Set Values
vhcl.Ixx.setValue(34924.16,'kg*m^2');
vhcl.Iyy.setValue(30487.96,'kg*m^2');
vhcl.Izz.setValue(64378.94,'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(731.66,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.volume.setValue(7.40,'m^3');
vhcl.mass.setValue(0.95*7404.24,'kg');

% vhcl.Ixx.setValue(6303,'kg*m^2');
% vhcl.Iyy.setValue(2080.7,'kg*m^2');
% vhcl.Izz.setValue(8320.4,'kg*m^2');
% vhcl.Ixy.setValue(0,'kg*m^2');
% vhcl.Ixz.setValue(0,'kg*m^2');
% vhcl.Iyz.setValue(0,'kg*m^2');
% vhcl.volume.setValue(0.9454,'m^3');
% vhcl.mass.setValue(859.4,'kg');

vhcl.centOfBuoy.setValue([0 0 0]','m');
vhcl.thrAttch1.posVec.setValue([0 0 0]','m');

vhcl.setICs('InitPos',[0 0 200],'InitEulAng',[0 7 0]*pi/180);

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
gndStn.numTethers.setValue(1,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad/s)');
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
gndStn.thrAttch1.posVec.setValue([0 0 0],'m');
gndStn.freeSpnEnbl.setValue(false,'');


%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(5,'');
thr.build;

% Set parameter values
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:),'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(50e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(false,'');
thr.tether1.setDiameter(0.015,'m');


%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build;
% Set values
wnch.winch1.maxSpeed.setValue(0.4,'m/s');
wnch.winch1.timeConst.setValue(1,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');

wnch = wnch.setTetherInitLength(vhcl,env,thr);

%% Set up controller
% Create
ctrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
ctrl.add('FPIDNames',{'elevators','ailerons'},...
    'FPIDErrorUnits',{'deg','deg'},...
    'FPIDOutputUnits',{'deg','deg'});

% add control allocation matrix (implemented as a simple gain)
ctrl.add('GainNames',{'ctrlAllocMat'},...
    'GainUnits',{''});

% add output saturation
ctrl.add('SaturationNames',{'outputSat'});

% add setpoints
ctrl.add('SetpointNames',{'pitchSP','rollSP'},...
    'SetpointUnits',{'deg','deg'});

% Set the values of the controller parameters
ctrl.elevators.kp.setValue(15,'(deg)/(deg)'); % do we really want to represent unitless values like this?
ctrl.elevators.tau.setValue(0.05,'s');

ctrl.ailerons.kp.setValue(15,'(deg)/(deg)');
ctrl.ailerons.kd.setValue(0,'(deg*s)/(deg)');
ctrl.ailerons.tau.setValue(0.05,'s');

ctrl.outputSat.upperLimit.setValue(30,'');
ctrl.outputSat.lowerLimit.setValue(-30,'');

% Calculate setpoints
timeVec = 0:0.1:1000;
ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';
ctrl.rollSP.Value = timeseries(20*sign(sin(2*pi*timeVec/(100))),timeVec);
ctrl.rollSP.Value.Data(timeVec<60) = 0;
ctrl.rollSP.Value.DataInfo.Units = 'deg';

%% Run first sim
simWithMonitor('OCTModel',5)
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
simWithMonitor('OCTModel',5)
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
subplot(3,1,1)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(1,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(1,:,:)),...
    'DisplayName','Roll, Scaled','LineWidth',1.5,'Color','r','LineStyle','--')
xlabel('Normalized Time')
ylabel('Roll, [rad]')

subplot(3,1,2)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(2,:,:)),...
    'DisplayName','Pitch, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(2,:,:)),...
    'DisplayName','Pitch, Scaled','LineWidth',1.5,'Color','r','LineStyle','--')
xlabel('Normalized Time')
ylabel('Pitch, [rad]')

subplot(3,1,3)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(3,:,:)),...
    'DisplayName','Yaw, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(3,:,:)),...
    'DisplayName','Yaw, Scaled','LineWidth',1.5,'Color','r','LineStyle','--')
xlabel('Normalized Time')
ylabel('Yaw, [rad]')

%% Plot moments breakdown
figure
subplot(3,1,1)
plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(1,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(1,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Fluid')

subplot(3,1,2)
plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(2,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(2,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Fluid')

subplot(3,1,3)
plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(3,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(3,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Fluid')

linkaxes(findall(gcf,'Type','axes'),'x')

figure
subplot(3,1,1)
plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(1,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(1,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Turb')

subplot(3,1,2)
plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(2,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(2,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Turb')

subplot(3,1,3)
plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(3,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(3,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Turb')

linkaxes(findall(gcf,'Type','axes'),'x')

figure
subplot(3,1,1)
plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(1,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(1,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Thr')

subplot(3,1,2)
plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(2,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(2,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Thr')

subplot(3,1,3)
plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(3,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(3,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Thr')

linkaxes(findall(gcf,'Type','axes'),'x')

figure
subplot(3,1,1)
plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(1,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(1,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mx Buoy')

subplot(3,1,2)
plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(2,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(2,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('My Buoy')

subplot(3,1,3)
plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(3,:,:))*scaleFactor^4,...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(3,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
ylabel('Mz Buoy')

linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot local angles of attack
format compact
clc
tsc1.CL.Data(:,:,1)-tsc2.CL.Data(:,:,1)
tsc1.CD.Data(:,:,1)-tsc2.CD.Data(:,:,1)
tsc1.alphaLocal.Data(:,:,1)-tsc2.alphaLocal.Data(:,:,1)
tsc1.MFluidBdy.Data(:,:,1)*(scaleFactor^4)-tsc2.MFluidBdy.Data(:,:,1)

tsc1.FFluidBdy.Data(:,:,1)*(scaleFactor^3)-tsc2.FFluidBdy.Data(:,:,1)
tsc1.FTurb1Bdy.Data(:,:,1)*(scaleFactor^3)-tsc2.FTurb1Bdy.Data(:,:,1)
tsc1.FGravBdy.Data(:,:,1)*(scaleFactor^3)-tsc2.FGravBdy.Data(:,:,1)
tsc1.FBuoyBdy.Data(:,:,1)*(scaleFactor^3)-tsc2.FBuoyBdy.Data(:,:,1)
tsc1.FThrNetBdy.Data(:,:,1)*(scaleFactor^3)-tsc2.FThrNetBdy.Data(:,:,1)

tsc1.airTenVecBusArry.tenVec.Data(:,:,1)*(scaleFactor^3)-tsc2.airTenVecBusArry.tenVec.Data(:,:,1)



