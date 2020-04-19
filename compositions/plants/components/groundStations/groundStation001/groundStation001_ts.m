%% Test script to test the floating ground station simulation and animation
clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(800,'s');
dynamicCalc = '';

%% Load components

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

% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
plant_bc
%% Environment IC's and dependant properties
env.water.setflowVec([1 0 0],'m/s')



%% Ground Station IC's and dependant properties
gndStn.setInitPosVecGnd([0 0 200],'m')
gndStn.setInitVelVecBdy([0 0 0],'m/s')
gndStn.setInitEulAng([0 0 0],'rad');
gndStn.initAngVelVec.setValue([0 0 0],'rad/s');





%%

simWithMonitor('groundStation001_th')
tsc = signalcontainer(logsout);


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
figure;
gndStn.animateGS(tsc,.1,...
    'FontSize',24,...
    'GroundStation',gndStn,...
    'GifTimeStep',1/30,...
    'SaveGif',true)