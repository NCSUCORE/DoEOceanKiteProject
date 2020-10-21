clear;
clc;
% close all;

cd(fileparts(mfilename('fullpath')));

simParams = SIM.simParams;
simParams.setDuration(300,'s');
dynamicCalc = '';
flowSpeed = 10;
thrLength = 500;
% rad - Mean elevation angle
el = 15*pi/180;    
% rad - Path width/height
w = 50*pi/180;          
h = 12*pi/180;  
% Path basis parameters
[a,b] = boothParamConversion(w,h);      

%% Load components
% Flight Controller
loadComponent('guidanceLawPathFollowingAir');
% loadComponent('pathFollowingCtrlForILC');

% Spooling controller
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem');
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('ayazFullScaleOneThrWinch');
% Tether
loadComponent('ayazAirborneThr');
% Sensors
loadComponent('idealSensors');
% Sensor processing
loadComponent('idealSensorProcessing');
% Vehicle
loadComponent('ayazAirborneVhcl');

% Environment
loadComponent('ayazAirborneFlow');

%% Environment IC's and dependant properties
env.water.setflowVec([flowSpeed 0 0],'m/s')

%% Set basis parameters for high level controller
% Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]');

%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .05,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value))   % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);

fltCtrl.elevatorReelInDef.setValue(0,'deg');
fltCtrl.rudderGain.setValue(0,'');
fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');

%% Run Simulation
simWithMonitor('OCTModel');
tsc = signalcontainer(logsout);

%%  Log Results
% dt = datestr(now,'mm-dd_HH-MM');
% % save file location
% 
% [status, msg, msgID] = mkdir(fullfile(fileparts(which('OCTProject.prj')),'outputs'));
% fpath = fullfile(fileparts(which('OCTProject.prj')),'outputs\');
% filename = sprintf(strcat('FS-%.1f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,w*180/pi,h*180/pi);
% save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams')


%%
vhcl.animateSim(tsc,0.5,...
    'PathFunc',fltCtrl.fcnName.Value,'pause',false,'plotTarget',true,...
    'SaveGif',false);
