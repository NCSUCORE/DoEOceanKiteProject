%% Test script to test the floating ground station simulation and animation
clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(100,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('oneThrThreeAnchGndStn001');
% Winches
loadComponent('oneDOFWnchPTO');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('hurricaneSandyWave');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')

%% Environment IC's and dependant properties
env.water.setflowVec([1 0 0],'m/s')

% env.waterWave.waveParamMat.setValue([0,0,0,0;0,0,0,0],'')
%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([1,1.4,-20*pi/180,0*pi/180,125],'') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.setInitPosVecGnd([0 0 200],'m')
gndStn.setInitVelVecBdy([0 0 0],'m/s')
gndStn.setInitEulAng([0 0 0],'rad');
gndStn.initAngVelVec.setValue([0 0 0],'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.initPosVecGnd.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value)) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.initPosVecGnd.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value,env,thr,[ 1 0 0]);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.initPosVecGnd.Value);
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);

%%
% vhcl.animateSim(tsc,.4,...
%     'PathFunc',fltCtrl.fcnName.Value,...
%     'PlotTracer',true,...
%     'FontSize',24,...
%     'PowerBar',false,...
%     'PlotAxes',false,...
%     'TetherNodeForces',true,...
%     'TracerDuration',10,...
%     'GroundStation',gndStn,...
%     'GifTimeStep',1/30)
figure;
plotAnchThrTen;
figure;
tsc.gndStnPositionVec.plot

vhcl.animateSim(tsc,.1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',true,...
    'FontSize',24,...
    'PowerBar',false,...
    'PlotAxes',false,...
    'TetherNodeForces',false,...
    'TracerDuration',10,...
    'GroundStation',gndStn,...
    'GifTimeStep',1/30,...
    'SaveGif',false)