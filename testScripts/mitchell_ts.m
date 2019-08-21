clc;clear
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 100*sqrt(lengthScaleFactor);
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
    0.75,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    (11.5/2)*flowspeed) % Initial speed
vhcl.setAddedMISwitch(false,'');
vhcl.inertia.setValue(diag(diag(vhcl.inertia.Value)),'kg*m^2');

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
% fltCtrl.tanRoll.kp.setValue(0,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(1e-3,'s');

fltCtrl.rollMoment.kp.setValue((1e4)/(10*pi/180),'(N*m)/(rad)')
% fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)')
fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue((1e4)/(10*pi/180),'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(0.001,'s');

fltCtrl.yawMoment.kp.setValue((1e3)/(10*pi/180),'(N*m)/(rad)');
% fltCtrl.yawMoment.ki.setValue(0,'(N*m)/(rad*s)');
% fltCtrl.yawMoment.kd.setValue(0,'(N*m)/(rad/s)');
% fltCtrl.yawMoment.tau.setValue(0.001,'s');

fltCtrl.controlSigMax.upperLimit.setValue(300,'')
fltCtrl.controlSigMax.lowerLimit.setValue(-300,'')

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
parseLogsout;

%% Plot the matrices
plotMatrixTimeseries(tsc.BMatrix)
linkaxes(findall(gcf,'Type','axes'),'xy')
plotMatrixTimeseries(tsc.CMatrix)
linkaxes(findall(gcf,'Type','axes'),'xy')

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
subplot(4,1,1)
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

subplot(4,1,2)
plot(tsc.ctrlSurfDeflection.Time,...
    squeeze(tsc.ctrlSurfDeflection.Data(4,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k')
grid on
xlabel('Time, t [s]')
ylabel({'Rudder Defl [deg]'})

subplot(4,1,3)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidBdy.Data(3,:,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','Actual');
grid on
hold on
plot(tsc.desiredMoment.Time,tsc.desiredMoment.Data(:,3),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Desired');
xlabel('Time, t [s]')
legend

subplot(4,1,4)
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidPartBdy.Data(1,2,:)+tsc.MFluidPartBdy.Data(3,2,:)),...
    'LineWidth',1.5,'LineStyle','-','Color','k',...
    'DisplayName','AdverseYaw');
grid on
hold on
plot(tsc.MFluidBdy.Time,squeeze(tsc.MFluidPartBdy.Data(1,4,:)),...
    'LineWidth',1.5,'LineStyle','--','Color','r',...
    'DisplayName','Rudder Yaw');
legend

linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',16)

%% Compare different solution methods
figure
lineStyles = {'-','--','-.',':'};
for ii = 1:3
    subplot(3,1,ii)
    set(gca,'NextPlot','add')
    for jj = 1:4
        plot(tsc.(sprintf('d%d',jj)).Time,...
            tsc.(sprintf('d%d',jj)).Data(:,ii),...
            'LineWidth',1.5,...
            'DisplayName',sprintf('d%d',jj),...
            'LineStyle',lineStyles{jj});
    end
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
    'NavigationVecs',true,...
    'Pause',false)


