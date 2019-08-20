clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 6*sqrt(lengthScaleFactor);
flowspeed = 2;

SPOOLINGCONTROLLER = 'nonTrad';

dynamicCalc = '';

% ZERO FOR MITCHELLS CONTROL ALLOCATION, ONE OLD CONTROL ALLOCATION MATRIX
controlAllocationBit = 0;

%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('pathFollowingEnv');

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([.75,1,20*pi/180,0,175],'') % Lemniscate of Booth

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
    3*flowspeed) % Initial speed
vhcl.setAddedMISwitch(false,'');

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
% fltCtrl.velAng.kp.setValue(0.2,'(rad)/(rad)');
fltCtrl.velAng.kp.setValue(0,'(rad)/(rad)');
fltCtrl.velAng.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.velAng.kd.setValue(0,'(rad)/(rad/s)');

% fltCtrl.rollMoment.kp.setValue((1e4)/(10*pi/180),'(N*m)/(rad)')
fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(0,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

% fltCtrl.yawMoment.kp.setValue((4e4)/(2*pi/180),'(N*m)/(rad)');
fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');
fltCtrl.yawMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.yawMoment.kd.setValue(0,'(N*m)/(rad/s)');
fltCtrl.yawMoment.tau.setValue(0,'s');

fltCtrl.controlSigMax.upperLimit.setValue(30,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-30,'')

fltCtrl.startControl.setValue(3,'s');

% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)

fltCtrl.ctrlAllocMat.setValue([-1.1584         0         0;
                                1.1584         0         0;
                                0             -2.0981    0;
                                0              0         4.8067],'(deg)/(m^3)');

%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;

%% Plot the matrices
plotMatrixTimeseries(tsc.BMatrix)
plotMatrixTimeseries(tsc.CMatrix)

%% Plot things
% Desired And Achieved Moments
figure
subplot(3,1,1)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(1,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
title('Desired and Achieved Moments')
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,1),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Roll Moment [Nm]')
legend
subplot(3,1,2)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(2,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,2),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');xlabel('Time, [s]')
ylabel('Pitch Moment [Nm]')
legend
subplot(3,1,3)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(3,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,3),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, [s]')
ylabel('Yaw Moment [Nm]')
legend

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)


%% Plot control surf deflections
plotControlSurfaceDeflections

%% Plot yaw moment controller things
figure
subplot(3,1,1)
tsc.betaRad.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual')
grid on
hold on
tsc.betaSP.plot('LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Setpoint')
xlabel('Time, t [s]')
ylabel('$\beta$,[rad]')
legend
title('Yaw controller breakdown')

subplot(3,1,2)
plot(tsc.ctrlSurfDeflection.Time,...
    squeeze(tsc.ctrlSurfDeflection.Data(4,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k')
grid on
xlabel('Time, t [s]')
ylabel({'Rudder Defl [deg]'})

subplot(3,1,3)
tsc.yawMomCtrl.plot('LineWidth',1.5,'LineStyle','-','Color','k')
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,3),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, t [s]')
ylabel({'Yaw Mom.','Des. [Nm]'})
legend

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)

%% Compare decoupled quadratic solutions to linearized solutions
figure
for ii = 1:3
    subplot(3,1,ii)
    plot(tsc.deflVec.Time,tsc.deflVec.Data(ii,:),...
        'LineWidth',1.5,'LineStyle','-','Color','k',...
        'DisplayName','LinearSolution');
    grid on
    hold on
    plot(tsc.deflVec.Time,squeeze(tsc.deflVec2.Data(1,ii,:)),...
        'LineWidth',1.5,'LineStyle','--','Color','g',...
        'DisplayName','LinearSolution2');
    data = eval(sprintf('tsc.r%d1.Data',ii));
    plot(tsc.deflVec.Time,data,...
        'LineWidth',1.5,'LineStyle','-','Color','r',...
        'DisplayName',sprintf('r%d1',ii));
    data = eval(sprintf('tsc.r%d2.Data',ii));
    plot(tsc.deflVec.Time,data,...
        'LineWidth',1.5,'LineStyle','-','Color','b',...
        'DisplayName',sprintf('r%d2',ii));
    ylim([min(tsc.deflVec.Data(ii,:)) max(tsc.deflVec.Data(ii,:))]);
    xlabel('Time, [s]')
legend    
end
linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)

%% Plot tangent roll tracking
figure
tsc.tanRoll.plot('LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual Tan Roll');
grid on
hold on
tsc.tanRollDes.plot('LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired Tan Roll');
legend


%% Animate the results
vhcl.animateSim(tsc,0.1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',true,...
    'NavigationVecs',true)

