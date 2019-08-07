clear
clc
format compact
% close all

cd(fileparts(mfilename('fullpath')));

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 1000*sqrt(lengthScaleFactor);

%% Set up simulation
GNDSTNCONTROLLER      = 'oneDoF';

%% common parameters
numTethers = 3;
thrNumNodes = 2;
numTurbines = 2;

load('ayazThreeTetEnv.mat')
% Set Values
env.water.velVec.setValue([1 0 0]','m/s');

%% lifiting body
load('ayazThreeTetVhcl.mat')

% % % initial conditions
vhcl.setInitPosVecGnd([0;0;50],'m');
vhcl.setInitVelVecGnd([0;0;0],'m/s');
vhcl.setInitEulAng([0;1;0]*pi/180,'rad');
vhcl.setInitAngVelVec([0;0;0],'rad/s');

% % % plot
% vhcl.plot
% vhcl.plotCoeffPolars

% High Level Con
loadComponent('basicILC');


%% Ground Station
load('ayazThreeTetGndStn.mat')

gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Tethers
load('ayazThreeTetTethers.mat')

% set initial conditions
for ii = 1:3
    thr.(strcat('tether',num2str(ii))).initGndNodePos.setValue...
        (gndStn.(strcat('thrAttch',num2str(ii))).posVec.Value(:),'m');
    thr.(strcat('tether',num2str(ii))).initAirNodePos.setValue...
        (vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts(ii).posVec.Value,'m');
    thr.(strcat('tether',num2str(ii))).initGndNodeVel.setValue([0 0 0]','m/s');
    thr.(strcat('tether',num2str(ii))).initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
    thr.(strcat('tether',num2str(ii))).vehicleMass.setValue(vhcl.mass.Value,'kg');
    
end
% thr.designTetherDiameter(vhcl,env);

%% winches
load('ayazThreeTetWnch.mat');
% set initial conditions
wnch.setTetherInitLength(vhcl,env,thr);

%% Set up controller
load('ayazThreeTetCtrl.mat');

% switching values
fltCtrl.ySwitch.setValue(5,'m');
fltCtrl.rollAmp.setValue(20,'deg');

% set setpoints
timeVec = 0:0.1*sqrt(lengthScaleFactor):duration_s;
fltCtrl.altiSP.setValue(50*ones(size(timeVec)),'m',timeVec);
fltCtrl.pitchSP.setValue(10*ones(size(timeVec)),'deg',timeVec);
fltCtrl.yawSP.setValue(0*ones(size(timeVec)),'deg',timeVec);

%% scale 
% scale environment
env.scale(lengthScaleFactor,densityScaleFactor);
% scale vehicle
vhcl.scale(lengthScaleFactor,densityScaleFactor);
% scale ground station
gndStn.scale(lengthScaleFactor,densityScaleFactor);
% scale tethers
thr.scale(lengthScaleFactor,densityScaleFactor);
% scale winches
wnch.scale(lengthScaleFactor,densityScaleFactor);
% scale controller
fltCtrl.scale(lengthScaleFactor);

%% Run the simulation
% load_system('OCTModel')
% set_param('OCTModel','Profile','off')
simWithMonitor('OCTModel',2)

plotAyaz

% fullKitePlot

