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
GROUNDSTATION    = 'groundStation000';
ENVIRONMENT      = 'constantUniformFlow';
FLIGHTCONTROLLER = 'threeTetherThreeSurfaceCtrl';
GNDSTNCONTROLLER = 'oneDoF';

%% Create busses
createConstantUniformFlowEnvironmentBus
createThreeTetherThreeSurfaceCtrlBus;
createOneDoFGndStnCtrlBus;

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
% Set Values
env.water.velVec.setValue([1 0 0],'m/s');


%% lifiting body
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
gndStn.freeSpnEnbl.setValue(false,'');


%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(3,'');
thr.setNumNodes(2,'');
thr.build;

% Set parameter values
thrDia = 0.0075;

thr.tether1.setInitGndNodePos(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(1).posVec.Value,'m');
thr.tether1.setInitGndNodeVel([0 0 0]','m/s');
thr.tether1.setInitAirNodeVel(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether1.setVehicleMass(vhcl.mass.Value,'kg');
thr.tether1.setYoungsMod(4e9,'Pa');
thr.tether1.setDampingRatio(0.05,'');
thr.tether1.setDragCoeff(0.5,'');
thr.tether1.setDensity(1300,'kg/m^3');
thr.tether1.setSetDragEnable(true,'');
thr.tether1.setSetSpringDamperEnable(true,'');
thr.tether1.setSetNetBuoyEnable(false,'');
thr.tether1.setSetDiameter(thrDia,'m');

thr.tether2.setInitGndNodePos(gndStn.thrAttch2.posVec.Value(:),'m');
thr.tether2.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(2).posVec.Value,'m');
thr.tether2.setInitGndNodeVel([0 0 0]','m/s');
thr.tether2.setInitAirNodeVel(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether2.setVehicleMass(vhcl.mass.Value,'kg');
thr.tether2.setYoungsMod(4e9,'Pa');
thr.tether2.setDampingRatio(0.05,'');
thr.tether2.setDragCoeff(0.5,'');
thr.tether2.setDensity(1300,'kg/m^3');
thr.tether2.setSetDragEnable(true,'');
thr.tether2.setSetSpringDamperEnable(true,'');
thr.tether2.setSetNetBuoyEnable(false,'');
thr.tether2.setSetDiameter(thrDia*sqrt(2),'m');

thr.tether3.setInitGndNodePos(gndStn.thrAttch3.posVec.Value(:),'m');
thr.tether3.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAngBdy.Value)*vhcl.thrAttchPts(3).posVec.Value,'m');
thr.tether3.setInitGndNodeVel([0 0 0]','m/s');
thr.tether3.setInitAirNodeVel(vhcl.initVelVecGnd.Value(:),'m/s');
thr.tether3.setVehicleMass(vhcl.mass.Value,'kg');
thr.tether3.setYoungsMod(4e9,'Pa');
thr.tether3.setDampingRatio(0.05,'');
thr.tether3.setDragCoeff(0.5,'');
thr.tether3.setDensity(1300,'kg/m^3');
thr.tether3.setSetDragEnable(true,'');
thr.tether3.setSetSpringDamperEnable(true,'');
thr.tether3.setSetNetBuoyEnable(false,'');
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


%% Set up controller
% Create
ctrl = CTR.controller;
% add filtered PID controllers
% FPID controllers are initialized to zero gains, 1s time const
ctrl.add('FPIDNames',{'tetherAlti','tetherPitch','tetherRoll','elevators','ailerons','rudder'},...
    'FPIDErrorUnits',{'m','rad','rad','deg','deg','deg'},...
    'FPIDOutputUnits',{'m/s','m/s','m/s','deg','deg','deg'});

% add control allocation matrix (implemented as a simple gain)
ctrl.add('GainNames',{'ctrlSurfAllocationMat','thrAllocationMat','ySwitch','rollAmp'},...
    'GainUnits',{'','','m','deg'});

ctrl.ySwitch.setValue(5,'m');
ctrl.rollAmp.setValue(20,'deg');


% add output saturation
ctrl.add('SaturationNames',{'outputSat'});

% add setpoints
ctrl.add('SetpointNames',{'altiSP','pitchSP','yawSP'},...
    'SetpointUnits',{'m','deg','deg'});

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

ctrl.outputSat.upperLimit.setValue(0,'');
ctrl.outputSat.lowerLimit.setValue(0,'');

% Calculate setpoints
timeVec = 0:0.1*sqrt(lengthScaleFactor):duration_s;
ctrl.altiSP.Value = timeseries(50*ones(size(timeVec)),timeVec);
ctrl.altiSP.Value.DataInfo.Units = 'm';

ctrl.pitchSP.Value = timeseries(7*ones(size(timeVec)),timeVec);
ctrl.pitchSP.Value.DataInfo.Units = 'deg';

ctrl.yawSP.Value = timeseries(0*ones(size(timeVec)),timeVec);
ctrl.yawSP.Value.DataInfo.Units = 'deg';



%% Run first sim
try
    sim('OCTModel');
catch
end
tsc1 = parseLogsout;
clearvars logsout

%% Scaling
lengthScaleFactor = 0.01;
densityScaleFactor = 1;
duration_s = duration_s*sqrt(lengthScaleFactor);
% Scale up/down
env.scale(lengthScaleFactor,densityScaleFactor);
% Scale up/down
vhcl.scale(lengthScaleFactor,densityScaleFactor);
% Scale up/down
gndStn.scale(lengthScaleFactor,densityScaleFactor);
% Scale up/down
thr.scale(lengthScaleFactor,densityScaleFactor);
% Scale up/down
wnch.scale(lengthScaleFactor,densityScaleFactor);
% Scale up/down
ctrl = ctrl.scale(lengthScaleFactor);


%% Run second sim
try
    sim('OCTModel');
catch
end
tsc2 = parseLogsout;

%% Post Process
sigs = fieldnames(tsc2);
for ii = 1:length(sigs)
    try
        tsc2.(sigs{ii}).Time = tsc2.(sigs{ii}).Time/sqrt(lengthScaleFactor);
    catch
        warning('Skipping %s',sigs{ii})
    end
end

%%
figure
subplot(3,2,1)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(1,:,:)),...
    'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(1,:,:)),...
    'DisplayName','Roll, Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Roll, [rad]')

subplot(3,2,3)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(2,:,:)),...
    'DisplayName','Pitch, Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(2,:,:)),...
    'DisplayName','Pitch, Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Pitch, [rad]')

subplot(3,2,5)
plot(tsc1.eulerAngles.Time,squeeze(tsc1.eulerAngles.Data(3,:,:)),...
    'DisplayName','Yaw, Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.eulerAngles.Time,squeeze(tsc2.eulerAngles.Data(3,:,:)),...
    'DisplayName','Yaw, Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Yaw, [rad]')


subplot(3,2,2)
plot(tsc1.positionVec.Time,squeeze(tsc1.positionVec.Data(1,:,:))*lengthScaleFactor,...
    'DisplayName','Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.positionVec.Time,squeeze(tsc2.positionVec.Data(1,:,:)),...
    'DisplayName','Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('X Normed')

subplot(3,2,4)
plot(tsc1.positionVec.Time,squeeze(tsc1.positionVec.Data(2,:,:))*lengthScaleFactor,...
    'DisplayName','Nominal','LineWidth',1.5,'Color','k',...
    'LineStyle','-')
grid on
hold on
plot(tsc2.positionVec.Time,squeeze(tsc2.positionVec.Data(2,:,:)),...
    'DisplayName','Scaled','LineWidth',1.5,'Color','r',...
    'LineStyle','--')
xlabel('Normalized Time')
ylabel('Y Normed')

subplot(3,2,6)
plot(tsc1.positionVec.Time,squeeze(tsc1.positionVec.Data(3,:,:))*lengthScaleFactor,...
    'DisplayName','Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
grid on
hold on
plot(tsc2.positionVec.Time,squeeze(tsc2.positionVec.Data(3,:,:)),...
    'DisplayName','Scaled','LineWidth',1.5,'Color','r','LineStyle','--')
xlabel('Normalized Time')
ylabel('Z Normed')
set(findall(gcf,'Type','axes'),'FontSize',24)


%% Plot moments breakdown
% figure
% subplot(3,1,1)
% plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Fluid')
% 
% subplot(3,1,2)
% plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Fluid')
% 
% subplot(3,1,3)
% plot(tsc1.MFluidBdy.Time,squeeze(tsc1.MFluidBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MFluidBdy.Time,squeeze(tsc2.MFluidBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Fluid')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')
% 
% figure
% subplot(3,1,1)
% plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Turb')
% 
% subplot(3,1,2)
% plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Turb')
% 
% subplot(3,1,3)
% plot(tsc1.MTurbBdy.Time,squeeze(tsc1.MTurbBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MTurbBdy.Time,squeeze(tsc2.MTurbBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Turb')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')
% 
% figure
% subplot(3,1,1)
% plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Thr')
% 
% subplot(3,1,2)
% plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Thr')
% 
% subplot(3,1,3)
% plot(tsc1.MThrNetBdy.Time,squeeze(tsc1.MThrNetBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MThrNetBdy.Time,squeeze(tsc2.MThrNetBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Thr')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')
% 
% figure
% subplot(3,1,1)
% plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(1,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(1,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mx Buoy')
% 
% subplot(3,1,2)
% plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(2,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(2,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('My Buoy')
% 
% subplot(3,1,3)
% plot(tsc1.MBuoyBdy.Time,squeeze(tsc1.MBuoyBdy.Data(3,:,:))*scaleFactor^4,...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','k','LineStyle','-')
% grid on
% hold on
% plot(tsc2.MBuoyBdy.Time,squeeze(tsc2.MBuoyBdy.Data(3,:,:)),...
%     'DisplayName','Roll, Nominal','LineWidth',1.5,'Color','r','LineStyle','--')
% ylabel('Mz Buoy')
% 
% linkaxes(findall(gcf,'Type','axes'),'x')