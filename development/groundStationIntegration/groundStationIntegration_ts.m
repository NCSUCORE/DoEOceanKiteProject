clear
clearvars logsout
clc
format compact
close all
lengthScaleFactor = 1;
densityScaleFactor = 1;
duration_s = 500;

%% Set up simulation
VEHICLE          = 'vehicle000';
WINCH            = 'winch000';
TETHERS          = 'tether000';
GROUNDSTATION    = 'groundStation001';
ENVIRONMENT      = 'waveFlow';
FLIGHTCONTROLLER = 'threeTetherThreeSurfaceCtrl';
GNDSTNCONTROLLER = 'anchorTetherCtrl';

%% Create busses
createWaveFlowEnvironmentBus
createThreeTetherThreeSurfaceCtrlBus
createAnchorThetherCtrlBus
createPlantBus

%% Set up environment
env = ENV.env;
env.addFlow({'water'},{'waveFlow'},'FlowDensities',1000)
env.water.setDensity(1000,'kg/m^3');
env.water.setWavePeriod(20,'s');
env.water.setWaveAmplitude(1.5,'m');
env.water.setWaveHeading(90,'deg');
env.water.setOceanDepth(105,'m');
env.water.setPltfrmAppFlwMag(1,'m/s');
env.water.setFlowVelocityVec([1 0 0]','m/s');


%% Create floating platform ground station
buoyF = 1.5; % Buoyancy factor
dist = env.water.oceanDepth.Value-5; % Nominal depth of center of mass

gndStn = OCT.sixDoFStation;
gndStn.setVolume(3.5,'m^3');
gndStn.setMass(gndStn.volume.Value*(env.water.density.Value/buoyF),'kg');
gndStn.setInertiaMatrix(((1/6)*gndStn.mass.Value*gndStn.volume.Value^(2/3)).*eye(3),'kg*m^2');
gndStn.setCentOfBuoy([0 0 gndStn.volume.Value^(1/3)/2],'m');
gndStn.setDragCoefficient(0.8,'');

gndStn.addThrAttch('airThrAttchPt1',[0 0 ((gndStn.volume.Value)^(1/3))/2]);
gndStn.addThrAttch('airThrAttchPt2',[0 0 ((gndStn.volume.Value)^(1/3))/2]);
gndStn.addThrAttch('airThrAttchPt3',[0 0 ((gndStn.volume.Value)^(1/3))/2]);

gndStn.addThrAttch('bdyThrAttchPt1',[0 1 0]');
gndStn.addThrAttch('bdyThrAttchPt2',rotation_sequence([0 0  120])*gndStn.bdyThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('bdyThrAttchPt3',rotation_sequence([0 0 -120])*gndStn.bdyThrAttchPt1.posVec.Value(:));

gndStn.addThrAttch('gndThrAttchPt1',[100 0 0]');
gndStn.addThrAttch('gndThrAttchPt2',rotation_sequence([0 0  120])*gndStn.gndThrAttchPt1.posVec.Value(:));
gndStn.addThrAttch('gndThrAttchPt3',rotation_sequence([0 0 -120])*gndStn.gndThrAttchPt1.posVec.Value(:));

% Initial conditions
gndStn.setInitPos([0 0 100],'m');
gndStn.setInitEulAng([0 0 0],'rad');
gndStn.setInitVel([1e-3 0 0],'m/s');
gndStn.setInitAngVel([0 0 0],'rad/s');

% Tethers
gndStn.anchThrs.setNumNodes(2,'');
gndStn.anchThrs.setNumTethers(3,'');
gndStn.anchThrs.build;

% Tether 1 properties
gndStn.anchThrs.tether1.initGndNodePos.setValue(gndStn.gndThrAttchPt1.posVec.Value,'m'); % initial anchor node position
gndStn.anchThrs.tether1.initAirNodePos.setValue(gndStn.initPos.Value(:)+rotation_sequence(gndStn.initEulAng.Value)*gndStn.bdyThrAttchPt1.posVec.Value(:),'m'); % initial body node position in ground frame
gndStn.anchThrs.tether1.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
gndStn.anchThrs.tether1.initAirNodeVel.setValue(gndStn.initVel.Value,'m/s');  % initial velocity of body node
gndStn.anchThrs.tether1.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether1.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether1.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether1.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether1.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether1.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Tether 2 properties
gndStn.anchThrs.tether2.initGndNodePos.setValue(gndStn.gndThrAttchPt2.posVec.Value,'m'); % initial anchor node position
gndStn.anchThrs.tether2.initAirNodePos.setValue(gndStn.initPos.Value(:)+rotation_sequence(gndStn.initEulAng.Value)*gndStn.bdyThrAttchPt2.posVec.Value(:),'m'); % initial body node position in ground frame
gndStn.anchThrs.tether2.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
gndStn.anchThrs.tether2.initAirNodeVel.setValue(gndStn.initVel.Value,'m/s');  % initial velocity of body node
gndStn.anchThrs.tether2.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether2.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether2.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether2.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether2.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether2.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% Tether 3 properties
gndStn.anchThrs.tether3.initGndNodePos.setValue(gndStn.gndThrAttchPt3.posVec.Value,'m');
gndStn.anchThrs.tether3.initAirNodePos.setValue(gndStn.initPos.Value(:)+rotation_sequence(gndStn.initEulAng.Value)*gndStn.bdyThrAttchPt3.posVec.Value(:),'m'); % initial body node position in ground frame
gndStn.anchThrs.tether3.initGndNodeVel.setValue([0 0 0],'m/s');  % initial velocity of anchor node
gndStn.anchThrs.tether3.initAirNodeVel.setValue(gndStn.initVel.Value,'m/s');  % initial velocity of body node
gndStn.anchThrs.tether3.diameter.setValue(.05,'m');              % tether diameter
gndStn.anchThrs.tether3.youngsMod.setValue(3.8e9,'Pa');          % tether Young's Modulus
gndStn.anchThrs.tether3.dampingRatio.setValue(.05,'');           % zeta, damping ratio
gndStn.anchThrs.tether3.dragCoeff.setValue(.5,'');               % drag coefficient for intermediate nodes
gndStn.anchThrs.tether3.density.setValue(1300,'kg/m^3');         % tether density
gndStn.anchThrs.tether3.vehicleMass.setValue(gndStn.mass.Value,'kg'); % mass of platform for damping coefficient calculations

% anchor tether winches
anchWnch = OCT.winches;                                     % initiate winch creation
anchWnch.setNumWinches(gndStn.anchThrs.numTethers.Value,'');            % number of winches = number of tethers
anchWnch.build;                                             % builds winches in code

anchWnch.winch1.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
anchWnch.winch1.timeConst.setValue(.1,'s');                 % set time constant
anchWnch.winch1.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration
anchWnch.winch1.initLength.setValue(norm(gndStn.anchThrs.tether1.initAirNodePos.Value(:)-gndStn.anchThrs.tether1.initGndNodePos.Value(:)),'m')   % set initial length

anchWnch.winch2.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
anchWnch.winch2.timeConst.setValue(.1,'s');                 % set time constant
anchWnch.winch2.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration
anchWnch.winch2.initLength.setValue(norm(gndStn.anchThrs.tether2.initAirNodePos.Value(:)-gndStn.anchThrs.tether2.initGndNodePos.Value(:)),'m')   % set initial length

anchWnch.winch3.maxSpeed.setValue(0.4,'m/s');               % set maximum speed
anchWnch.winch3.timeConst.setValue(.1,'s');                 % set time constant
anchWnch.winch3.maxAccel.setValue(.5,'m/s^2')               % set maximum accleration
anchWnch.winch3.initLength.setValue(norm(gndStn.anchThrs.tether3.initAirNodePos.Value(:)-gndStn.anchThrs.tether3.initGndNodePos.Value(:)),'m')   % set initial length

%% Create lifting body
vhcl = OCT.vehicle_v2;

vhcl.setFluidDensity(env.water.density.Value,'kg/m^3')
vhcl.setNumTethers(3,'');
vhcl.setNumTurbines(2,'');
vhcl.setBuoyFactor(1.00,'');

% % % volume and inertias
vhcl.setVolume(945352023.474*1e-9,'m^3');
vhcl.setIxx(6.303080401918E+09*1e-6,'kg*m^2');
vhcl.setIyy(2080666338.077*1e-6,'kg*m^2');
vhcl.setIzz(8.320369733598E+09*1e-6,'kg*m^2');
vhcl.setIxy(0,'kg*m^2');
vhcl.setIxz(81875397.942*1e-6,'kg*m^2');
vhcl.setIyz(0,'kg*m^2');
vhcl.setCentOfBuoy([0;0;0],'m');
vhcl.setRbridle_cm([0;0;0],'m');

% % % wing
vhcl.setRwingLE_cm([-1;0;0],'m');
vhcl.setWingChord(1,'m');
vhcl.setWingAR(10,'');
vhcl.setWingTR(0.8,'');
vhcl.setWingSweep(2,'deg');
vhcl.setWingDihedral(0,'deg');
vhcl.setWingIncidence(0,'deg');
vhcl.setWingNACA('4412','');
vhcl.setWingClMax(1.75,'');
vhcl.setWingClMin(-1.75,'');

% % % H-stab
vhcl.setRhsLE_wingLE([6;0;0],'m');
vhcl.setHsChord(0.6,'m');
vhcl.setHsAR(8,'');
vhcl.setHsTR(0.8,'');
vhcl.setHsSweep(5,'deg');
vhcl.setHsDihedral(0,'deg');
vhcl.setHsIncidence(0,'deg');
vhcl.setHsNACA('0012','');
vhcl.setHsClMaxl(1.75,'');
vhcl.setHsClMin(-1.75,'');

% % % V-stab
vhcl.setRvs_wingLE([6;0;0],'m');
vhcl.setVsChord(0.6,'m');
vhcl.setVsSpan(2.5,'m');
vhcl.setVsTR(0.8,'');
vhcl.setVsSweep(10,'deg');
vhcl.setVsNACA('0012','');
vhcl.setVsClMax(1.75,'');
vhcl.setVsClMin(-1.75,'');

% % % initial conditions
vhcl.setInitialCmPos([0;0;50],'m');
vhcl.setInitialCmVel([0;0;0],'m/s');
vhcl.setInitialEuler([0;1;0]*pi/180,'rad');
vhcl.setInitialAngVel([0;0;0],'rad/s');

% % % data file name
vhcl.setFluidCoeffsFileName('someFile4','');

% % % load/generate fluid dynamic data
vhcl.calcFluidDynamicCoefffs

%% Tethers to lifting body
% Create
thr = OCT.tethers;
thr.setNumTethers(3,'');
thr.setNumNodes(2,'');
thr.build;

% Set parameter values
thrDia = 0.0075;

thr.tether1.setInitGndNodePos(gndStn.airThrAttchPt1.posVec.Value(:),'m');
thr.tether1.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(1).posVec.Value,'m');
thr.tether1.setInitGndNodeVel([0 0 0]','m/s');
thr.tether1.setInitAirNodeVel(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.setVehicleMass(vhcl.mass.Value,'kg');
thr.tether1.setYoungsMod(4e9,'Pa');
thr.tether1.setDampingRatio(0.05,'');
thr.tether1.setDragCoeff(0.5,'');
thr.tether1.setDensity(1300,'kg/m^3');
thr.tether1.setDiameter(thrDia,'m');

thr.tether2.setInitGndNodePos(gndStn.airThrAttchPt2.posVec.Value(:),'m');
thr.tether2.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(2).posVec.Value,'m');
thr.tether2.setInitGndNodeVel([0 0 0]','m/s');
thr.tether2.setInitAirNodeVel(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether2.setVehicleMass(vhcl.mass.Value,'kg');
thr.tether2.setYoungsMod(4e9,'Pa');
thr.tether2.setDampingRatio(0.05,'');
thr.tether2.setDragCoeff(0.5,'');
thr.tether2.setDensity(1300,'kg/m^3');
thr.tether2.setDiameter(thrDia*sqrt(2),'m');

thr.tether3.setInitGndNodePos(gndStn.airThrAttchPt3.posVec.Value(:),'m');
thr.tether3.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(3).posVec.Value,'m');
thr.tether3.setInitGndNodeVel([0 0 0]','m/s');
thr.tether3.setInitAirNodeVel(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether3.setVehicleMass(vhcl.mass.Value,'kg');
thr.tether3.setYoungsMod(4e9,'Pa');
thr.tether3.setDampingRatio(0.05,'');
thr.tether3.setDragCoeff(0.5,'');
thr.tether3.setDensity(1300,'kg/m^3');
thr.tether3.setDiameter(thrDia,'m');

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

%% Set up flight controller
% Create
fltCtrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
fltCtrl.add('FPIDNames',{'tetherAlti','tetherPitch','tetherRoll','elevators','ailerons','rudder'},...
    'FPIDErrorUnits',{'m','rad','rad','deg','deg','deg'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s','deg','deg','deg'});

% add control allocation matrix (implemented as a simple gain)
fltCtrl.add('GainNames',{'ctrlSurfAllocationMat','thrAllocationMat','ySwitch','rollAmp'},...
    'GainUnits',{'','','m','deg'});

fltCtrl.ySwitch.setValue(5,'m');
fltCtrl.rollAmp.setValue(20,'deg');


% add output saturation
fltCtrl.add('SaturationNames',{'outputSat'});

% add setpoints
fltCtrl.add('SetpointNames',{'altiSP','pitchSP','yawSP'},...
    'SetpointUnits',{'m','deg','deg'});

% tether controllers
fltCtrl.tetherAlti.kp.setValue(0,'(m/s)/(m)');
fltCtrl.tetherAlti.ki.setValue(0,'(m/s)/(m*s)');
fltCtrl.tetherAlti.kd.setValue(0,'(m/s)/(m/s)');
fltCtrl.tetherAlti.tau.setValue(5,'s');

fltCtrl.tetherPitch.kp.setValue(2*1,'(m/s)/(rad)');
fltCtrl.tetherPitch.ki.setValue(0,'(m/s)/(rad*s)');
fltCtrl.tetherPitch.kd.setValue(4*1,'(m/s)/(rad/s)');
fltCtrl.tetherPitch.tau.setValue(0.1,'s');

fltCtrl.tetherRoll.kp.setValue(4*1,'(m/s)/(rad)');
fltCtrl.tetherRoll.ki.setValue(0,'(m/s)/(rad*s)');
fltCtrl.tetherRoll.kd.setValue(12*1,'(m/s)/(rad/s)');
fltCtrl.tetherRoll.tau.setValue(0.01,'s');

fltCtrl.thrAllocationMat.setValue([1 .5 -.5; 1 -.5 0; 1 .5 .5],'');

% Set the values of the controller parameters
fltCtrl.ailerons.kp.setValue(0,'(deg)/(deg)');
fltCtrl.ailerons.ki.setValue(0,'(deg)/(deg*s)');
fltCtrl.ailerons.kd.setValue(0,'(deg)/(deg/s)');
fltCtrl.ailerons.tau.setValue(0.5,'s');

fltCtrl.elevators.kp.setValue(0,'(deg)/(deg)'); % do we really want to represent unitless values like this?
fltCtrl.elevators.ki.setValue(0,'(deg)/(deg*s)');
fltCtrl.elevators.kd.setValue(0,'(deg)/(deg/s)'); % Likewise, do we want (deg*s)/(deg) or just s?
fltCtrl.elevators.tau.setValue(0.01,'s');

fltCtrl.rudder.kp.setValue(0,'(deg)/(deg)');
fltCtrl.rudder.ki.setValue(0,'(deg)/(deg*s)');
fltCtrl.rudder.kd.setValue(0,'(deg)/(deg/s)');
fltCtrl.rudder.tau.setValue(0.5,'s');

fltCtrl.ctrlSurfAllocationMat.setValue([-1 0 0; 1 0 0; 0 -1 0; 0 0 1],'');

fltCtrl.outputSat.upperLimit.setValue(0,'');
fltCtrl.outputSat.lowerLimit.setValue(0,'');

% Calculate setpoints
timeVec = 0:0.1*sqrt(lengthScaleFactor):duration_s;
fltCtrl.altiSP.Value = timeseries(50*ones(size(timeVec)),timeVec);
fltCtrl.altiSP.Value.DataInfo.Units = 'm';

fltCtrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
fltCtrl.pitchSP.Value.DataInfo.Units = 'deg';

fltCtrl.yawSP.Value = timeseries(0*ones(size(timeVec)),timeVec);
fltCtrl.yawSP.Value.DataInfo.Units = 'deg';

%% Ground station controller
% initiate controller creation
gndCtrl = CTR.controller;
% create surge, sway, and heave controller
gndCtrl.add('FPIDNames',{'surge','sway','heave'},...
    'FPIDErrorUnits',{'m','m','m'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s'});
% create control allocation matrix
gndCtrl.add('GainNames',{'thrAllocationMat'},...
    'GainUnits',{'1/s'});
% create set points for each controller
gndCtrl.add('SetpointNames',{'surgeSP','swaySP','heaveSP'},...
    'SetpointUnits',{'m','m','m'});
% add output saturation
gndCtrl.add('SaturationNames',{'outputSat'});

gndCtrl.surge.kp.setValue(.05,'(m/s)/(m)');                        % proportional gain
gndCtrl.surge.kd.setValue(12*gndCtrl.surge.kp.Value,'(m/s)/(m/s)');   % derivative gain
gndCtrl.surge.tau.setValue(.1,'s');                                % time constant

gndCtrl.sway.kp.setValue(.05,'(m/s)/(m)');                         % proportional gain
gndCtrl.sway.kd.setValue(12*gndCtrl.sway.kp.Value,'(m/s)/(m/s)');     % derivative gain
gndCtrl.sway.tau.setValue(.1,'s');                                 % time constant

gndCtrl.heave.kp.setValue(.15,'(m/s)/(m)');                        % proportional gain
gndCtrl.heave.kd.setValue(12*gndCtrl.heave.kp.Value,'(m/s)/(m/s)');   % derivative gain
gndCtrl.heave.tau.setValue(.1,'s');                                % time constant

% set set points as a time series
timeV = 0:.1:duration_s;
gndCtrl.surgeSP.Value = timeseries(0*ones(size(timeV)),timeV);     % constant surge set point
gndCtrl.surgeSP.Value.DataInfo.Units = 'm';    % set units
gndCtrl.swaySP.Value = timeseries(0*ones(size(timeV)),timeV);      % constant sway set point
gndCtrl.surgeSP.Value.DataInfo.Units = 'm';    % set units
gndCtrl.heaveSP.Value = timeseries(100*ones(size(timeV)),timeV);   % constant heave set point
gndCtrl.surgeSP.Value.DataInfo.Units = 'm';    % set units

% tether control allocation matrix
% use zero vectors to turn individual controllers on and off (or set
% proportional gain to zero)
surgeVec = [0 -.5 .5]';                             % symmetric tether 2 and 3
surgeVec = surgeVec/norm(surgeVec);                 % normalize
% surgeVec = [0 0 0]';
swayNum = -dist + sqrt(dist^2+1-2*dist*cosd(60));   % geometric analysis for sway
swayVec = [-1 -swayNum -swayNum]';                  % symmetric tether 1 and tethers 2&3
swayVec = swayVec/norm(swayVec);                    % normalize
% swayVec = [0 0 0]';
heaveVec = [1 1 1]';                                % all tethers move together
heaveVec = heaveVec/norm(heaveVec);                 % normalize
% heaveVec = [0 0 0]';

% create matrix using vectors above
gndCtrl.thrAllocationMat.setValue([surgeVec,swayVec,heaveVec],'1/s')

gndCtrl.outputSat.upperLimit.setValue(1,'');
gndCtrl.outputSat.lowerLimit.setValue(-1,'');

%% run simulation
sim('OCTModel')
parseLogsout

%% Position
figure
subplot(3,1,1)
plot(tsc.posVecGnd.Time,squeeze(tsc.posVecGnd.Data(1,:,:)),...
    'Color','k','LineWidth',1.5)
ylabel('x, [m]')
grid on
title('Position')
subplot(3,1,2)
plot(tsc.posVecGnd.Time,squeeze(tsc.posVecGnd.Data(2,:,:)),...
    'Color','k','LineWidth',1.5)
ylabel('y, [m]')
grid on
subplot(3,1,3)
plot(tsc.posVecGnd.Time,squeeze(tsc.posVecGnd.Data(3,:,:)),...
    'Color','k','LineWidth',1.5)
ylabel('z, [m]')
grid on
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Euler Angles
figure
subplot(3,1,1)
plot(tsc.posVecGnd.Time,squeeze(tsc.eulerAngleVec.Data(1,:,:)))

grid on
title('Euler Angles')
subplot(3,1,2)
plot(tsc.posVecGnd.Time,squeeze(tsc.eulerAngleVec.Data(2,:,:)))
grid on
subplot(3,1,3)
plot(tsc.posVecGnd.Time,squeeze(tsc.eulerAngleVec.Data(3,:,:)))
grid on

%% Plot anchor tethers at first time step
timeVec = 0:1:tsc.posVecGnd.Time(end);
fileName = 'animation.gif';
for ii= 1:3
    tsc.anchThrNodeBusArry(ii).nodePositions = resample(tsc.anchThrNodeBusArry(ii).nodePositions,timeVec);
end
figure
h.thr1 = plot3(...
    tsc.anchThrNodeBusArry(1).nodePositions.Data(1,:,1),...
    tsc.anchThrNodeBusArry(1).nodePositions.Data(2,:,1),...
    tsc.anchThrNodeBusArry(1).nodePositions.Data(3,:,1),...
    'LineWidth',1.5,'Color','k','Marker','o');
xlabel('x position')
ylabel('y position')
zlabel('z position')
hold on
grid on
h.thr2 = plot3(...
    tsc.anchThrNodeBusArry(2).nodePositions.Data(1,:,1),...
    tsc.anchThrNodeBusArry(2).nodePositions.Data(2,:,1),...
    tsc.anchThrNodeBusArry(2).nodePositions.Data(3,:,1),...
    'LineWidth',1.5,'Color','k','Marker','o');
h.thr3 = plot3(...
    tsc.anchThrNodeBusArry(3).nodePositions.Data(1,:,1),...
    tsc.anchThrNodeBusArry(3).nodePositions.Data(2,:,1),...
    tsc.anchThrNodeBusArry(3).nodePositions.Data(3,:,1),...
    'LineWidth',1.5,'Color','k','Marker','o');
h.title = title(sprintf('Time = %.1f',timeVec(1)));
set(gca,'FontSize',24')

frame = getframe(gcf );
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);

imwrite(imind,cm,fileName,'gif', 'Loopcount',inf,'DelayTime',0.2);
for ii = 2:numel(timeVec)
    h.thr1.XData =  tsc.anchThrNodeBusArry(1).nodePositions.Data(1,:,ii);
    h.thr1.YData =  tsc.anchThrNodeBusArry(1).nodePositions.Data(2,:,ii);
    h.thr1.ZData =  tsc.anchThrNodeBusArry(1).nodePositions.Data(3,:,ii);
    
    h.thr2.XData =  tsc.anchThrNodeBusArry(2).nodePositions.Data(1,:,ii);
    h.thr2.YData =  tsc.anchThrNodeBusArry(2).nodePositions.Data(2,:,ii);
    h.thr2.ZData =  tsc.anchThrNodeBusArry(2).nodePositions.Data(3,:,ii);
    
    h.thr3.XData =  tsc.anchThrNodeBusArry(3).nodePositions.Data(1,:,ii);
    h.thr3.YData =  tsc.anchThrNodeBusArry(3).nodePositions.Data(2,:,ii);
    h.thr3.ZData =  tsc.anchThrNodeBusArry(3).nodePositions.Data(3,:,ii);
    
    h.title.String = sprintf('Time = %.1f',timeVec(ii));
    frame = getframe(gcf );
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,fileName,'gif','WriteMode','append');
    drawnow
end

