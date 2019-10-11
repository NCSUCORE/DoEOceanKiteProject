%% Script to run ILC path optimization
clc;clear;close all
lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 7200*sqrt(lengthScaleFactor);
dynamicCalc = '';

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
loadComponent('constXY_ZvarT_ADCP');


%% Environment IC's and dependant properties
env.water = env.water.setEndADCPTime(1.505e7,'s');
env.water = env.water.setStartADCPTime(1.48e7,'s');
env.water.plotMags
% env.water.setEndADCPTime(1.505e7,'s')
% env.water.setStartADCPTime(1.48e7,'s')

%% Set basis parameters for high level controller
hiLvlCtrl.initBasisParams.setValue([0.4,1.1,20*pi/180,45*pi/180,175],'[]') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.initBasisParams.Value,... % Geometry parameters
    (11.5/2)*norm(env.water.flowVecTSeries.Value.Data(:,30,1))) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr,env.water.flowVecTSeries.Value.Data(:,30,1));
wnch.winch1.setMaxSpeed(inf,'m/s')

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value)


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;

%% Plot basis parameters vs time and iteration number
iterBasisParams = resample(tsc.basisParams,tsc.estGradient.Time);
if strcmpi(getenv('username'),'M.Cobb')
    figure('Name','Basis Parameters',...
        'Position',1e3*[0.0010    0.0410    1.5360    0.7488]);
else
    figure('Name','Basis Parameters',...
        'Position',[-0.5625   -0.1824    0.5625    1.6694])
end
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
if strcmpi(getenv('username'),'M.Cobb')
    figure('Name','Basis Parameters',...
        'Position',1e3*[0.0010    0.0410    1.5360    0.7488]);
else
    figure('Name','Basis Parameters',...
        'Position',[-0.5625   -0.1824    0.5625    1.6694])
end
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
if strcmpi(getenv('username'),'M.Cobb')
    figure('Name','Basis Parameters',...
        'Position',1e3*[0.0010    0.0410    1.5360    0.7488]);
else
    figure('Name','Basis Parameters',...
        'Position',[-0.5625   -0.1824    0.5625    1.6694])
end
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
if strcmpi(getenv('username'),'M.Cobb')
    figure('Name','Basis Parameters',...
        'Position',1e3*[0.0010    0.0410    1.5360    0.7488]);
else
    figure('Name','Basis Parameters',...
        'Position',[-0.5625   -0.1824    0.5625    1.6694])
end
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
if strcmpi(getenv('username'),'M.Cobb')
    figure('Name','Basis Parameters',...
        'Position',1e3*[0.0010    0.0410    1.5360    0.7488]);
else
    figure('Name','Basis Parameters',...
        'Position',[-0.5625   -0.1824    0.5625    1.6694])
end
numBP = numel(tsc.estGradient.Data(end,:));
for ii = 1:numBP
    subplot(numBP,1,ii)
    stairs(tsc.estGradient.Data(:,ii),...
        'LineWidth',1.5,...
        'Color','k')
    xlabel('Iteration Num')
    ylabel(sprintf('$\\frac{dJ}{db_%d}$',ii))
    grid on
end
set(findall(gcf,'Type','axes'),'FontSize',18)
linkaxes(findall(gcf,'Type','axes'),'xy')

% Plot tether length vs time
figure('Name','Tether Length Tracking')
tsc.LThr.plot('DisplayName','Tether Length')
grid on
hold on
tsc.LThrSP.plot('DisplayName','Tether Length Setpoint')
legend
xlabel('Time, [s]')
ylabel('Length [m]')
title('Tether Length Tracking')
set(gca,'FontSize',18)


%% Plot flow speed at fuselage center
if strcmpi(getenv('username'),'M.Cobb')
    figure('Name','Flow Speed',...
        'Position',1e3*[0.0010    0.0410    1.5360    0.7488]);
else
    figure('Name','Basis Parameters',...
        'Position',[-0.5625   -0.1824    0.5625    1.6694])
end
plot(...
    tsc.vhclFlowVecs.Time,...
    squeeze(sqrt(sum(tsc.vhclFlowVecs.Data(:,end,:).^2,1))),...
    'Color','k','LineWidth',1.5)
grid on
xlabel('Time [s]')
ylabel('Flow Speed At CoM [m/s]')
set(gca,'FontSize',18)

%%
vhcl.animateSim(tsc,2,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PathPosition',false,...
    'NavigationVecs',false,...
    'Pause',false,...
    'PlotTracer',true)

