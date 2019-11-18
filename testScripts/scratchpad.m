<<<<<<< HEAD
%% Script to run ILC path optimization
clear;clc;close all
sim = SIM.sim;
sim.setDuration(7200,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('fig8ILC')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('CNAPsMitchell');


%% Environment IC's and dependant properties
% env.water.setflowVec([1 0 0],'m/s')
% 
%% Set basis parameters for high level controller
hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 200],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.initBasisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm(squeeze(env.water.flowVecTimeseries.Value.Data(1,1,4,:,1)))) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,squeeze(env.water.flowVecTimeseries.Value.Data(1,1,4,:,1)));
wnch.winch1.setMaxSpeed(inf,'m/s');

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.initBasisParams.Value,...
    gndStn.posVec.Value);


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;


%%
vhcl.animateSim(tsc,1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',false,...
    'ZoomIn',false,...
    'NavigationVecs',true,...
    'TangentCoordSys',false,...
    'VelocityVec',true,...
    'Pause',false,...
    'PlotTracer',true,...
    'LocalAero',false,...
    'SaveMPEG',false)



=======
close all
clear
clc
x = ENV.CNAPS('StartTime',8.6857e+05,'EndTime',8.6857e+05+3600*3+1);
% x.cropGUI
x.setXGridPoints(1:2,'m');
x.setYGridPoints(0:1:5,'m');

y = ENV.FAUTurb;
y.setIntensity(0.1,'');
y.setMinFreqHz(0.1,'Hz');
y.setMaxFreqHz(1,'Hz');
y.setNumMidFreqs(5,'');
y.setLateralStDevRatio(0.1,'');
y.setVerticalStDevRatio(0.1,'');
y.setSpatialCorrFactor(5,'');
y.process(x,'Verbose',true);
>>>>>>> 248da8d72499add21289f5c17841998b649a4375

