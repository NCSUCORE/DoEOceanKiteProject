clear
clc
format compact
% close all

cd(fileparts(mfilename('fullpath')));

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 1000*sqrt(lengthScaleFactor);

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'threeTetherThreeSurfaceCtrl';

%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createThreeTetherThreeSurfaceCtrlBus;

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
vhcl.setInitialCmPos([0;0;50],'m');
vhcl.setInitialCmVel([0;0;0],'m/s');
vhcl.setInitialEuler([0;1;0]*pi/180,'rad');
vhcl.setInitialAngVel([0;0;0],'rad/s');

% % % plot
% vhcl.plot
% vhcl.plotCoeffPolars


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
        (vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(ii).posVec.Value,'m');
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
ctrl.ySwitch.setValue(8,'m');
ctrl.rollAmp.setValue(25,'deg');

% set setpoints
timeVec = 0:0.1*sqrt(lengthScaleFactor):duration_s;
ctrl.altiSP.Value = timeseries(50*ones(size(timeVec)),timeVec);
ctrl.altiSP.Value.DataInfo.Units = 'm';

ctrl.pitchSP.Value = timeseries(10*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';

ctrl.yawSP.Value = timeseries(0*ones(size(timeVec)),timeVec);
ctrl.yawSP.Value.DataInfo.Units = 'deg';

%% scale 
% scale environment
env.scale(lengthScaleFactor,densityScaleFactor);
% scale vehicle
vhcl.scale(lengthScaleFactor,densityScaleFactor);
vhcl.calcFluidDynamicCoefffs;
% scale ground station
gndStn.scale(lengthScaleFactor,densityScaleFactor);
% scale tethers
thr.scale(lengthScaleFactor,densityScaleFactor);
% scale winches
wnch.scale(lengthScaleFactor,densityScaleFactor);
% scale controller
ctrl.scale(lengthScaleFactor);


%% Run the simulation
try
%     load_system('OCTModel')
%     set_param('OCTModel','Profile','off')
    simWithMonitor('OCTModel',2)
catch
%     load_system('OCTModel')
%     set_param('OCTModel','Profile','on')
    simWithMonitor('OCTModel',2)
end

plotAyaz

% fullKitePlot

