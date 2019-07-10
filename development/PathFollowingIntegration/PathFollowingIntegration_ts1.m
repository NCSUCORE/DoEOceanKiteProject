clear all;clc
bdclose OCTModel
OCTModel

scaleFactor = 1;
duration_s  = 1000*sqrt(scaleFactor);
startControl= 15; %duration_s for 0 control signals

%% Set up simulation
VEHICLE = 'modVehicle000';
WINCH = 'winch000';
TETHERS = 'tether000';
GROUNDSTATION = 'groundStation000';
% PLANT = 'modularPlant';
ENVIRONMENT = 'constantUniformFlow';
CONTROLLER = 'pathFollowingController';
VARIANTSUBSYSTEM = 'NNodeTether';

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
long = -pi/4;
lat = pi/4;
tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
           -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
           cos(lat)            0          -sin(lat);];
ini_Rcm = tetherLength*[cos(long).*cos(lat);
         sin(long).*cos(lat);
         sin(lat);];
% path_init=tetherLength * boothSToGroundPos(.68*(2*pi),1,1,.5,0);
constantVelMag=19; %Constant velocity or initial velocity
initVelAng = 90;%degrees
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
thr.setNumNodes(5,'');
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

MOI_X=vhcl.Ixx.Value;
pathCtrl = CTR.controller;
pathCtrl.add('FPIDNames',{'velAng','rollMoment'},...
    'FPIDErrorUnits',{'rad','N*m'},...
    'FPIDOutputUnits',{'rad','N*m'})

pathCtrl.rollMoment.kp.setValue(5.5e5,'(N*m)/(N*m)'); %Units are wrong
pathCtrl.rollMoment.kd.setValue(5.5e4,'(N*m*s)/(N*m)');
pathCtrl.rollMoment.tau.setValue (.01,'s');

pathCtrl.add('GainNames',{'ctrlAllocMat'},...
    'GainUnits',{''}) %Not scaling here is dangerous

pathCtrl.add('SaturationNames',{'maxBank','controlSigMax'})

pathCtrl.maxBank.upperLimit.setValue(40*pi/180,'');
pathCtrl.maxBank.lowerLimit.setValue(-40*pi/180,'');
pathCtrl.controlSigMax.lowerLimit.setValue(-inf,'');
pathCtrl.controlSigMax.upperLimit.setValue(inf,'');

pathCtrl.velAng.kp.setValue(pathCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
pathCtrl.velAng.kd.setValue(pathCtrl.velAng.kp.Value,'(rad*s)/(rad)');
pathCtrl.velAng.tau.setValue(.01,'s');

pathCtrl.ctrlAllocMat.setValue(eye(3),'');

pathCtrl.add('SetpointNames',{'latSP','trim','perpErrorVal','pathParams','searchSize'})
pathCtrl.latSP.Value = pi/4;
pathCtrl.trim.Value = 15;
pathCtrl.perpErrorVal.Value = 3*pi/180;
pathCtrl.pathParams.Value = [1,1,pi/4,0,norm(vhcl.initPosVecGnd.Value)]; %lem
% pathCtrl.pathParams.Value = [.5,pi/2,0,norm(vhcl.initPosVecGnd.Value)]; %Circle
pathCtrl.searchSize.Value = pi/2;
%% Plant Modification Options
%Pick 0 or 1 to turn on:
MMAddBool = 1;
MMOverrideBool = 0;

%Pick 0 or 1 to turn on:
constantVelBool = 0;
constantNormVelBool = 0;

%Only meaningful if using constantNormVel
radialMotionBool = 0;

%% Run the simulation
% try
% disp("running the first time")
% sim('OCTModel')
% catch
% disp("second time")
% sim('OCTModel')
% end

simWithMonitor('OCTModel')

parseLogsout;

figure;
subplot(1,3,1)
tsc.velAngleAdjustedError.plot
subplot(1,3,2)
tsc.tanRollDes.plot
deslims=ylim;
subplot(1,3,3)
tsc.tanRoll.plot
ylim(deslims)

velmags = sqrt(sum(tsc.velocityVec.Data.^2,1));
figure;
plot(tsc.velocityVec.Time,squeeze(velmags));

radialPos = sqrt(sum(tsc.positionVec.Data.^2,1));
figure;
plot(tsc.velocityVec.Time,squeeze(radialPos));

lat = atan2(squeeze(tsc.positionVec.Data(3,:,:)),sqrt(squeeze(tsc.positionVec.Data(1,:,:)).^2+squeeze(tsc.positionVec.Data(2,:,:)).^2));
lat=lat*180/pi;
figure;
plot(tsc.velocityVec.Time,squeeze(lat));
% Run stop callback to plot everything
% kiteAxesPlot
% clear h
% animateSim
 %%
% stopCallback


 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Script to help implement the pathFollowingController with the modularized model
% % clear all;clc;
% 
% %% Define Variants an busses
% VEHICLE = 'modVehicle000';
% WINCH = 'winch000';
% TETHERS = 'tether000';
% GROUNDSTATION = 'groundStation000';
% PLANT = 'modularPlant';
% ENVIRONMENT = 'constantUniformFlow';
% CONTROLLER = 'pathFollowingController';
% 
% createPathFollowingControllerCtrlBus;
% %% Initialize Plant Parameters
% %scaling
% scaleFactor = 1;
% duration_s = 500*sqrt(scaleFactor);
% 
% %AeroStruct
% load('partDsgn1_lookupTables.mat')
% 
% aeroStruct(1).aeroCentPosVec(1) = -aeroStruct(1).aeroCentPosVec(1);
% aeroStruct(2).aeroCentPosVec(1) = -aeroStruct(2).aeroCentPosVec(1);
% 
% simParam = simParamClass;
% simParam.tether_param.tether_youngs.Value = simParam.tether_param.tether_youngs.Value/3;
% 
% %%
% tetherLength=200;
