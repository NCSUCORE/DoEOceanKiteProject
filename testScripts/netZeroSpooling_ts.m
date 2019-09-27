%% Script to run ILC path optimization
clc;clear;close all
lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 200*sqrt(lengthScaleFactor);
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('fig8ILC')
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
% loadComponent('constT_XYZvarZ_Ramp');
loadComponent('constXYZT');

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([1,1.1,20*pi/180,0,125 0.25 0.125],'') % Lemniscate of Booth

%% Environment IC's and dependant properties
% env.water.nominal100mFlowVec.setValue([2 0 0]','m/s')
env.water.flowVec.setValue([2 0 0]','m/s')

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    (11.5/2)*norm(env.water.flowVec.Value)) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
fltCtrl.winchSpeedIn.setValue(-norm(env.water.flowVec.Value)/3,'m/s');
fltCtrl.winchSpeedOut.setValue(norm(env.water.flowVec.Value)/3,'m/s');


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;


%% Animate the results
vhcl.animateSim(tsc,1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',false,...
    'NavigationVecs',false,...
    'Pause',false,...
    'SaveGif',true,...
    'GifTimeStep',0.05,...
    'ZoomIn',false,...
    'FontSize',24,...
    'PowerBar',false,...
    'ColorTracer',true);


