clear all;clc

scaleFactor = 0.5;
duration_s  = 500*sqrt(scaleFactor);

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'oneTetherThreeSurfaceCtrl';


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
% Load it from a file
load('TestVehicle1')

vhcl.setICs('InitPos',[0 0 200],'InitEulAng',[0 7 0]*pi/180);

vhcl.scale(scaleFactor);

%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.setValue(1,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad*s)');
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
gndStn.thrAttch1.posVec.setValue([0 0 0],'m');
gndStn.freeSpnEnbl.setValue(false,'');

% Scale up/down
gndStn.scale(scaleFactor);

%% Tethers
% Create
thr = OCT.tethers;
thr.numTethers.setValue(1,'');
thr.build;

% Set parameter values
thr.tether1.numNodes.setValue(5,'');
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:),'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
% thr.tether1.diameter.Value      = 0.04;
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(30e9,'Pa');
thr.tether1.dampingRatio.setValue(0.05,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');

thr.designTetherDiameter(vhcl,env);

% Scale up/down
thr.scale(scaleFactor);


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
ctrl.elevators.kp.setValue(10,'(deg)/(deg)'); % do we really want to represent unitless values like this?
% ctrl.elevators.ki.Value = 2;
ctrl.elevators.kd.setValue(0.25,'(deg*s)/(deg)'); % Likewise, do we want (deg*s)/(deg) or just s?
ctrl.elevators.tau.setValue(0.05,'s');

ctrl.ailerons.kp.setValue(15,'(deg)/(deg)');
ctrl.ailerons.kd.setValue(15,'(deg*s)/(deg)');
ctrl.ailerons.tau.setValue(0.05,'s');

ctrl.outputSat.upperLimit.setValue(0,'');
ctrl.outputSat.lowerLimit.setValue(0,'');

% Calculate setpoints
timeVec = 0:0.1:1000;
ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';
ctrl.rollSP.Value = timeseries(30*sign(sin(2*pi*timeVec/(100))),timeVec);
ctrl.rollSP.Value.Data(timeVec<60) = 0;
ctrl.rollSP.Value.DataInfo.Units = 'deg';

% Scale up/down
ctrl = ctrl.scale(scaleFactor);

%% Run the simulation
sim('OCTModel')
% Run stop callback to plot everything
stopCallback


