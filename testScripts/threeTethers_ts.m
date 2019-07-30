clear;
% clc
format compact
% close all

make_video = 0;

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 400*sqrt(lengthScaleFactor);

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation000';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'threeTetherThreeSurfaceCtrl';
VARIANTSUBSYSTEM = 'NNodeTether';


%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createThreeTetherThreeSurfaceCtrlBus;


%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.setValue([1 0 0],'m/s');

%% common parameters
numTethers = 3;
thrNumNodes = 2;
numTurbines = 2;

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

%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(3,'');
wnch.build;
% Set values
wnch.winch1.maxSpeed.setValue(1,'m/s');
wnch.winch1.timeConst.setValue(0.05,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');
wnch.winch1.initLength.setValue(50.01,'m');

wnch.winch2.maxSpeed.setValue(1,'m/s');
wnch.winch2.timeConst.setValue(0.05,'s');
wnch.winch2.maxAccel.setValue(inf,'m/s^2');
wnch.winch2.initLength.setValue(49.90,'m');

wnch.winch3.maxSpeed.setValue(1,'m/s');
wnch.winch3.timeConst.setValue(0.05,'s');
wnch.winch3.maxAccel.setValue(inf,'m/s^2');
wnch.winch3.initLength.setValue(50.01,'m');

% wnch = wnch.setTetherInitLength(vhcl,env,thr);

%% Set up controller
% Create
ctrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
ctrl.add('FPIDNames',{'tetherAlti','tetherPitch','tetherRoll','elevators','ailerons','rudder'},...
    'FPIDErrorUnits',{'m','rad','rad','deg','deg','deg'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s','deg','deg','deg'});

% add control allocation matrix (implemented as a simple gain)
ctrl.add('GainNames',{'ctrlSurfAllocationMat','thrAllocationMat','ySwitch','rollAmp'},...
    'GainUnits',{'','','m','deg'});

ctrl.ySwitch.setValue(5,'m');
ctrl.rollAmp.setValue(20,'deg');


% add output saturation
ctrl.add('SaturationNames',{'outputSat'});

% add setpoints
ctrl.add('SetpointNames',{'altiSP','pitchSP','yawSP'},...
    'SetpointUnits',{'m','deg','deg'});

% tether controllers
ctrl.tetherAlti.kp.setValue(0,'(m/s)/(m)');
ctrl.tetherAlti.ki.setValue(0,'(m/s)/(m*s)');
ctrl.tetherAlti.kd.setValue(0,'(m/s)/(m/s)');
ctrl.tetherAlti.tau.setValue(5,'s');

ctrl.tetherPitch.kp.setValue(2*1,'(m/s)/(rad)');
ctrl.tetherPitch.ki.setValue(0,'(m/s)/(rad*s)');
ctrl.tetherPitch.kd.setValue(4*1,'(m/s)/(rad/s)');
ctrl.tetherPitch.tau.setValue(0.1,'s');

ctrl.tetherRoll.kp.setValue(4*1,'(m/s)/(rad)');
ctrl.tetherRoll.ki.setValue(0,'(m/s)/(rad*s)');
ctrl.tetherRoll.kd.setValue(12*1,'(m/s)/(rad/s)');
ctrl.tetherRoll.tau.setValue(0.01,'s');

ctrl.thrAllocationMat.setValue([1 .5 -.5; 1 -.5 0; 1 .5 .5],'');

% Set the values of the controller parameters
ctrl.ailerons.kp.setValue(0,'(deg)/(deg)');
ctrl.ailerons.ki.setValue(0,'(deg)/(deg*s)');
ctrl.ailerons.kd.setValue(0,'(deg)/(deg/s)');
ctrl.ailerons.tau.setValue(0.5,'s');

ctrl.elevators.kp.setValue(0,'(deg)/(deg)'); % do we really want to represent unitless values like this?
ctrl.elevators.ki.setValue(0,'(deg)/(deg*s)');
ctrl.elevators.kd.setValue(0,'(deg)/(deg/s)'); % Likewise, do we want (deg*s)/(deg) or just s?
ctrl.elevators.tau.setValue(0.01,'s');

ctrl.rudder.kp.setValue(0,'(deg)/(deg)');
ctrl.rudder.ki.setValue(0,'(deg)/(deg*s)');
ctrl.rudder.kd.setValue(0,'(deg)/(deg/s)');
ctrl.rudder.tau.setValue(0.5,'s');

ctrl.ctrlSurfAllocationMat.setValue([-1 0 0; 1 0 0; 0 -1 0; 0 0 1],'');

ctrl.outputSat.upperLimit.setValue(0,'');
ctrl.outputSat.lowerLimit.setValue(0,'');

% Calculate setpoints
timeVec = 0:0.1*sqrt(lengthScaleFactor):duration_s;
ctrl.altiSP.Value = timeseries(50*ones(size(timeVec)),timeVec);
ctrl.altiSP.Value.DataInfo.Units = 'm';

ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';

ctrl.yawSP.Value = timeseries(0*ones(size(timeVec)),timeVec);
ctrl.yawSP.Value.DataInfo.Units = 'deg';

%% scale
env.scale(lengthScaleFactor,densityScaleFactor);

vhcl.scale(lengthScaleFactor,densityScaleFactor);
vhcl.calcFluidDynamicCoefffs;

gndStn.scale(lengthScaleFactor,densityScaleFactor);

thr.scale(lengthScaleFactor,densityScaleFactor);

wnch.scale(lengthScaleFactor,densityScaleFactor);

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
% Run stop callback to plot everything

% plotAyaz

% fullKitePlot

