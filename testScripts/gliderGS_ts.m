% Test script for modeling the ground station as a glider.
% -Mitchell
clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(60,'s');

%% Load components

%This is the section where all of the objects, simulation parameters and
%variant subsystem identifiers are loaded into the model

% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% Ground station controller
loadComponent('motionlessGliderCtrl');
% High level controller
loadComponent('constBoothLem');
% Ground station
loadComponent('resizedKiteGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('fullScale1Thr');
% Environment
loadComponent('constXYZT');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')


%% Environment IC's and dependant properties

%if you are using constant flow, this is where the constant flow speed is
%set
env.water.setflowVec([1 0 0],'m/s')

%% Set basis parameters for high level controller

%This is where the path parameters are set. The first value dictates the
%width of the figure eight, the second determines the height, the third
%determines the center of the paths elevation angle, the four sets the path
%centers azimuth angle, the fifth is the initial tether length
hiLvlCtrl.basisParams.setValue(...
    [.8,1.6,20*pi/180,0*pi/180,125],...
    '[rad rad rad rad m]') % Lemniscate of Booth


%% Ground Station IC's and dependant properties

% this is where the ground station initial parameters are set. 
gndStn.setInitPosVecGnd([0 0 0],'m')
gndStn.setInitVelVecBdy([0 0 0],'m/s')
gndStn.setInitEulAng([0 0 0],'rad')
gndStn.setInitAngVelVec([0 0 0],'rad/s')

%% Set vehicle initial conditions

%This is where the vehicle initial conditions are aet.
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.initPosVecGnd.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value)) % Initial speed

%% Tethers IC's and dependant properties'

% This is where the Kite tether initial conditions and parameter values are
% set
thr.tether1.initGndNodePos.setValue(gndStn.thrAttchPts_B.posVec.Value(:)...
    +gndStn.initPosVecGnd.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
%this sets the initial tether length that the winch has spooled out
wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value,env,thr,env.water.flowVec.Value);

%% Controller User Def. Parameters and dependant properties

% This is where the path geometry is set, (lemOfBooth is figure eight, race track, ellipse,ect...) 
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.initPosVecGnd.Value);

%% Run the simulation
% this is where the simulation is commanded to run
sim('OCTModel')

%this stores all of the logged signals from the model. To veiw, type
%tsc.signalname.data to view data, tsc.signalname.plot to plot etc.
tsc = signalcontainer(logsout);

%%
vhcl.animateSim(tsc,1,'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',false,'FontSize',18)

