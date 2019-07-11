close all;clear;clc

duration_s = 1800;

%% Set up simulation
VEHICLE         = 'vehicle000';
WINCH           = 'winch000';
TETHERS         = 'tether000';
GROUNDSTATION   = 'groundStation001';
ENVIRONMENT     = 'constantUniformFlow';
CONTROLLER      = 'oneTetherThreeSurfaceCtrl';
VARIANTSUBSYSTEM = 'NNodeTether';

%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createOneTetherThreeSurfaceCtrlBus;

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
env.addFlow({'air'},'FlowDensities',1.225);
% Set Values
env.water.velVec.setValue([.5 0 0],'m/s');
env.air.velVec.setValue([1 0 0],'m/s');

%% Vehicle
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(2,'');
vhcl.build('partDsgn1_lookupTables.mat');

% Set Values
% vhcl.Ixx.setValue(34924.16,'kg*m^2');
% vhcl.Iyy.setValue(30487.96,'kg*m^2');
% vhcl.Izz.setValue(64378.94,'kg*m^2');
% vhcl.Ixy.setValue(0,'kg*m^2');
% vhcl.Ixz.setValue(731.66,'kg*m^2');
% vhcl.Iyz.setValue(0,'kg*m^2');
% vhcl.volume.setValue(7.40,'m^3');
% vhcl.mass.setValue(0.95*7404.24,'kg');

vhcl.Ixx.setValue(6303,'kg*m^2');
vhcl.Iyy.setValue(2080.7,'kg*m^2');
vhcl.Izz.setValue(8320.4,'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(0,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.volume.setValue(0.9454,'m^3');
vhcl.mass.setValue(859.4,'kg');

vhcl.centOfBuoy.setValue([0 0 0]','m');
vhcl.thrAttch1.posVec.setValue([0 0 0]','m');

vhcl.setICs('InitPos',[0 0 200],'InitEulAng',[0 7 0]*pi/180);

vhcl.turbine1.diameter.setValue(0,'m');
vhcl.turbine1.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine1.attachPtVec.setValue([-1.25 -5 0]','m');
vhcl.turbine1.powerCoeff.setValue(0.5,'');
vhcl.turbine1.dragCoeff.setValue(0.8,'');

vhcl.turbine2.diameter.setValue(0,'m');
vhcl.turbine2.axisUnitVec.setValue([1 0 0]','');
vhcl.turbine2.attachPtVec.setValue([-1.25  5 0]','m');
vhcl.turbine2.powerCoeff.setValue(0.5,'');
vhcl.turbine2.dragCoeff.setValue(0.8,'');

%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(5,'');
thr.build;

% Set parameter values
thr.tether1.initGndNodePos.setValue([0 0 1/2]','m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttch1.posVec.Value(:),'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(3.9e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');

thr.designTetherDiameter(vhcl,env);

%% Ground Station

% geometry of platform
platformVolume = 3.5;
objectHeight = platformVolume^(1/3);
% platform properties
buoyF = 1.5;
platformMass = 1000*platformVolume/buoyF;
platformInertiaMatrix = ((1/6)*platformMass*objectHeight^2).*eye(3);

% initial conditions
initPos = [0 0 100];
initVel = [0 0 0];
initEulAng = (pi/180).*[0 0 0];
initAngVel = [0 0 0];

CB2CMVec = [0 0 objectHeight/4];

% distance from previously calculated tether tension to center of mass
airTethDist = [0 0 objectHeight/2];

% Vectors from CoM to anchor tether attachment point, in body/platform frame
anchThrPltfrm(1).posVec = [0 1 0]';
anchThrPltfrm(2).posVec = [cosd(30) -.5 0]';
anchThrPltfrm(3).posVec = [-cosd(30) -.5 0]';

% Vector from ground fixed origin to tether attachment point, in ground frame
anchThrGnd(1).posVec = 100.*anchThrPltfrm(1).posVec;
anchThrGnd(2).posVec = 100.*anchThrPltfrm(2).posVec;
anchThrGnd(3).posVec = 100.*anchThrPltfrm(3).posVec;

% (theoretical) tether attachment points for a lifting body on platform
airbThrPltfrm(1).posVec = [0 0 1/2]';

% number of tethers
N = 5;

thrs = OCT.tethers;
thrs.numTethers.setValue(3,'');
thrs.numNodes.setValue(N,'')
thrs.build;

thrs.tether1.initGndNodePos.setValue(anchThrGnd(1).posVec,'m');
thrs.tether1.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(1).posVec(:),'m');
thrs.tether1.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether1.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether1.diameter.setValue(.05,'m');
thrs.tether1.youngsMod.setValue(3.8e9,'Pa');
thrs.tether1.dampingRatio.setValue(.05,'');
thrs.tether1.dragCoeff.setValue(.5,'');
thrs.tether1.density.setValue(1300,'kg/m^3');
thrs.tether1.vehicleMass.setValue(platformMass,'kg');
thrs.tether1.setDragEnable(true,'');
thrs.tether1.setSpringDamperEnable(true,'');
thrs.tether1.setNetBuoyEnable(true,'');
tetherLengths(1) = norm(thrs.tether1.initAirNodePos.Value-thrs.tether1.initGndNodePos.Value);

thrs.tether2.initGndNodePos.setValue(anchThrGnd(2).posVec,'m');
thrs.tether2.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(2).posVec(:),'m');
thrs.tether2.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether2.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether2.diameter.setValue(.05,'m');
thrs.tether2.youngsMod.setValue(3.8e9,'Pa');
thrs.tether2.dampingRatio.setValue(.05,'');
thrs.tether2.dragCoeff.setValue(.5,'');
thrs.tether2.density.setValue(1300,'kg/m^3');
thrs.tether2.vehicleMass.setValue(platformMass,'kg');
thrs.tether2.setDragEnable(true,'');
thrs.tether2.setSpringDamperEnable(true,'');
thrs.tether2.setNetBuoyEnable(true,'');
tetherLengths(2) = norm(thrs.tether2.initAirNodePos.Value-thrs.tether2.initGndNodePos.Value);

thrs.tether3.initGndNodePos.setValue(anchThrGnd(3).posVec,'m');
thrs.tether3.initAirNodePos.setValue(initPos(:)+rotation_sequence(initEulAng)*anchThrPltfrm(2).posVec(:),'m');
thrs.tether3.initGndNodeVel.setValue([0 0 0],'m/s');
thrs.tether3.initAirNodeVel.setValue(initVel,'m/s');
thrs.tether3.diameter.setValue(.05,'m');
thrs.tether3.youngsMod.setValue(3.8e9,'Pa');
thrs.tether3.dampingRatio.setValue(.05,'');
thrs.tether3.dragCoeff.setValue(.5,'');
thrs.tether3.density.setValue(1300,'kg/m^3');
thrs.tether3.vehicleMass.setValue(platformMass,'kg');
thrs.tether3.setDragEnable(true,'');
thrs.tether3.setSpringDamperEnable(true,'');
thrs.tether3.setNetBuoyEnable(true,'');
tetherLengths(3) = norm(thrs.tether3.initAirNodePos.Value-thrs.tether3.initGndNodePos.Value);

% ocean properties
waveAmp = 0;
wavePeriod = 1;
oceanDepth = 105;

%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build;
% Set values
wnch.winch1.maxSpeed.setValue(0.4,'m/s');
wnch.winch1.timeConst.setValue(1,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');

wnch = wnch.setTetherInitLength(vhcl,env,thr);

%% Set up controller
% Create
ctrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
ctrl.add('FPIDNames',{'elevators','ailerons'},...
    'FPIDErrorUnits',{'deg','deg'},...
    'FPIDOutputUnits',{'deg','deg'});

% add control allocation matrix (implemented as a simple gain)
ctrl.add('GainNames',{'ctrlAllocMat'},...
    'GainUnits',{''});

% add output saturation
ctrl.add('SaturationNames',{'outputSat'});

% add setpoints
ctrl.add('SetpointNames',{'pitchSP','rollSP'},...
    'SetpointUnits',{'deg','deg'});

% Set the values of the controller parameters
ctrl.elevators.kp.setValue(10,'(deg)/(deg)'); % do we really want to represent unitless values like this?
% ctrl.elevators.ki.Value = 2;
ctrl.elevators.kd.setValue(0.25,'(deg*s)/(deg)'); % Likewise, do we want (deg*s)/(deg) or just s?
ctrl.elevators.tau.setValue(0.05,'s');

ctrl.ailerons.kp.setValue(15,'(deg)/(deg)');
ctrl.ailerons.kd.setValue(15,'(deg*s)/(deg)');
ctrl.ailerons.tau.setValue(0.05,'s');

ctrl.outputSat.upperLimit.setValue(30,'');
ctrl.outputSat.lowerLimit.setValue(-30,'');

% Calculate setpoints
timeVec = 0:0.1:1000;
ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';
ctrl.rollSP.Value = timeseries(30*sign(sin(2*pi*timeVec/(100))),timeVec);
ctrl.rollSP.Value.Data(timeVec<60) = 0;
ctrl.rollSP.Value.DataInfo.Units = 'deg';

%% Run the simulation
try
    sim('OCTModel')
catch
end

stopCallback
parseLogsout

figure
tsc.subBodyPos.plot
legend('x','y','z')
figure
tsc.positionVec.plot
legend('x','y','z')