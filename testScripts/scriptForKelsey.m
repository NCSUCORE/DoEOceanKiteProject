% clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(500,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
loadComponent('pathFollowingCtrlForILC');
fltCtrl.rudderGain.setValue(0,'')
% SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('constEllipse');
loadComponent('constBoothLem');
% Ground station
loadComponent('pathFollowingGndStn');
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
env.water.setflowVec([1.5 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1.2,2.2,.36,0*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth
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
    (11/2)*norm([ 1 0 0 ])) % Initial speed

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
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);

%% Run Simulation
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);


%% Plot the kind of things that Kelsey might be interested in
% position of the center of mass in the ground frame
figure
tsc.positionVec.plot
figure
tsc.positionVec.plot3
figure
tsc.velocityVec.plot

%% Calculate some things that Kelsey might be interested in using different methods
groundSpeedMethod1 = tsc.velocityVec.mag; % this produces a timesignal object
groundSpeedMethod2 = squeeze(sqrt(sum(tsc.velocityVec.Data.^2,1))); % this produces a N by 1 matrix

%% Other signals that Kelsey might be interested in
% Angular velocity vector in the body frame
tsc.angularVel.plot
% Local apparent flow vectors in the body frame (x,y,z in rows, port wing,
% starboard wing, horizontal stabilizer, vertical stabilizer in columns)
tsc.vAppLclBdy.plot

%% Calculate p*b/2*v
p = tsc.angularVel.Data(1,1,:); % Angular velocity vector in the body frame
b = vhcl.portWing.halfSpan.Value; % The root-to-tip length of the port wing
% To calculate magintude of apparent flow at the center of mass, we have to
% back it out from logged data, because that's not actually a logged signal
% in the model (it is calculated, just not logged)
v = repmat(env.water.flowVec.Value(:),[1,1,numel(tsc.velocityVec.Time)])-tsc.velocityVec.Data;
v = sqrt(sum(v.^2,1));
x = (p(:).*b)./(2.*v(:));
plot(tsc.velocityVec.Time,x)

%% Also useful to check out methods(timesignal) to see all the math you can do with signals
