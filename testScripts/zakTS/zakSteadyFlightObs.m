%% Test script for Zak to control the kite model (developed from James' openLoopExp.m)
clear;clc;close all;
Simulink.sdi.clear
%% Set Test Parameters
thrLength = 3;
altitude = 1.5;
flwSpd = -0.01;
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
elev = atan2(altitude,thrLength); % Initial tether length/operating altitude/elevation angle
Tmax = 38; % kN - Max tether tension
h = 25*pi/180;  w = 100*pi/180; % rad - Path width/height
[a,b] = boothParamConversion(w,h); % Path basis parameters
%% Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = asin(altitude/thrLength);
loadComponent('pathFollowCtrlExp'); % Path-following controller with AoA control
% FLIGHTCONTROLLER = 'pathFollowingControllerExp';
FLIGHTCONTROLLER = 'hiToLoElevationControllerExp';
loadComponent('oneDoFGSCtrlBasic'); % Ground station controller
loadComponent('raftGroundStation'); % Ground station
loadComponent('winchManta'); % Winches
loadComponent('MantaTether'); % Manta Ray tether
loadComponent('ObsTether'); % Observer tether
loadComponent('realisticSensors') % Sensors
loadComponent('realisticSensorProcessing') % Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8_exp2'); % AR = 8; 8m span
%% Environment Properties
loadComponent('ConstXYZT'); % Environment
env.water.setflowVec([flwSpd 0 0],'m/s'); % m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2RotBandLin'; % Two turbines
    FLOWCALCULATION = 'rampSaturatedXYZT';
    rampSlope = 1; % flow speed ramp rate
    rampSlopeTow = 1; % tow speed ramp rate
%%  Set basis parameters for high level controller
loadComponent('constBoothLem');  % High level controller
hiLvlCtrl.basisParams.setValue([a,b,-el,0*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
theta = 30*pi/180;
T_tether = 100; % N
phi_max = 30*pi/180;
omega_kite = 2*pi/5; % rad/s
m_raft = 78.3; % kg
J_raft = 92.4; % kg*m^2
tow_length = 16;
tow_speed = 0.49;
end_time = tow_length/(tow_speed-flwSpd);
x_init = 4;
y_init = 0;
y_dot_init = 0;
psi_init = 0;
psi_dot_init = 0;
initGndStnPos = [x_init;y_init;3];
thrAttachInit = initGndStnPos;
%%  Vehicle Properties INITIAL CONDITIONS
% vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))
initPosKite = [x_init;y_init;0.01];
vhcl.initPosVecGnd.setValue(initPosKite,'m')
vhcl.initAngVelVec.setValue([0;0;0],'rad/s')
initVelKite = [0;0;0];
vhcl.initVelVecBdy.setValue(initVelKite,'m/s')
vhcl.initEulAng.setValue([pi;0;pi],'rad')
%%  Tether Properties
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
thr.tether1.initGndNodePos.setValue(initGndStnPos,'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([-tow_speed 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:)+[tow_speed 0 0]','m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
%thr.tether1.youngsMod.setValue(1E20,'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(.0076,'m');
thr.setNumNodes(8,'');
thr.tether1.setDragCoeff(1.8,'');
%%  Observer Tether Properties
Obsthr.tether1.initGndNodePos.setValue(initGndStnPos,'m');
Obsthr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
Obsthr.tether1.initGndNodeVel.setValue([tow_speed 0 0]','m/s');
Obsthr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:)+[tow_speed 0 0]','m/s');
Obsthr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
Obsthr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
%thr.tether1.youngsMod.setValue(1E20,'Pa');
Obsthr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
Obsthr.tether1.setDiameter(.0076,'m');
numObsThrNodes = 4;
Obsthr.setNumNodes(numObsThrNodes,'');
Obsthr.tether1.setDragCoeff(1.8,'');
ObsLinkFlowVecsConstant = [flwSpd*ones(1,numObsThrNodes-1);...
    zeros(1,numObsThrNodes-1); zeros(1,numObsThrNodes-1)];
%%  LAS
load('lineAngleSensor');
las.setThrInitAng([-el 0],'rad');
las.setInitAngVel([-0 0],'rad/s');
x = thr.tether1.initGndNodePos.Value(1)-thr.tether1.initAirNodePos.Value(1);
y = thr.tether1.initGndNodePos.Value(2)-thr.tether1.initAirNodePos.Value(2);
z = thr.tether1.initGndNodePos.Value(3)-thr.tether1.initAirNodePos.Value(3);
initThrAng = atan2(z,sqrt(x^2+y^2));
las.setThrInitAng([-initThrAng 0],'rad');
%% Observer params
accelBias = 0.0005.*[1 0 1]';
eulerBias = 0.*3.14159/180*[1 1 1]';
ObserverGains = ...zeros(10,4);
                [0 1 0.1 0;
                 0 0 0 0;
                 0 1 0.1 0;
                 0 0 0 0;
                 0 0 0 0;
                 0 0 0 0;
                 0 0 0 0;
                 0 0 0 0;
                 0 0 0 0;
                 0 0 0 0];
obsLASphiInit = las.initAng.Value(2);
obsLASphidotInit = las.initAngVel.Value(2);
obsLASthetaInit = las.initAng.Value(1);
obsLASthetadotInit = las.initAngVel.Value(1);
%% Environment Properties
% towVels = -tow_speed*[ones(1,numThrNodes-1);
%     zeros(1,numThrNodes-1);
%     zeros(1,numThrNodes-1)];
%%  Winches Properties
wnch.setTetherInitLength(vhcl,thrAttachInit,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(0,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,thrAttachInit);
fltCtrl.setPerpErrorVal(.25,'rad')
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.rollMoment.kp.setValue(50,'(N*m)/(rad)')
fltCtrl.rollMoment.kd.setValue(25,'(N*m)/(rad/s)')
fltCtrl.tanRoll.kp.setValue(.45,'(rad)/(rad)')
thr.tether1.dragEnable.setValue(1,'')
vhcl.hStab.setIncidence(-6,'deg');
vhcl.setBuoyFactor(.81,'')
bridlePosVec = [0.019;0;-0.072];
vhcl.setRBridle_LE(bridlePosVec,'m')
vhcl.setRCM_LE([0.077 0 0],'m');
%% Start Control
fltCtrl.startControl.setValue(end_time,'s')
startFlow = 0;
startTow = 0;
elSP = -5;
%% Open Loop Flow Speed
flowSpeedOpenLoop = -.03;
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
vhcl.animateSim(tsc,0.3,'GifTimeStep',0.05,'SaveGif',1==1)
%%  Save results
fname = fullfile('g:\','My Drive','RA','Simulation Data','2021-06-10','scratch');
save(fname,'tsc')