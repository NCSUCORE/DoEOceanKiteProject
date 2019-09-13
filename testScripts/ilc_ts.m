clc;clear;close all
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end

lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 2000*sqrt(lengthScaleFactor);

% SPOOLINGCONTROLLER = 'multiSpoolingController';
% SPOOLINGCONTROLLER = 'intraSpoolingController';
SPOOLINGCONTROLLER = 'intraSpoolNetZeroPI';
batteryMaxEnergy = inf;
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('firstBuildPathFollowing');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('fig8ILC')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
%loadComponent('pathFollowingEnv');

%% Set basis parameters for high level controller
hiLvlCtrl.initBasisParams.setValue([.75,1,20*pi/180,0,125],'[]') % Lemniscate of Booth

%% Environment IC's and dependant properties
flowspeed = 2;
flowType = 'constantUniformFlow';
variableFlow_bs

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.initBasisParams.Value,... % Geometry parameters
    (11.5/2)*flowspeed) % Initial speed
vhcl.setAddedMISwitch(false,'');

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

fltCtrl.winchSpeedIn.setValue(-2/3,'m/s')
fltCtrl.winchSpeedOut.setValue(2/3,'m/s')
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
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value)

fltCtrl.ctrlAllocMat.setValue([-1.1584         0         0;
                                1.1584         0         0;
                                0             -2.0981    0;
                                0              0         4.8067],'(deg)/(m^3)');
fltCtrl.elevatorReelInDef.setValue(23,'deg')

pitchKp = (1e5)/(2*pi/180);


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;

%% Plot things
%% Plot basis parameters vs time and iteration number
iterBasisParams = resample(tsc.basisParams,tsc.estGradient.Time);
figure('Name','Basis Parameters')
subplot(2,1,1)
plot(tsc.basisParams.Time,...
    squeeze(tsc.basisParams.Data(1,:,:)),...
    'DisplayName','$b_1$',...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
hold on
grid on
plot(tsc.basisParams.Time,...
    squeeze(tsc.basisParams.Data(2,:,:)),...
    'DisplayName','$b_2$',...
    'Color','k',...
    'LineStyle','--',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Basis','Parameters'})
legend

subplot(2,1,2)
stairs(squeeze(iterBasisParams.Data(1,:,:)),...
    'DisplayName','$b_1$',...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
hold on
grid on
stairs(squeeze(iterBasisParams.Data(2,:,:)),...
    'DisplayName','$b_2$',...
    'Color','k',...
    'LineStyle','--',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Basis','Parameters'})
legend 

set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot Performance Index
% Resample to plot against iteration index
figure('Name','Performance Index')
iterPerf = resample(tsc.perfIndx,tsc.estGradient.Time);
subplot(2,1,1)
iterPerf.plot('Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Performance','Index'})

subplot(2,1,2)
stairs(iterPerf.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Performance','Index'})
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot Mean Power
figure('Name','Mean Power')
iterPower = resample(tsc.meanPower,tsc.estGradient.Time);
subplot(2,1,1)
iterPower.plot('Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Mean','Power'})

subplot(2,1,2)
stairs(iterPower.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Mean','Power'})
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot Mean Distance To Path
figure('Name','Mean Ang To Path')
iterDist = resample(tsc.meanDistToPath,tsc.estGradient.Time);
subplot(2,1,1)
iterDist.plot('Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Mean Ang.','To Path, [rad]'})

subplot(2,1,2)
stairs(iterDist.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Mean Ang.','To Path, [rad]'})
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot initial and final path geometry
iterations = [1 5 10 24 25];
lineStyles = {'-','--','-.',':',':'};
pathFcn = @(x) eval(sprintf('%s(linspace(0,1,100),x)',fltCtrl.fcnName.Value));
iterBasisParams = resample(tsc.basisParams,tsc.estGradient.Time);
figure('Name','Path Geometry Comparison')
for ii = 1:length(iterations)
    iterNum = min(iterations(ii),numel(iterBasisParams.Time));
   pathPts = pathFcn(iterBasisParams.Data(:,:,iterNum));
   plot3(pathPts(1,:),pathPts(2,:),pathPts(3,:),...
       'Color','k',...
       'LineWidth',1.5,...
       'DisplayName',sprintf('Iteration %d',iterNum),...
       'LineStyle',lineStyles{ii})
   hold on
   grid on
end
legend
xlabel('X Position')
ylabel('Y Position')
zlabel('Z Position')
daspect([1 1 1])
view([63.256 32.88])
set(gca,'FontSize',24)

%% Plot tether length error in iteration domain


%% Save all the plots
saveAllPlots

%% Animate the results
vhcl.animateSim(tsc,1.25,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',false,...
    'NavigationVecs',false,...
    'Pause',false,...
    'SaveGif',true,...
    'GifTimeStep',0.075,...
    'ZoomIn',false)


