clear all;clc

scaleFactor = 1;
duration_s  = 500*sqrt(scaleFactor);

%% Set up simulation
VEHICLE = 'modVehicle000';
WINCH = 'winch000';
TETHERS = 'tether000';
GROUNDSTATION = 'groundStation000';
% PLANT = 'modularPlant';
ENVIRONMENT = 'constantUniformFlow';
CONTROLLER = 'pathFollowingController';

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

tetherLength = 200;
long = 0;
lat = pi/4;
tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
           -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
           cos(lat)            0          -sin(lat);];
path_init = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
ini_Rcm = [path_init(1);path_init(2);path_init(3);];
constantVelMag=7; %Constant velocity or Constant initial velocity
initVelAng = 45;%degrees
ini_Vcm= constantVelMag*tanToGr*[cosd(initVelAng);sind(initVelAng);0];

vhcl.setICs('InitPos',ini_Rcm,'InitVel',ini_Vcm,'InitEulAng',[0 7 0]*pi/180);

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
thr.tether1.diameter.Value      = 0.05;
thr.tether1.vehicleMass.Value   = vhcl.mass.Value;
thr.tether1.youngsMod.Value     = 3.8e9;
thr.tether1.dampingRatio.Value  = 0.05;
thr.tether1.dragCoeff.Value     = 0.5;
thr.tether1.density.Value       = 1300;

% Scale up/down
thr.scale(scaleFactor);


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
env = OCT.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.Value = [1 0 0];
% Scale up/down
env.scale(scaleFactor);

%% Set up controller
% % Create
% ctrl = CTR.controller;
% % add filtered PID controllers
% % FPID controllers are initialized to zero gains, 1s time const
% ctrl.add('FPIDNames',{'elevonPitch','elevonRoll'},...
%     'FPIDErrorUnits',{'deg','deg'},...
%     'FPIDOutputUnits',{'deg','deg'});
% 
% % add control allocation matrix (implemented as a simple gain)
% ctrl.add('GainNames',{'ctrlAllocMat'},...
%     'GainUnits',{''});
% 
% % add output saturation
% ctrl.add('SaturationNames',{'outputSat'});
% 
% % add setpoints
% ctrl.add('SetpointNames',{'pitchSP','rollSP'},...
%     'SetpointUnits',{'deg','deg'});
% 
% % Set the values of the controller parameters
% ctrl.ctrlAllocMat.Value = [1 0;0 1];
% 
% ctrl.elevonPitch.kp.Value = 12.5;
% ctrl.elevonPitch.ki.Value  = 1;
% 
% ctrl.elevonRoll.kp.Value = 15;
% ctrl.elevonRoll.kd.Value  = 15;
% 
% 
% % Calculate setpoints
% timeVec = 0:0.1:duration_s;
% ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
% 
% ctrl.rollSP.Value = timeseries(30*sign(sin(2*pi*timeVec/(100))),timeVec);
% ctrl.rollSP.Value.Data(timeVec<60) = 0;
% 
% % Scale up/down
% ctrl.scale(scaleFactor);

%%%%%%%%%Controller Params%%%%%%
aBooth=1;bBooth=1;latCurve=.5;

%2 deg/s^2 for an error of 1 radian
MOI_X=vhcl.Ixx.Value;
kpRollMom =2*MOI_X;
kdRollMom = 5*MOI_X;
tauRollMom = .01; 

maxBank=45*pi/180;
kpVelAng=maxBank/(pi/2); %max bank divided by large error
kiVelAng=kpVelAng/100;
kdVelAng=kpVelAng;
tauVelAng=.01;

controlAlMat = [1 0 0 ; 0 1 0 ; 0 0 1];
controlSigMax = 5*10^7;
MMAddBool = 1;
MMOverrideBool = 1;
constantVelBool = 1;

%% Run the simulation
sim('OCTModel')
% Run stop callback to plot everything
stopCallback




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Script to help implement the pathFollowingController with the modularized model
% % clear all;clc;
% 
% %% Define Variants an busses
% VEHICLE = 'modVehicle000';
% WINCH = 'winch000';
% TETHERS = 'tether000';
% GROUNDSTATION = 'groundStation000';
% PLANT = 'modularPlant';
% ENVIRONMENT = 'constantUniformFlow';
% CONTROLLER = 'pathFollowingController';
% 
% createPathFollowingControllerCtrlBus;
% %% Initialize Plant Parameters
% %scaling
% scaleFactor = 1;
% duration_s = 500*sqrt(scaleFactor);
% 
% %AeroStruct
% load('partDsgn1_lookupTables.mat')
% 
% aeroStruct(1).aeroCentPosVec(1) = -aeroStruct(1).aeroCentPosVec(1);
% aeroStruct(2).aeroCentPosVec(1) = -aeroStruct(2).aeroCentPosVec(1);
% 
% simParam = simParamClass;
% simParam.tether_param.tether_youngs.Value = simParam.tether_param.tether_youngs.Value/3;
% 
% %%
% tetherLength=200;
