%% Test script for John to become familiar with the kite model 
clear;clc;%close all

%%  Set Physical Test Parameters
tetherLengths       = 400;
flowSpeeds          = .25;
lengthScaleFactors  = 0.8;
w = 90*pi/180;  h = 10*pi/180;
[a,b] = boothParamConversion(w,h);
a = 0.4;    b = 1.0;

%% Set up critical system parameters
simParams = SIM.simParams;
simParams.setDuration(2000,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% loadComponent('baselineSteadyLevelFlight');
fltCtrl.rudderGain.setValue(0,'')
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem');
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
% loadComponent('fiveNodeSingleTether');
loadComponent('pathFollowingTether');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')
% Vehicle
loadComponent('fullScale1thr');
% loadComponent('JohnfullScale1thr');
% Environment
loadComponent('ConstXYZT');

%% Scale everything to Manta Ray, except environment and sim params
fltCtrl.scale(lengthScaleFactors,1);
gndStn.scale(lengthScaleFactors,1);
hiLvlCtrl.scale(lengthScaleFactors,1);
vhcl.scale(lengthScaleFactors,1);
wnch.scale(lengthScaleFactors,1);
thr.scale(lengthScaleFactors,1);
env.scale(lengthScaleFactors,1);

%% Environment IC's and dependant properties
env.water.setflowVec([flowSpeeds 0 0],'m/s')

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue(...
    [a,b,20*pi/180,0*pi/180,tetherLengths],...
    '[rad rad rad rad m]') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.setVelVec([0 0 0],'m/s')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .05,...                                 % Initial path position
    PATHGEOMETRY,...                        % Name of path function
    hiLvlCtrl.basisParams.Value,...         % Geometry parameters
    gndStn.posVec.Value,...                 % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value))   % Initial speed
vhcl.setTurbDiam(0,'m');
% vhcl.setTurbDiam(.3772,'m');
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
% fltCtrl.setFirstSpoolLap(1000,'');
%% Hack things to make it run at lower flow speeds
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
thr.tether1.setDiameter(0.007,thr.tether1.diameter.Unit);
thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);

%% Run Simulation
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);

if vhcl.turbines.diameter.Value > 0
    save(sprintf('Manta_turb_D-%.4f_a-%.1f_b-%.1f.mat',vhcl.turbines.diameter.Value,a,b),'tsc')
elseif vhcl.turbines(1).diameter.Value == 0 && fltCtrl.firstSpoolLap.Value == 1
    save(sprintf('Manta_winch_a-%.1f_b-%.1f.mat',a,b),'tsc')
else
    save(sprintf('Manta_a-%.1f_b-%.1f.mat',a,b),'tsc')
end

%%  Animate Simulation 
filename = sprintf('Manta_SF%.1f_TL%d_FS%.2f.gif',lengthScaleFactors(1),tetherLengths(1),flowSpeeds(1));
vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
    'GifTimeStep',.1,'PlotTracer',true,'FontSize',12,...
    'Pause',false,'ZoomIn',false,'SaveGif',true,'GifFile',filename);


