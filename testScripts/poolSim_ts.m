% clear;clc;close all
clearvars tsc logsout

simLength = 300;
startPos = [0 0 0];
endPos = [1000 0 0];
simParams = SIM.simParams;
simParams.setDuration(simLength,'s');
dynamicCalc = '';

lengthScaleFactor = 1;
densityScaleFactor = 1;

%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
% loadComponent('pathFollowingCtrlForILC');
% loadComponent('newSpoolCtrl');
loadComponent('fullCycleCtrl');
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.dockedTetherLength.setValue(1,'m')
% SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('constEllipse');
loadComponent('constBoothLem');
% Ground station
loadComponent('prescribedGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')
% Vehicle
loadComponent('fullScale1thr');
% loadComponent('pathFollowingVhclForComp')

% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');

%% Environment IC's and dependant properties
env.water.setflowVec([0 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1.2,2.2,.36,180*pi/180,100],'[rad rad rad rad m]') % Lemniscate of Booth
%% Ground Station IC's and dependant properties

%gndStn.setInitPosVec([0 0 0],'m')
%gndStn.setVelVec([1.5 0 0],'m/s')
% gndStn.initAngPos.setValue(0,'rad');
% gndStn.initAngVel.setValue(0,'rad/s');
gndStn.setEulerAngVec([0 0 0],'rad');

%% Set position trajectory
time = [0 simParams.duration.Value];
posVecPoints = [startPos(:)'; endPos(:)'];
gndStn.setPosVecTrajectory(timesignal(timeseries(posVecPoints,time)),'m');
vGndStn = gndStn.posVecTrajectory.Value.diff;
vGndStnInit = vGndStn.getdatasamples(1);
%% Set vehicle initial conditions
% 
vhcl.setInitAngVelVec([0 0 0],'rad/s')
vhcl.setInitEulAng([0*pi/180 0*pi/180 180*pi/180],'rad')
initelev = 20;
initTL = fltCtrl.dockedTetherLength.Value; % m
vhcl.setInitPosVecGnd([-initTL*cosd(initelev) 0 initTL*sind(initelev)],'m')
vhcl.setInitVelVecBdy(rotation_sequence(vhcl.initEulAng.Value)*vGndStnInit(:),'m/s')
% 
% vhcl.setICsOnPath(...
%     .05,... % Initial path position
%     PATHGEOMETRY,... % Name of path function
%     hiLvlCtrl.basisParams.Value,... % Geometry parameters
%     gndStn.initPosVec.Value,... % Initial center point of path sphere
%     (11/2)*norm([ 1 0 0 ])) % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.initPosVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.initPosVec.Value,env,thr,env.water.flowVec.Value);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.initPosVec.Value);

%% Scale everything down
fltCtrl.scale(lengthScaleFactor,densityScaleFactor);
gndStn.scale(lengthScaleFactor,densityScaleFactor);
hiLvlCtrl.scale(lengthScaleFactor,densityScaleFactor);
vhcl.scale(lengthScaleFactor,densityScaleFactor);
wnch.scale(lengthScaleFactor,densityScaleFactor);
thr.scale(lengthScaleFactor,densityScaleFactor);
env.scale(lengthScaleFactor,densityScaleFactor);
simParams.scale(lengthScaleFactor,densityScaleFactor);

%% Run Simulation
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
%%
vhcl.animateSim(tsc,1,'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',true,'FontSize',18,'Pause',false)

