clear all;clc;
format compact

scaleFactor = 1;
duration_s  = 500*sqrt(scaleFactor);

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
PLANT           = 'modularPlant';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'oneTetherThreeSurfaceCtrl';


%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createOneTetherThreeSurfaceCtrlBus;

%% Vehicle
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.Value  = 3;
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

vhcl.Ixx.Value = (6.303e9)*10^-6;
vhcl.Iyy.Value = 2080666338.077*10^-6;
vhcl.Izz.Value = (8.32e9)*10^-6;
vhcl.Ixy.Value = 0;
vhcl.Ixz.Value = 81875397*10^-6;
vhcl.Iyz.Value = 0;
vhcl.volume.Value = 0.945352023;
vhcl.mass.Value = 0.8*vhcl.volume.Value*1000;

vhcl.centOfBuoy.Value = [0 0 0]';
vhcl.thrAttch1.posVec.Value = [-1 -1 -0.5]';
vhcl.thrAttch2.posVec.Value = [0 1 -0.5]';
vhcl.thrAttch3.posVec.Value = [-1 1 -0.5]';


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

% Scale up/down
vhcl.scale(scaleFactor);

%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.Value = 3;
gndStn.build;

% Set values
gndStn.inertia.Value            = 1;
gndStn.posVec.Value             = [0 0 0];
gndStn.dampCoeff.Value          = 1;
gndStn.initAngPos.Value         = 0;
gndStn.initAngVel.Value         = 0;
gndStn.thrAttch1.posVec.Value   = [-1 -1 0]';
gndStn.thrAttch2.posVec.Value   = [0 1 0]';
gndStn.thrAttch3.posVec.Value   = [-1 1 0]';


gndStn.freeSpnEnbl.Value        = false;

% Scale up/down
gndStn.scale(scaleFactor);

%% Tethers
% Create
thr = OCT.tethers;
thr.numTethers.Value = 3;
thr.build;

% Set parameter values
thr.tether1.numNodes.Value       = 5;
thr.tether1.initGndNodePos.Value = gndStn.thrAttch1.posVec.Value(:);
thr.tether1.initAirNodePos.Value = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:);
thr.tether1.initGndNodeVel.Value = [0 0 0]';
thr.tether1.initAirNodeVel.Value = vhcl.initVelVecGnd.Value(:);
thr.tether1.diameter.Value      = 0.05;
thr.tether1.vehicleMass.Value   = vhcl.mass.Value;
thr.tether1.youngsMod.Value     = 3.8e9;
thr.tether1.dampingRatio.Value  = 0.05;
thr.tether1.dragCoeff.Value     = 0.5;
thr.tether1.density.Value       = 1300;

thr.tether2.numNodes.Value       = 5;
thr.tether2.initGndNodePos.Value = gndStn.thrAttch2.posVec.Value(:);
thr.tether2.initAirNodePos.Value = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch2.posVec.Value(:);
thr.tether2.initGndNodeVel.Value = [0 0 0]';
thr.tether2.initAirNodeVel.Value = vhcl.initVelVecGnd.Value(:);
thr.tether2.diameter.Value      = 0.05;
thr.tether2.vehicleMass.Value   = vhcl.mass.Value;
thr.tether2.youngsMod.Value     = 3.8e9;
thr.tether2.dampingRatio.Value  = 0.05;
thr.tether2.dragCoeff.Value     = 0.5;
thr.tether2.density.Value       = 1300;

thr.tether3.numNodes.Value       = 5;
thr.tether3.initGndNodePos.Value = gndStn.thrAttch3.posVec.Value(:);
thr.tether3.initAirNodePos.Value = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch3.posVec.Value(:);
thr.tether3.initGndNodeVel.Value = [0 0 0]';
thr.tether3.initAirNodeVel.Value = vhcl.initVelVecGnd.Value(:);
thr.tether3.diameter.Value      = 0.05;
thr.tether3.vehicleMass.Value   = vhcl.mass.Value;
thr.tether3.youngsMod.Value     = 3.8e9;
thr.tether3.dampingRatio.Value  = 0.05;
thr.tether3.dragCoeff.Value     = 0.5;
thr.tether3.density.Value       = 1300;

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

%%
thr = thr.designTetherDiameter(vhcl,env);





