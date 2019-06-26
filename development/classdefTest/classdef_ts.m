clear all;clc

scaleFactor = 1;
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

%% Vehicle
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.Value  = 1;
vhcl.numTurbines.Value = 2;
vhcl.build('partDsgn1_lookupTables.mat');

% Set Values
% vhcl.mass.Value = (8.9360e+04)*(1/4)^3;%0.8*(945.352);
% vhcl.Ixx.Value = 14330000*(1/4)^5;%(6.303e9)*10^-6;
% vhcl.Iyy.Value = 143200*(1/4)^5;%2080666338.077*10^-6;
% vhcl.Izz.Value = 15300000*(1/4)^5;%(8.32e9)*10^-6;
% vhcl.Ixy.Value = 0;
% vhcl.Ixz.Value = 0;%81875397*10^-6;
% vhcl.Iyz.Value = 0;
% vhcl.volume.Value = 111.7*(1/4)^3;%9453552023*10^-6;

% vhcl.Ixx.Value = (6.303e9)*10^-6;
% vhcl.Iyy.Value = 2080666338.077*10^-6;
% vhcl.Izz.Value = (8.32e9)*10^-6;
% vhcl.Ixy.Value = 0;
% vhcl.Ixz.Value = 81875397*10^-6;
% vhcl.Iyz.Value = 0;
% vhcl.volume.Value = 0.945352023;
% vhcl.mass.Value = 0.8*vhcl.volume.Value*1000;

vhcl.Ixx.Value = (100e3)*(6.3/8);
vhcl.Iyy.Value = (100e3)*(2/8);
vhcl.Izz.Value = 100e3;
vhcl.Ixy.Value = 0;
vhcl.Ixz.Value = 0;
vhcl.Iyz.Value = 0;
vhcl.volume.Value = 6.033;
vhcl.mass.Value = 0.95*vhcl.volume.Value*1000;

vhcl.centOfBuoy.Value = [0 0 0]';
vhcl.thrAttch1.posVec.Value = [0 0 0]';

vhcl.setICs('InitPos',[90 0 185],'InitEulAng',[0 7 0]*pi/180);

vhcl.turbine1.diameter.Value        = 0;
vhcl.turbine1.axisUnitVec.Value     = [1 0 0]';
vhcl.turbine1.attachPtVec.Value     = [-1.25 -5 0]';
vhcl.turbine1.powerCoeff.Value      = 0.5;
vhcl.turbine1.dragCoeff.Value       = 0.8;

vhcl.turbine2.diameter.Value        = 0;
vhcl.turbine2.axisUnitVec.Value     = [1 0 0]';
vhcl.turbine2.attachPtVec.Value     = [-1.25  5 0]';
vhcl.turbine2.powerCoeff.Value      = 0.5;
vhcl.turbine2.dragCoeff.Value       = 0.8;

vhcl.aeroSurf1.aeroCentPosVec.Value(1) = 0;
vhcl.aeroSurf2.aeroCentPosVec.Value(1) = 0;

% Scale up/down
vhcl.scale(scaleFactor);

%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.Value = 1;
gndStn.build;

% Set values
gndStn.inertia.Value            = 1;
gndStn.posVec.Value             = [0 0 0];
gndStn.dampCoeff.Value          = 1;
gndStn.initAngPos.Value         = 0;
gndStn.initAngVel.Value         = 0;
gndStn.thrAttch1.posVec.Value   = [0 0 0];
gndStn.freeSpnEnbl.Value        = false;

% Scale up/down
gndStn.scale(scaleFactor);




%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.Value = 1;
wnch.build;
% Set values
wnch.winch1.initLength.Value = 212;
wnch.winch1.maxSpeed.Value   = 0.4;
wnch.winch1.timeConst.Value  = 1;
wnch.winch1.maxAccel.Value   = inf;

% Scale up/down
wnch.scale(scaleFactor);


%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.Value = [1 0 0];
% Scale up/down
env.scale(scaleFactor);

%% Tethers
% Create
thr = OCT.tethers;
thr.numTethers.Value = 1;
thr.build;

% Set parameter values
thr.tether1.numNodes.Value       = 5;
thr.tether1.initGndNodePos.Value = gndStn.thrAttch1.posVec.Value(:);
thr.tether1.initAirNodePos.Value = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:);
thr.tether1.initGndNodeVel.Value = [0 0 0]';
thr.tether1.initAirNodeVel.Value = vhcl.initVelVecGnd.Value(:);
% thr.tether1.diameter.Value      = 0.04;
thr.tether1.vehicleMass.Value   = vhcl.mass.Value;
thr.tether1.youngsMod.Value     = 60e9;
thr.tether1.dampingRatio.Value  = 0.05;
thr.tether1.dragCoeff.Value     = 0.5;
thr.tether1.density.Value       = 1300;

thr.designTetherDiameter(vhcl,env)

% Scale up/down
thr.scale(scaleFactor);

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
ctrl.elevators.kp.Value = 10;
ctrl.elevators.ki.Value = 2;

ctrl.ailerons.kp.Value  = 15;
ctrl.ailerons.kd.Value  = 15;

ctrl.outputSat.upperLimit.Value = 30;
ctrl.outputSat.lowerLimit.Value = -30;

% Calculate setpoints
timeVec = 0:0.1:duration_s;
ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);

ctrl.rollSP.Value = timeseries(30*sign(sin(2*pi*timeVec/(100))),timeVec);
ctrl.rollSP.Value.Data(timeVec<60) = 0;



% Scale up/down
ctrl.scale(scaleFactor);

%% Run the simulation
sim('OCTModel')
% Run stop callback to plot everything
stopCallback


