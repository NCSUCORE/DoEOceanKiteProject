clear all;clc
% bdclose OCTModelLateralFlight
% OCTModelLateralFlight

scaleFactor = 1;
duration_s  = 100*sqrt(scaleFactor);
startControl= 1; %duration_s for 0 control signals

%% Set up simulation
VEHICLE = 'modVehicle000';
WINCH = 'winch000';
TETHERS = 'tether000';
GROUNDSTATION = 'groundStation000';
% PLANT = 'modularPlant';
ENVIRONMENT = 'constantUniformFlow';
%CONTROLLER = 'pathFollowingController';
VARIANTSUBSYSTEM = 'twoNodeTether';

%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createPathFollowingControllerCtrlBus;

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.setValue([1 0 0],'m/s');
% Scale up/down
env.scale(scaleFactor);

%% Create Vehicle and Initial conditions
% Create
vhcl = OCT.vehicle;
vhcl.numTethers.setValue(1,'');
vhcl.numTurbines.setValue(2,'');
vhcl.build('partDsgn1_lookupTables.mat');
%IC's
tetherLength = 200;
long = 0;
lat = pi/8;
tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
           -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
           cos(lat)            0          -sin(lat);];
ini_Rcm = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
% path_init=tetherLength * boothSToGroundPos(.68*(2*pi),1,1,.5,0);
constantVelMag=34; %Constant velocity or Constant initial velocity
initVelAng = 270;%degrees
ini_Vcm= constantVelMag*tanToGr*[cosd(initVelAng);sind(initVelAng);0];

ini_pitch=atan2(ini_Vcm(3),sqrt(ini_Vcm(1)^2+ini_Vcm(2)^2));
ini_yaw=atan2(-ini_Vcm(2),-ini_Vcm(1));

[bodyToGr,~]=rotation_sequence([0 ini_pitch ini_yaw]);
bodyY_before_roll=bodyToGr*[0 1 0]';
tanZ=tanToGr*[0 0 1]';
ini_roll=(pi/2)-acos(dot(bodyY_before_roll,tanZ)/(norm(bodyY_before_roll)*norm(tanZ)));

ini_Vcm_body = [-constantVelMag;0;0];
ini_eul=[ini_roll ini_pitch ini_yaw];
vhcl.setICs('InitPos',ini_Rcm,'InitVel',ini_Vcm_body,'InitEulAng',ini_eul);

%% Vehicle Parameters
% Set Values
% vhcl.mass.Value = (8.9360e+04)*(1/4)^3;%0.8*(945.352);
% vhcl.Ixx.Value = 14330000*(1/4)^5;%(6.303e9)*10^-6;
% vhcl.Iyy.Value = 143200*(1/4)^5;%2080666338.077*10^-6;
% vhcl.Izz.Value = 15300000*(1/4)^5;%(8.32e9)*10^-6;
% vhcl.Ixy.Value = 0;
% vhcl.Ixz.Value = 0;%81875397*10^-6;
% vhcl.Iyz.Value = 0;
% vhcl.volume.Value = 111.7*(1/4)^3;%9453552023*10^-6;

vhcl.Ixx.setValue(6303,'kg*m^2');
vhcl.Iyy.setValue(2080.7,'kg*m^2');
vhcl.Izz.setValue(8320.4,'kg*m^2');
vhcl.Ixy.setValue(0,'kg*m^2');
vhcl.Ixz.setValue(0,'kg*m^2');
vhcl.Iyz.setValue(0,'kg*m^2');
vhcl.volume.setValue(0.9454,'m^3');
vhcl.mass.setValue(945.4,'kg'); %old=859.4
vhcl.centOfBuoy.setValue([0 0 0]','m');
vhcl.thrAttch1.posVec.setValue([0 0 0]','m');

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

% vhcl.aeroSurf1.aeroCentPosVec.Value(1) = -1.25;
% vhcl.aeroSurf2.aeroCentPosVec.Value(1) = -1.25;

% Scale up/down
vhcl.scale(scaleFactor);

%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.setValue(1,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad*s)');
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
gndStn.thrAttch1.posVec.setValue([0 0 0],'m');
gndStn.freeSpnEnbl.setValue(false,'');

% Scale up/down
gndStn.scale(scaleFactor);

%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(2,'');
thr.build;

% Set parameter values
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
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

% Scale up/down
thr.scale(scaleFactor);

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

% Scale up/down
wnch.scale(scaleFactor);

%% %%%%%%%%%Controller Params%%%%%%


%5 deg/s^2 for an error of 1 radian
MOI_X=vhcl.Ixx.Value;


pathCtrl = CTR.controller;
pathCtrl.add('FPIDNames',{'velAng','rollMoment'},...
    'FPIDErrorUnits',{'rad','N*m'},...
    'FPIDOutputUnits',{'rad','N*m'})

pathCtrl.rollMoment.kp.setValue(25000*(pi/180)*MOI_X,'(N*m)/(N*m)');
pathCtrl.rollMoment.kd.setValue(5000*(pi/180)*MOI_X,'(N*m*s)/(N*m)');
pathCtrl.rollMoment.tau.setValue (.01,'s');

pathCtrl.add('GainNames',{'ctrlAllocMat'},...
    'GainUnits',{''})

pathCtrl.add('SaturationNames',{'maxBank','controlSigMax'})

pathCtrl.maxBank.upperLimit.setValue(30*pi/180,'');
pathCtrl.maxBank.lowerLimit.setValue(-30*pi/180,'');
pathCtrl.controlSigMax.lowerLimit.setValue(-inf,'');
pathCtrl.controlSigMax.upperLimit.setValue(inf,'');

pathCtrl.velAng.kp.setValue(pathCtrl.maxBank.upperLimit.Value/(5*(pi/180)),'(rad)/(rad)');
pathCtrl.velAng.kd.setValue(pathCtrl.velAng.kp.Value*5,'(rad*s)/(rad)');
pathCtrl.velAng.tau.setValue(.01,'s');

pathCtrl.ctrlAllocMat.setValue(eye(3),'');

pathCtrl.add('SetpointNames',{'latSP','trim','perpErrorVal','aBooth','bBooth','latCurve'})
pathCtrl.latSP.Value = pi/8;
pathCtrl.trim.Value = 15;
pathCtrl.perpErrorVal.Value = 15*pi/180;
pathCtrl.aBooth.Value = 1;
pathCtrl.bBooth.Value = 1;
pathCtrl.latCurve.Value =.5;

%% Plant Modification Options
%Pick 0 or 1 to turn on:
MMAddBool = 1;
MMOverrideBool = 0;

%Pick 0 or 1 to turn on:
constantVelBool = 0;
constantNormVelBool = 0;

%Only meaningful if using constantNormVel
radialMotionBool = 1;

%% Run the simulation
sim('OCTModelLateralFlight')

%% Animate and Plot
% clear h;animateSim %Animate tether
% stopCallback %Plot Everything
parseLogsout;
figure;
subplot(1,3,1)
tsc.latErr.plot
subplot(1,3,2)
tsc.tanRollDes.plot
deslims=ylim;
subplot(1,3,3)
tsc.tanRoll.plot
ylim(deslims)
% pause(10)
kiteAxesPlot %Pretty plot