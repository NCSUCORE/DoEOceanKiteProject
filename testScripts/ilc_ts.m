%% Script to run ILC path optimization
clc;clear;close all
lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 2000*sqrt(lengthScaleFactor);
dynamicCalc = '';

% set_param('OCTModel','Profile','off')

%% Load components
% Flight Controller
loadComponent('pathFollowingForILC');
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
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('constXYZT');

%% Set basis parameters for high level controller
hiLvlCtrl.initBasisParams.setValue([0.6,1.1,20*pi/180,0,125],'[]') % Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([1,1.1,20*pi/180,0,125],'') % Lemniscate of Booth

%% Environment IC's and dependant properties
% env.water.nominal100mFlowVec.setValue([2 0 0]','m/s')
env.water.flowVec.setValue([2 0 0]','m/s')

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.initBasisParams.Value,... % Geometry parameters
    (11.5/2)*norm(env.water.flowVec.Value)) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value)
fltCtrl.winchSpeedIn.setValue(-norm(env.water.flowVec.Value)/3,'m/s');
fltCtrl.winchSpeedOut.setValue(norm(env.water.flowVec.Value)/3,'m/s');


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;

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
    squeeze(tsc.basisParams.Data(3,:,:)),...
    'DisplayName','$b_3$',...
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
stairs(squeeze(iterBasisParams.Data(3,:,:)),...
    'DisplayName','$b_3$',...
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

%% Plot Penalty Term in Performance Index
figure('Name','Penalty Term')
iterPenaltyTerm = resample(tsc.penaltyTerm,tsc.estGradient.Time);
subplot(2,1,1)
iterPenaltyTerm.plot('Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Penalty','Term'})

subplot(2,1,2)
stairs(iterPenaltyTerm.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Penalty','Term'})
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot the estimated gradient
figure('Name','Estimated Gradient')
numBP = numel(tsc.estGradient.Data(end,:));
for ii = 1:numBP
    subplot(numBP,1,ii)
    stairs(tsc.estGradient.Data(:,ii),...
        'LineWidth',1.5,...
        'Color','k')
    xlabel('Iteration Num')
    ylabel(sprintf('$\\frac{dJ}{db_%d}$',ii))
end
set(findall(gcf,'Type','axes'),'FontSize',18)

%% Plot J, grad, BP Breakdown
figure('Name','ILC Breakdown')
subplot(4,1,1)
stairs(iterPerf.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Performance','Index'})

subplot(4,1,2)
stairs(tsc.estGradient.Data(:,1),...
    'LineWidth',1.5,...
    'Color','k')
xlabel('Iteration Num')
ylabel(sprintf('$\\frac{dJ}{db_%d}$',1))

subplot(4,1,3)
stairs(squeeze(tsc.deltaBasisParamsSat.Data),...
    'LineWidth',1.5,...
    'Color','k')
xlabel('Iteration Num')
ylabel(sprintf('$\\delta b_%d$',1))


subplot(4,1,4)
stairs(squeeze(iterBasisParams.Data(1,:,:)),...
    'DisplayName','$b_7$',...
    'Color','k',...
    'LineStyle','--',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel('$b_1$')


set(findall(gcf,'Type','axes'),'FontSize',18)
linkaxes(findall(gcf,'Type','axes'),'x')


%% Save all the plots
saveAllPlots

%% Animate the results
vhcl.animateSim(tsc,1.5,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',false,...
    'NavigationVecs',false,...
    'Pause',false,...
    'SaveGif',false,...
    'GifTimeStep',0.05,...
    'ZoomIn',false,...
    'FontSize',24,...
    'PowerBar',true,...
    'ColorTracer',true);


