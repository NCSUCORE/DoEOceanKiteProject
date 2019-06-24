% Script to test the origional model against the modularized model
% clear all;clc;


VEHICLE = 'modVehicle000';
WINCH = 'winch000';
TETHERS = 'tether000';
GROUNDSTATION = 'groundStation000';
PLANT = 'modularPlant';
ENVIRONMENT = 'constantUniformFlow';

load('partDsgn1_lookupTables.mat')

aeroStruct(1).aeroCentPosVec(1) = -aeroStruct(1).aeroCentPosVec(1);
aeroStruct(2).aeroCentPosVec(1) = -aeroStruct(2).aeroCentPosVec(1);

% Check that scaling works
scaleFactor = 1;
duration_s = 500*sqrt(scaleFactor);

% Initialize classes
ctrl = threeTetherThreeSurfaceCtrlClass;
simParam = simParamClass;

simParam.tether_param.tether_youngs.Value = simParam.tether_param.tether_youngs.Value/3;

% Set initial condition
ini_Rcm_o = [0 0 ctrl.setAltM.Value]';
ini_O_Vcm_o = [0 0 0]';
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
ctrl.scale(scaleFactor,1);
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

% Turn controller off/on
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

createOrigionalPlantBus;
createConstantUniformFlowEnvironmentBus;

ctrl.P_cs_mat.Value = [1 0;0 1];
ctrl.elevonPitchKp.Value = 10/2;
ctrl.elevonPitchKd.Value  = 20/2;
% 
ctrl.elevonRollKp.Value = 10;
ctrl.elevonRollKd.Value  = 20;


simParam.geom_param.MI.Value = simParam.geom_param.MI.Value*(1/4)^5;
simParam.geom_param.mass.Value = simParam.geom_param.mass.Value*(1/4)^3;

% Calculate setpoints
timeVec = 0:0.1:duration_s;
set_alt = timeseries(ctrl.setAltM.Value*ones(size(timeVec)),timeVec);
set_pitch = timeseries(15*ones(size(timeVec)),timeVec);
set_roll = timeseries(ctrl.setRollDeg.Value*ones(size(timeVec)),timeVec);
set_roll.Data = 30*sign(sin(2*pi*timeVec/(100)));
set_roll.Data(timeVec<60) = 0;
% set_roll.plot

switch numel(thr)
    case 3
        createThreeTetherThreeSurfaceCtrlBus;
        CONTROLLER = 'threeTetherThreeSurfaceCtrl';
        caseDescriptor = '3 Tethers';
        
    case 1
        createOneTetherThreeSurfaceCtrlBus;
        CONTROLLER = 'oneTetherThreeSurfaceCtrl';
        caseDescriptor = '1 Tether';
end

simParam.geom_param.MI.Value = simParam.geom_param.MI.Value*10;
thr(1).diameter         = simParam.tether_param.tether_diameter.Value(1)*2;


simWithMonitor('OCTModel')

% stopCallback