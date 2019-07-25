clear;
% clc
format compact
% close all

scaleFactor = 1/1;
duration_s  = 400*sqrt(scaleFactor);

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
% Scale up/down
env.scale(scaleFactor);

%% common parameters
numTethers = 3;
thrNumNodes = 2;
numTurbines = 2;

%% lifiting body
vhcl = OCT.vehicle_v2;

vhcl.setFluidDensity(env.water.density.Value,'kg/m^3')
vhcl.setNumTethers(numTethers,'');
vhcl.setNumTurbines(numTurbines,'');
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

vhcl.scale(scaleFactor);

% % % data file name
vhcl.setFluidCoeffsFileName('someFile4','');

% % % load/generate fluid dynamic data
vhcl.calcFluidDynamicCoefffs

% % % plot
% vhcl.plot
% vhcl.plotCoeffPolars


%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.setValue(3,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad/s)');
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
gndStn.thrAttch1.posVec.setValue([-0.8254   -5.0000         0]','m');
gndStn.thrAttch2.posVec.setValue([5.6000         0         0]','m');
gndStn.thrAttch3.posVec.setValue([-0.8254    5.0000         0]','m');
gndStn.freeSpnEnbl.setValue(true,'');


% Scale up/down
gndStn.scale(scaleFactor);

%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(3,'');
thr.setNumNodes(4,'');
thr.build;

% Set parameter values
thrDia = 0.0075;

thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(1).posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(4e9,'Pa');
thr.tether1.dampingRatio.setValue(0.05,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(false,'');
thr.tether1.setDiameter(thrDia,'m');

thr.tether2.initGndNodePos.setValue(gndStn.thrAttch2.posVec.Value(:),'m');
thr.tether2.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(2).posVec.Value,'m');
thr.tether2.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether2.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether2.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether2.youngsMod.setValue(4e9,'Pa');
thr.tether2.dampingRatio.setValue(0.05,'');
thr.tether2.dragCoeff.setValue(0.5,'');
thr.tether2.density.setValue(1300,'kg/m^3');
thr.tether2.setDragEnable(true,'');
thr.tether2.setSpringDamperEnable(true,'');
thr.tether2.setNetBuoyEnable(false,'');
thr.tether2.setDiameter(thrDia*sqrt(2),'m');

thr.tether3.initGndNodePos.setValue(gndStn.thrAttch3.posVec.Value(:),'m');
thr.tether3.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(3).posVec.Value,'m');
thr.tether3.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether3.initAirNodeVel.setValue(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether3.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether3.youngsMod.setValue(4e9,'Pa');
thr.tether3.dampingRatio.setValue(0.05,'');
thr.tether3.dragCoeff.setValue(0.5,'');
thr.tether3.density.setValue(1300,'kg/m^3');
thr.tether3.setDragEnable(true,'');
thr.tether3.setSpringDamperEnable(true,'');
thr.tether3.setNetBuoyEnable(false,'');
thr.tether3.setDiameter(thrDia,'m');

% thr.designTetherDiameter(vhcl,env);

% Scale up/down
thr.scale(scaleFactor);


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

% Scale up/down
wnch.scale(scaleFactor);


%% Set up controller
% Create
ctrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
ctrl.add('FPIDNames',{'tetherAlti','tetherPitch','tetherRoll','elevators','ailerons','rudder'},...
    'FPIDErrorUnits',{'m','rad','rad','deg','deg','deg'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s','deg','deg','deg'});

% add control allocation matrix (implemented as a simple gain)
ctrl.add('GainNames',{'ctrlSurfAllocationMat','thrAllocationMat'},...
    'GainUnits',{'',''});

% add output saturation
ctrl.add('SaturationNames',{'outputSat'});

% add setpoints
ctrl.add('SetpointNames',{'altiSP','pitchSP','rollSP','yawSP'},...
    'SetpointUnits',{'m','deg','deg','deg'});

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

ctrl.outputSat.upperLimit.setValue(30,'');
ctrl.outputSat.lowerLimit.setValue(-30,'');

% Calculate setpoints
timeVec = 0:0.1*sqrt(scaleFactor):duration_s;
ctrl.altiSP.Value = timeseries(50*ones(size(timeVec)),timeVec);
ctrl.altiSP.Value.DataInfo.Units = 'm';

ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';

Yswitch = 10*scaleFactor;
rollAmp = 20;
rollPeriod = 100*sqrt(scaleFactor);

ctrl.rollSP.Value = timeseries(20*sign(sin(2*pi*timeVec/(rollPeriod))),timeVec);
ctrl.rollSP.Value.Data(timeVec<0) = 0;
ctrl.rollSP.Value.DataInfo.Units = 'deg';

ctrl.yawSP.Value = timeseries(0*ones(size(timeVec)),timeVec);
ctrl.yawSP.Value.DataInfo.Units = 'deg';

% Scale up/down
ctrl = ctrl.scale(scaleFactor);

%% Run the simulation
try
    simWithMonitor('OCTModel',2)
catch
    simWithMonitor('OCTModel',2)
end
% Run stop callback to plot everything

plotAyaz

% fullKitePlot

