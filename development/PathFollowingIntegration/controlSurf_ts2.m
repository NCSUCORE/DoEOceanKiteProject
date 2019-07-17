clc;clear all
bdclose OCTModel
OCTModel

scaleFactor = 1;
duration_s  = 1000*sqrt(scaleFactor);
startControl= 1; %duration_s for 0 control signals. Does not apply to constant elevator angle

%% Set up simulation
VEHICLE = 'vehicle000';
WINCH = 'winch000';
TETHERS = 'tether000';
GROUNDSTATION = 'groundStation000';
ENVIRONMENT = 'constantUniformFlow';
CONTROLLER = 'pathFollowingController';

%% Create busses
createConstantUniformFlowEnvironmentBus
createPlantBus;
createOneTetherThreeSurfaceCtrlBus;

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
vhcl.aeroSurf1.CD.setValue(.02+vhcl.aeroSurf1.CD.Value,'');
vhcl.aeroSurf2.CD.setValue(.02+vhcl.aeroSurf2.CD.Value,'');
vhcl.aeroSurf3.CD.setValue(.02+vhcl.aeroSurf3.CD.Value,'');
vhcl.aeroSurf4.CD.setValue(.02+vhcl.aeroSurf4.CD.Value,'');

%IC's
tetherLength = 200;
velMag=6;
%pathParamVec=[.4,3*pi/8,0,tetherLength];%Circle
pathParamVec=[3*pi/8,1.5,.7854,0,tetherLength];%Lem
onpath = true;
if onpath
    pathParamStart = .6;
    [ini_Rcm,ini_Vcm]=swapablePath(pathParamStart,pathParamVec);
    ini_Vcm=velMag*ini_Vcm;
    [long,lat,~]=cart2sph(ini_Rcm(1),ini_Rcm(2),ini_Rcm(3));
    tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
               -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
               cos(lat)            0          -sin(lat);];
else
    long = -1.3*pi/8;
    lat = 1.7*pi/4;
    initVelAng = 90;%degrees
    tanToGr = [-sin(lat)*cos(long) -sin(long) -cos(lat)*cos(long);
               -sin(lat)*sin(long) cos(long)  -cos(lat)*sin(long);
               cos(lat)            0          -sin(lat);];
    ini_Rcm = tetherLength*[cos(long).*cos(lat);
                            sin(long).*cos(lat);
                            sin(lat);];
    ini_Vcm= velMag*tanToGr*[cosd(initVelAng);sind(initVelAng);0];
end

ini_pitch=atan2(ini_Vcm(3),sqrt(ini_Vcm(1)^2+ini_Vcm(2)^2));
ini_yaw=atan2(-ini_Vcm(2),-ini_Vcm(1));

[bodyToGr,~]=rotation_sequence([0 ini_pitch ini_yaw]);
bodyY_before_roll=bodyToGr*[0 1 0]';
tanZ=tanToGr*[0 0 1]';
ini_roll=(pi/2)-acos(dot(bodyY_before_roll,tanZ)/(norm(bodyY_before_roll)*norm(tanZ)));

ini_Vcm_body = [-velMag;0;0];
ini_eul=[ini_roll ini_pitch ini_yaw];
vhcl.setICs('InitPos',ini_Rcm,'InitVel',ini_Vcm_body,'InitEulAng',ini_eul);
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
vhcl.Ixz.setValue(81.87,'kg*m^2');
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
gndStn.dampCoeff.setValue(1,'(N*m)/(rad/s)'); 
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
thr.tether1.youngsMod.setValue(50e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
thr.tether1.setDiameter(0.0144,'m');

% thr.designTetherDiameter(vhcl,env);

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

%% Controller

pathCtrl = CTR.controller;

pathCtrl.add('SaturationNames',{'maxBank','controlSigMax'})

pathCtrl.maxBank.upperLimit.setValue(20*pi/180,'');
pathCtrl.maxBank.lowerLimit.setValue(-20*pi/180,'');

pathCtrl.controlSigMax.lowerLimit.setValue(-30,'');
pathCtrl.controlSigMax.upperLimit.setValue(30,'');

pathCtrl.add('FPIDNames',{'velAng','rollMoment'},...
    'FPIDErrorUnits',{'rad','rad'},...
    'FPIDOutputUnits',{'rad','N*m'})

pathCtrl.velAng.kp.setValue(pathCtrl.maxBank.upperLimit.Value/(100*(pi/180)),'(rad)/(rad)');
pathCtrl.velAng.kd.setValue(1.5*pathCtrl.velAng.kp.Value,'(rad)/(rad/s)');
pathCtrl.velAng.tau.setValue(.8,'s');

pathCtrl.rollMoment.kp.setValue(3e5,'(N*m)/(rad)'); %Units are wrong
pathCtrl.rollMoment.kd.setValue(.2*pathCtrl.rollMoment.kp.Value,'(N*m)/(rad/s)');
pathCtrl.rollMoment.tau.setValue (.8,'s');

pathCtrl.add('GainNames',{'ctrlAllocMat','perpErrorVal','pathParams','searchSize','constantPitchSig'},...
    'GainUnits',{'(deg)/(N*m)','rad','','rad','deg'}) %Not scaling here is dangerous

allMat = zeros(4,3);
allMat(1,1)=-1/(2*vhcl.aeroSurf1.GainCL.Value(2)*vhcl.aeroSurf1.refArea.Value*abs(vhcl.aeroSurf1.aeroCentPosVec.Value(2)));
allMat(2,1)=-1*allMat(1,1);
allMat(3,2)=-1/(vhcl.aeroSurf3.GainCL.Value(2)*vhcl.aeroSurf3.refArea.Value*abs(vhcl.aeroSurf3.aeroCentPosVec.Value(1)));
allMat(4,3)=1/(vhcl.aeroSurf4.GainCL.Value(2)*vhcl.aeroSurf4.refArea.Value*abs(vhcl.aeroSurf4.aeroCentPosVec.Value(1))); %Could be negative
pathCtrl.ctrlAllocMat.setValue(allMat,'(deg)/(N*m)');
% pathCtrl.ctrlAllocMat.setValue(eye(2),'(deg)/(N*m)');

pathCtrl.perpErrorVal.setValue(10*pi/180,'rad');
% pathCtrl.pathParams.setValue([1,1,pi/4,0,norm(vhcl.initPosVecGnd.Value)],''); % Lem Unscalable
pathCtrl.pathParams.setValue(pathParamVec,''); %Unscalable
pathCtrl.searchSize.setValue(.25,'rad');

pathCtrl.constantPitchSig.setValue(-25,'deg');

pathCtrl.scale(scaleFactor);

%% Run the simulation
MMAddBool = 0;
simWithMonitor('OCTModel')
parseLogsout;

%% Plot choices
errorSigsPlot = 1;
velMagsPlot = 1 ;
radialPosPlot = 0;
tetherTenMagPlot = 0;
alphaLocalPlot = 1;
clcdPlots = 0;
%% Plots
if errorSigsPlot == 1
figure;
subplot(1,3,1)
tsc.velAngleAdjustedError.plot
subplot(1,3,2)
tsc.tanRollDes.plot
deslims=ylim;
subplot(1,3,3)
tsc.tanRoll.plot
ylim(deslims)
end

if velMagsPlot 
figure
vels=tsc.velocityVec.Data(:,:,:);%[(1-tsc.velocityVec.Data(1,1,:)); tsc.velocityVec.Data(2:3,1,:)];
velmags = sqrt(sum((vels).^2,1));
plot(tsc.velocityVec.Time, squeeze(velmags));
xlabel('time (s)')
ylabel('ground frame velocity (m)')
end

if radialPosPlot 
figure
radialPos = sqrt(sum(tsc.positionVec.Data.^2,1));
plot(tsc.velocityVec.Time,squeeze(radialPos));
xlabel('time (s)')
ylabel('radial position/tether length (m)')
title("Radial Position")
end

if tetherTenMagPlot
figure
plot(tsc.FThrNetBdy.Time,squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1))));
xlabel('time (s)')
ylabel('Tether Tension Magnitude on Body (N)')
title("Tether Tension")
end

if alphaLocalPlot
    
figure
plot(tsc.alphaLocal.Time,squeeze(tsc.alphaLocal.Data(1,1,:)))
xlabel('time (s)')
ylabel('Alpha on the Left Wing')

end

if clcdPlots
figure;
subplot(2,2,1)
scatter(vhcl.aeroSurf1.CD.Value,vhcl.aeroSurf1.CL.Value)
xlabel("C_D")
ylabel("C_L")
title("half wing C_L vs C_D")

subplot(2,2,2)
scatter(vhcl.aeroSurf1.alpha.Value,vhcl.aeroSurf1.CL.Value)
xlabel("alpha (deg)")
ylabel("C_L")
title("half wing C_L vs alpha")

subplot(2,2,3)
scatter(vhcl.aeroSurf1.alpha.Value,vhcl.aeroSurf1.CD.Value)
xlabel("alpha (deg)")
ylabel("C_D")
title("half wing C_D vs alpha")

subplot(2,2,4)
plot(vhcl.aeroSurf1.alpha.Value,vhcl.aeroSurf1.CL.Value./vhcl.aeroSurf1.CD.Value)
xlabel("alpha")
ylabel('C_L \/ C_D')
title("Wing Lift to Drag Ratio vs alpha with 0 Deflection")
end
%% Animations/Plot Everything
% stopCallback
% animateSim
kiteAxesPlot