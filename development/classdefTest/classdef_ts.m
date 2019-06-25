clear all;clc

scaleFactor = 1;
simParam = simParamClass;

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
PLANT           = 'modularPlant';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'oneTetherThreeSurfaceCtrl';
duration_s      = 500;

%% Create busses
createConstantUniformFlowEnvironmentBus
createOrigionalPlantBus;
createOneTetherThreeSurfaceCtrlBus;

%% Build the vehicle
vhcl = OCT.vehicle;
vhcl.numTethers.Value  = 1;
vhcl.numTurbines.Value = 2;
vhcl.build('partDsgn1_lookupTables.mat');

% vhcl.mass.Value = (8.9360e+04)*(1/4)^3;%0.8*(945.352);
% vhcl.Ixx.Value = 14330000*(1/4)^5;%(6.303e9)*10^-6;
% vhcl.Iyy.Value = 143200*(1/4)^5;%2080666338.077*10^-6;
% vhcl.Izz.Value = 15300000*(1/4)^5;%(8.32e9)*10^-6;
% vhcl.Ixy.Value = 0;
% vhcl.Ixz.Value = 0;%81875397*10^-6;
% vhcl.Iyz.Value = 0;
% vhcl.volume.Value = 111.7*(1/4)^3;%9453552023*10^-6;

vhcl.Ixx.Value = (6.303e9)*10^-6;
vhcl.Iyy.Value = 2080666338.077*10^-6;
vhcl.Izz.Value = (8.32e9)*10^-6;
vhcl.Ixy.Value = 0;
vhcl.Ixz.Value = 81875397*10^-6;
vhcl.Iyz.Value = 0;
vhcl.volume.Value = 0.945352023;
vhcl.mass.Value = 0.8*vhcl.volume.Value*1000;

vhcl.centOfBuoy.Value = [0 0 0]';
vhcl.thrAttch1.posVec.Value = [0 0 0]';

vhcl.setICs('InitPos',[150 0 150],'InitEulAng',[0 7 0]*pi/180);

vhcl.turbine1.diameter.Value        = 1;
vhcl.turbine1.axisUnitVec.Value     = [1 0 0]';
vhcl.turbine1.attachPtVec.Value     = [-1.25 -5 0]';
vhcl.turbine1.powerCoeff.Value      = 0.5;
vhcl.turbine1.dragCoeff.Value       = 0.8;

vhcl.turbine2.diameter.Value        = 1;
vhcl.turbine2.axisUnitVec.Value     = [1 0 0]';
vhcl.turbine2.attachPtVec.Value     = [-1.25  5 0]';
vhcl.turbine2.powerCoeff.Value      = 0.5;
vhcl.turbine2.dragCoeff.Value       = 0.8;

vhcl.aeroSurf1.aeroCentPosVec.Value(1) = -1.25;
vhcl.aeroSurf2.aeroCentPosVec.Value(1) = -1.25;

vhcl.scale(scaleFactor);

%% Create ground station
gndStn = OCT.station;
gndStn.numTethers.Value = 1;
gndStn.build;

gndStn.inertia.Value            = 1;
gndStn.posVec.Value             = [0 0 0];
gndStn.dampCoeff.Value          = 1;
gndStn.initAngPos.Value         = 0;
gndStn.initAngVel.Value         = 0;
gndStn.thrAttch1.posVec.Value   = [0 0 0];
gndStn.freeSpnEnbl.Value        = false;
gndStn.scale(scaleFactor);

%% Create tethers
thr = OCT.tethers;
thr.numTethers.Value = 1;
thr.build
thr.tether1.numNodes.Value       = 5;
thr.tether1.initGndNodePos.Value = gndStn.thrAttch1.posVec.Value(:);
thr.tether1.initAirNodePos.Value = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:);
thr.tether1.initGndNodeVel.Value = [0 0 0]';
thr.tether1.initAirNodeVel.Value = vhcl.initVelVecGnd.Value(:);
thr.tether1.diameter.Value      = 0.05;
thr.tether1.youngsMod.Value     = 3.8e9;
thr.tether1.dampingRatio.Value  = 0.05;
thr.tether1.dragCoeff.Value     = 0.5;
thr.tether1.density.Value       = 1300;
thr.scale(scaleFactor)


%% Create winches
winch(1).initLength = 212;
winch(1).maxSpeed  = 0.4;
winch(1).timeConst = 1;
winch(1).maxAccel = inf;


%% Set up controller
ctrl = threeTetherThreeSurfaceCtrlClass;

ctrl.elevonPitchKp.Value   = 0;
ctrl.elevonPitchKi.Value   = 0;
ctrl.elevonPitchKd.Value   = 0;
ctrl.elevonPitchTau.Value  = 1;

ctrl.elevonRollKp.Value   = 0;
ctrl.elevonRollKi.Value   = 0;
ctrl.elevonRollKd.Value   = 0;
ctrl.elevonRollTau.Value  = 1;

ctrl.tetherAltitudeKp.Value   = 0;
ctrl.tetherAltitudeKi.Value   = 0;
ctrl.tetherAltitudeKd.Value   = 0;
ctrl.tetherAltitudeTau.Value  = 1;

ctrl.tetherPitchKp.Value   = 0;
ctrl.tetherPitchKi.Value   = 0;
ctrl.tetherPitchKd.Value   = 0;
ctrl.tetherPitchTau.Value  = 1;

ctrl.tetherRollKp.Value   = 0;
ctrl.tetherRollKi.Value   = 0;
ctrl.tetherRollKd.Value   = 0;
ctrl.tetherRollTau.Value  = 1;

ctrl.P_cs_mat.Value = [1 0;0 1];
ctrl.elevonPitchKp.Value = 12.5;
ctrl.elevonPitchKi.Value  = 1;

ctrl.elevonRollKp.Value = 15;
ctrl.elevonRollKd.Value  = 15;

% Calculate setpoints
timeVec = 0:0.1:duration_s;
set_alt = timeseries(ctrl.setAltM.Value*ones(size(timeVec)),timeVec);
set_pitch = timeseries(7*ones(size(timeVec)),timeVec);
set_roll = timeseries(ctrl.setRollDeg.Value*ones(size(timeVec)),timeVec);
set_roll.Data = 30*sign(sin(2*pi*timeVec/(100)));
set_roll.Data(timeVec<60) = 0;

ctrl.scale(scaleFactor);



sim('OCTModel')

stopCallback


