% Script to help implement the pathFollowingController with the modularized model
% clear all;clc;

%% Define Variants an busses
VEHICLE = 'modVehicle000';
WINCH = 'winch000';
TETHERS = 'tether000';
GROUNDSTATION = 'groundStation000';
PLANT = 'modularPlant';
ENVIRONMENT = 'constantUniformFlow';
CONTROLLER = 'pathFollowingController';

createPathFollowingControllerCtrlBus;
%% Initialize Plant Parameters
%scaling
scaleFactor = 1;
duration_s = 500*sqrt(scaleFactor);

%AeroStruct
load('partDsgn1_lookupTables.mat')

aeroStruct(1).aeroCentPosVec(1) = -aeroStruct(1).aeroCentPosVec(1);
aeroStruct(2).aeroCentPosVec(1) = -aeroStruct(2).aeroCentPosVec(1);

simParam = simParamClass;
simParam.tether_param.tether_youngs.Value = simParam.tether_param.tether_youngs.Value/3;

%%
tetherLength=200;
long = -.2;
lat = .56;
tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
           -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
           cos(lat)            0          -sin(lat);];
path_init = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
ini_Rcm_o = [path_init(1);path_init(2);path_init(3);];
velMag=7;
initVelAng = 45;%degrees
ini_O_Vcm_o= velMag*tanToGr*[cosd(initVelAng);sind(initVelAng);0];
%%%%%%%%%Controller Params%%%%%%
aBooth=1;bBooth=1;latCurve=.5;

%2 deg/s^2 for an error of 1 radian
MOI_X=simParam.geom_param.MI.Value(1,1);
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


% Set initial condition
% ini_Rcm_o = [0 0 200]';
% ini_O_Vcm_o = [0 0 0]';
ini_euler_ang = [0 0 0]';
ini_OwB = [0 0 0]';
initPlatformAngle = 0;
initPlatformAngularVel = 0;
simParam.setInitialConditions(...
    'Position',[10 0 ini_Rcm_o(3)-2],...
    'Velocity',ini_O_Vcm_o,...
    'EulerAngles',ini_euler_ang,...
    'AngularVelocity',ini_OwB,...
    'PlatformAngle',initPlatformAngle,...
    'PlatformAngularVelocity',initPlatformAngularVel);

% Scale up/down
simParam = simParam.scale(scaleFactor,1);

% Set up structure for tether for loop
thr(1).N                = simParam.N.Value;
thr(1).diameter         = simParam.tether_param.tether_diameter.Value(1);
thr(1).youngsMod        = simParam.tether_param.tether_youngs.Value;
thr(1).density          = simParam.tether_param.tether_density.Value+ simParam.env_param.density.Value;
thr(1).dragCoeff        = simParam.tether_param.CD_cylinder.Value;
thr(1).dampingRatio     = simParam.tether_param.damping_ratio.Value;
thr(1).fluidDensity     = simParam.env_param.density.Value;
thr(1).gravAccel        = simParam.env_param.grav.Value;
thr(1).vehicleMass      = simParam.geom_param.mass.Value;
thr(1).initVhclAttchPt  = simParam.initPosVec.Value +...
    rotation_sequence(simParam.initEulAng.Value)*simParam.tether_imp_nodes.R1n_cm.Value;
thr(1).initVhclAttchPt  = simParam.initPosVec.Value;
thr(1).initGndStnAttchPt = [0 0 0]';

% Set up structure for tether attachment points at ground station
gndStnMmtArms(1).arm = [0 0 0];

% Set up structure for tether attachment points on lifting body
lftBdyMmtArms(1).arm = [0 0 0];

% Set up structure for winches
winch.initLength = simParam.unstretched_l.Value(1);
winch.maxSpeed  = ctrl.winc_vel_up_lims.Value;
winch.timeConst = simParam.winch_time_const.Value;
winch.maxAccel = inf;



simParam.geom_param.MI.Value = simParam.geom_param.MI.Value*10;
thr(1).diameter         = simParam.tether_param.tether_diameter.Value(1)*2;


%%
simWithMonitor('OCTModel')

% stopCallback