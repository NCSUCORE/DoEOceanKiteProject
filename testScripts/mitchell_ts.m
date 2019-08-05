close all;clear;clc;format compact

duration_s = 100;
lengthScaleFactor = 1;
densityScaleFactor = 1;

%% Pick Variants
VEHICLE          = 'vehicle000';
WINCH            = 'winch000';
TETHERS          = 'tether000';
GROUNDSTATION    = 'groundStation000';
ENVIRONMENT      = 'constantUniformFlow';
FLIGHTCONTROLLER = 'threeTetherThreeSurfaceCtrl';
GNDSTNCONTROLLER = 'oneDoF';

%% Create Busses
createConstantUniformFlowEnvironmentBus
createThreeTetherThreeSurfaceCtrlBus
oneDoF_bc
plant_bc

%% Load components
% Flight Controller
loadComponent('ayazThreeTetCtrl');
% Ground station controller
% N/A, No controller currently developed
% Ground station
loadComponent('ayazThreeTetGndStn');
% Winches 
loadComponent('threeWnch');
% Tether
loadComponent('ayazThreeTetTethers');
% Vehicle
loadComponent('ayazThreeTetVhcl');
% Environment
loadComponent('ayazThreeTetEnv');

%% Set initial conditions and dependent properties in the plant

% Vehicle
vhcl.setInitPosVecGnd([0 0 100],'m');
vhcl.setInitVelVecGnd([0 0 0],'m/s');
vhcl.setInitEulAng([0 7 0]*pi/180,'rad');
vhcl.setInitAngVelVec([0 0 0],'rad/s');

% Ground station
gndStn.setInitAngPos(0,'rad');
gndStn.setInitAngVel(0,'rad/s');

gndStn.thrAttch1.setPosVec(vhcl.thrAttchPts(1).posVec.Value,'m');
gndStn.thrAttch2.setPosVec(vhcl.thrAttchPts(2).posVec.Value,'m');
gndStn.thrAttch3.setPosVec(vhcl.thrAttchPts(3).posVec.Value,'m');

% Find air node positions in ground frame
airNodePos{1} = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts(1).posVec.Value(:);
airNodePos{2} = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts(2).posVec.Value(:);
airNodePos{3} = vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts(3).posVec.Value(:);

% Winches
wnch.winch1.setInitLength(norm(...
    airNodePos{1}-...
    gndStn.thrAttch1.posVec.Value(:)),'m');
wnch.winch1.setInitLength(norm(...
    airNodePos{2}-...
    gndStn.thrAttch2.posVec.Value(:)),'m');
wnch.winch1.setInitLength(norm(...
    airNodePos{3}-...
    gndStn.thrAttch3.posVec.Value(:)),'m');

% Tethers
thr.tether1.setInitGndNodePos(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether2.setInitGndNodePos(gndStn.thrAttch2.posVec.Value(:),'m');
thr.tether3.setInitGndNodePos(gndStn.thrAttch3.posVec.Value(:),'m');

thr.tether1.setInitAirNodePos(airNodePos{1},'m');
thr.tether2.setInitAirNodePos(airNodePos{1},'m');
thr.tether3.setInitAirNodePos(airNodePos{1},'m');

thr.tether1.setInitGndNodeVel([0 0 0]','m/s');
thr.tether2.setInitGndNodeVel([0 0 0]','m/s');
thr.tether3.setInitGndNodeVel([0 0 0]','m/s');

% thr.tether1.setInitAirNodeVel(vhcl.thrAttchPts(1).velVec.Value(:),'m/s');
% thr.tether2.setInitAirNodeVel(vhcl.thrAttchPts(2).velVec.Value(:),'m/s');
% thr.tether3.setInitAirNodeVel(vhcl.thrAttchPts(3).velVec.Value(:),'m/s');

thr.tether1.setVehicleMass(vhcl.mass.Value,vhcl.mass.Unit);
thr.tether2.setVehicleMass(vhcl.mass.Value,vhcl.mass.Unit);
thr.tether3.setVehicleMass(vhcl.mass.Value,vhcl.mass.Unit);

%% Set up environment
env.water.setVelVec([1 0 0],'m/s');

%% Set setpoints in the flight controller
timeVec = 0:0.1:duration_s;
fltCtrl.yawSP.setValue(zeros(size(timeVec)),'deg',timeVec);
fltCtrl.altiSP.setValue(vhcl.initPosVecGnd.Value(3),'m');
fltCtrl.ySwitch.setValue(3,'m');
fltCtrl.rollAmp.setValue(10,'deg');

% gndStn.struct('OCT.thrAttch').velVec



%% Run the simulation
sim('OCTModel')

stopCallback



