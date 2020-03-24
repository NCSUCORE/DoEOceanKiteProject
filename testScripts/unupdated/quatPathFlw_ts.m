% Test script to test the implementation of quaternoins for the path
% following controller
clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 100*sqrt(lengthScaleFactor);
flowspeed = 0.5;

SPOOLINGCONTROLLER = 'nonTrad';

dynamicCalc = '';


%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('varRadiusBooth')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('pathFollowingEnv');

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([.75,1,20*pi/180,0,125],'') % Lemniscate of Booth

%% Environment IC's and dependant properties
env.water.velVec.setValue([flowspeed 0 0],'m/s');

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    (11.5/2)*flowspeed) % Initial speed
vhcl.setAddedMISwitch(true,'');
% vhcl.inertia.setValue(diag(diag(vhcl.inertia.Value)),'kg*m^2');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');


%% winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');

% Spooling/tether control parameters
fltCtrl.outRanges.setValue( [...
    0           0.1250;
    0.3450      0.6250;
    0.8500      1.0000;],'');

fltCtrl.winchSpeedIn.setValue(0,'m/s')
fltCtrl.winchSpeedOut.setValue(0,'m/s')
fltCtrl.traditionalBool.setValue(1,'')

% Control surface parameters
fltCtrl.tanRoll.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue((1e4)/(10*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((1e4)/(10*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(0,'s');

% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)

fltCtrl.ctrlAllocMat.setValue([-1.1584         0         0;
                                1.1584         0         0;
                                0             -2.0981    0;
                                0              0         4.8067],'(deg)/(m^3)');
fltCtrl.elevatorReelInDef.setValue(0,'deg')

pitchKp = (1e5)/(2*pi/180);


%% Run the simulation
simWithMonitor('OCTModel')
tscEul = parseLogsout;

dynamicCalc = 'Quaternions';

simWithMonitor('OCTModel')
tscQuat = parseLogsout;

%% Plot things
tscEul.tanRollDes.plot('DisplayName','Tan Roll Des, Eul')
grid on
hold on
tscQuat.tanRollDes.plot('DisplayName','Tan Roll Des, Quat')
legend

edit plotEulerAngles.m
