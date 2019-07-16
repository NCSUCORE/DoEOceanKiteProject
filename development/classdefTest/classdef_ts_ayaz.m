clear;
clc
format compact

scaleFactor = 1/10;
duration_s  = 1500*sqrt(scaleFactor);

% merging branches
altiMin = 100*sqrt(scaleFactor);
altiMax = 150*sqrt(scaleFactor);


%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'singleTetherSpooling';
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
% Scale up/down
env.scale(scaleFactor);

%% Vehicle
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(2,'');
vhcl.build('partDsgn2_lookupTables.mat');

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

vhcl.centOfBuoy.setValue([0 0 0]','m');
vhcl.thrAttch1.posVec.setValue([0 0 0]','m');

vhcl.setICs('InitPos',[0 0 1.25*altiMin],'InitEulAng',[0 7 0]*pi/180,'InitVel',[1 0 0]);

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

% Scale up/down
vhcl.scale(scaleFactor);

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

% Scale up/down
gndStn.scale(scaleFactor);

%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(4,'');
thr.build;

% Set parameter values
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:),'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(10e9,'Pa');
thr.tether1.dampingRatio.setValue(0.05,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');

thr.designTetherDiameter(vhcl,env);

% Scale up/down
thr.scale(scaleFactor);


%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build;
% Set values
wnch.winch1.maxSpeed.setValue(0.15,'m/s');
wnch.winch1.timeConst.setValue(5,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');

wnch = wnch.setTetherInitLength(vhcl,env,thr);

% Scale up/down
wnch.scale(scaleFactor);


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
ctrl.ailerons.kp.setValue(0.6,'(deg)/(deg)');
ctrl.ailerons.ki.setValue(0,'(deg)/(deg*s)');
ctrl.ailerons.kd.setValue(1.2,'(deg*s)/(deg)');
ctrl.ailerons.tau.setValue(0.5,'s');

ctrl.elevators.kp.setValue(.15,'(deg)/(deg)'); % do we really want to represent unitless values like this?
ctrl.elevators.ki.setValue(0,'(deg)/(deg*s)');
ctrl.elevators.kd.setValue(1,'(deg*s)/(deg)'); % Likewise, do we want (deg*s)/(deg) or just s?
ctrl.elevators.tau.setValue(0.01,'s');


ctrl.outputSat.upperLimit.setValue(30,'');
ctrl.outputSat.lowerLimit.setValue(-30,'');

% Calculate setpoints
timeVec = 0:0.1:duration_s;
ctrl.pitchSP.Value = timeseries(8*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';
ctrl.rollSP.Value = timeseries(25*sign(sin(2*pi*timeVec/(120))),timeVec);
ctrl.rollSP.Value.Data(timeVec<120) = 0;
ctrl.rollSP.Value.DataInfo.Units = 'deg';

% Scale up/down
ctrl = ctrl.scale(scaleFactor);

%% Run the simulation
try
    simWithMonitor('OCTModel',2)
catch
    simWithMonitor('OCTModel',2)
end
% Run stop callback to plot everything

stopCallback


