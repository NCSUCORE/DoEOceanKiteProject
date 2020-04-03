% This is the section where the simulation parameters are set. Mainly the
clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(100,'s');

dynamicCalc = '';

lengthScaleFactor  = 0.1;
densityScaleFactor = 1;

%% Load components

%This is the section where all of the objects, simulation parameters and
%variant subsystem identifiers are loaded into the model

% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem');
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('pathFollowingVhclForComp');
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
    [.8,1.6,-20*pi/180,0*pi/180,125],...
    '[rad rad rad rad m]') % Lemniscate of Booth


%% Ground Station IC's and dependant properties

% this is where the ground station initial parameters are set. 
gndStn.setPosVec([0 0 200],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions

%This is where the vehicle initial conditions are aet.
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value)) % Initial speed

%% Tethers IC's and dependant properties'

% This is where the Kite tether initial conditions and parameter values are
% set
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
%this sets the initial tether length that the winch has spooled out
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);

%% Controller User Def. Parameters and dependant properties

% This is where the path geometry is set, (lemOfBooth is figure eight, race track, ellipse,ect...) 
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);

%% 
% fltCtrl.rollMoment.setKp(fltCtrl.rollMoment.kp.Value/10,fltCtrl.rollMoment.kp.Unit);
% fltCtrl.rollMoment.setKi(fltCtrl.rollMoment.ki.Value/10,fltCtrl.rollMoment.ki.Unit);
% fltCtrl.rollMoment.setKd(fltCtrl.rollMoment.kd.Value*10,fltCtrl.rollMoment.kd.Unit);


%% Scale everything down
fltCtrl.scale(lengthScaleFactor,densityScaleFactor);
gndStn.scale(lengthScaleFactor,densityScaleFactor);
hiLvlCtrl.scale(lengthScaleFactor,densityScaleFactor);
vhcl.scale(lengthScaleFactor,densityScaleFactor);
wnch.scale(lengthScaleFactor,densityScaleFactor);
thr.scale(lengthScaleFactor,densityScaleFactor);
env.scale(lengthScaleFactor,densityScaleFactor);
simParams.scale(lengthScaleFactor,densityScaleFactor);


%% Run the simulation
% this is where the simulation is commanded to run
simWithMonitor('OCTModel')

%this stores all of the logged signals from the model. To veiw, type
%tsc.signalname.data to view data, tsc.signalname.plot to plot etc.
tsc = signalcontainer(logsout);

%%
tsc.ctrlSurfDeflCmd.plot
% figure
% tsc.velocityVec.plot
% 
% %% this animates the simulation
vhcl.animateSim(tsc,1,'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',true,'FontSize',18)

