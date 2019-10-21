% Test script for Mitchell's Control Systems Technology (CST) journal
% paper (tenatively, the exact journal might change).  This test script
% runs ILC-based path optimization for the neutrally buoyant MHK system
% under
% 1) constant flow speed, and 
% 2) variable flow speed, implemented using the CNAPS+Turbulence model.
% It generates all plots included in the paper.


%% ------------------------------------------------------------------------
% CONSTANT FLOW ILC
% -------------------------------------------------------------------------

%% Preliminaries & simulation parameters
clc;clear;close all
sim = SIM.sim;
sim.setDuration(3600,'s')
dynamicCalc = ''; % We need to get rid of this and move to quaternoins

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
hiLvlCtrl.initBasisParams.setValue([0.4,1.1,20*pi/180,0,125],'[]') % Lemniscate of Booth

%% Environment IC's and dependant properties
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
wnch.setTetherInitLength(vhcl,env,thr,[norm(env.water.flowVec.Value) 0 0]);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value)


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;

%% Plot basis parameters vs time and iteration number
figure('Name','Basis Parameters',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
plot(tsc.basisParams.Time/60,squeeze(tsc.basisParams.Data(1,:,:)),...
    'LineWidth',1.5,'Color','k','DisplayName','$b_1$')
hold on
plot(tsc.basisParams.Time/60,squeeze(tsc.basisParams.Data(2,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','$b_2$')
drawIterationTicks(gca,tsc.estGradient.Time/60);
h.leg = legend;
h.leg.FontSize = 36;
h.leg.Location = 'best';
xlabel('Time, t [min]')
xlim([tsc.basisParams.Time(1) tsc.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel({'Basis Parameter'},'FontSize',36)


%% Plot Performance Index
% Resample to plot against iteration index
figure('Name','Performance Index',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterPerfIdx = resample(tsc.perfIndx,tsc.estGradient.Time);
stairs(iterPerfIdx.Time./60,iterPerfIdx.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tsc.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tsc.basisParams.Time(1) tsc.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Performance Index','FontSize',36)

%% Plot Mean Power
% Resample to plot against iteration index
figure('Name','Mean Power',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterMeanPower = resample(tsc.meanPower,tsc.estGradient.Time);
stairs(iterMeanPower.Time./60,iterMeanPower.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tsc.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tsc.basisParams.Time(1) tsc.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Mean Power','FontSize',36)


%% Plot Penalty Term in Performance Index
figure('Name','Penalty Term',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterPenaltyTerm = resample(tsc.penaltyTerm,tsc.estGradient.Time);
stairs(iterPenaltyTerm.Time./60,iterPenaltyTerm.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tsc.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tsc.basisParams.Time(1) tsc.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Penalty Term','FontSize',36)
