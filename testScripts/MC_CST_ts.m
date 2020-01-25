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
loadComponent('pathFollowingCtrlForILC');
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
tscConst = parseLogsout;

%% Plot basis parameters vs time and iteration number
figure('Name','Constant Flow Basis Parameters',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
plot(tscConst.basisParams.Time/60,squeeze(tscConst.basisParams.Data(1,:,:)),...
    'LineWidth',1.5,'Color','k','DisplayName','$b_1$')
hold on
plot(tscConst.basisParams.Time/60,squeeze(tscConst.basisParams.Data(2,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','$b_2$')
drawIterationTicks(gca,tscConst.estGradient.Time/60);
h.leg = legend;
h.leg.FontSize = 36;
h.leg.Location = 'best';
xlabel('Time, t [min]')
xlim([tscConst.basisParams.Time(1) tscConst.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel({'Basis Parameter'},'FontSize',36)


%% Plot Performance Index
% Resample to plot against iteration index
figure('Name','Constant Flow Performance Index',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterPerfIdx = resample(tscConst.perfIndx,tscConst.estGradient.Time);
stairs(iterPerfIdx.Time./60,iterPerfIdx.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tscConst.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tscConst.basisParams.Time(1) tscConst.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Performance Index','FontSize',36)

%% Plot Mean Power
% Resample to plot against iteration index
figure('Name','Constant Flow Mean Power',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterMeanPower = resample(tscConst.meanPower,tscConst.estGradient.Time);
stairs(iterMeanPower.Time./60,iterMeanPower.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tscConst.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tscConst.basisParams.Time(1) tscConst.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Mean Power','FontSize',36)


%% Plot Penalty Term in Performance Index
figure('Name','Constant Flow Penalty Term',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterPenaltyTerm = resample(tscConst.penaltyTerm,tscConst.estGradient.Time);
stairs(iterPenaltyTerm.Time./60,iterPenaltyTerm.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tscConst.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tscConst.basisParams.Time(1) tscConst.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Penalty Term','FontSize',36)

%% ------------------------------------------------------------------------
% VARIABLE FLOW
% -------------------------------------------------------------------------
%% Preliminaries
sim.setDuration(7200,'s');

%% Load neccessary new components
% Environment
loadComponent('constXY_ZvarT_ADCP');

%% Environment IC's and dependant properties
env.water = env.water.setEndADCPTime(1.505e7,'s');
env.water = env.water.setStartADCPTime(1.48e7,'s');


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

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.initBasisParams.Value)


%% Run the simulation
simWithMonitor('OCTModel')
tscVarFlowILC = parseLogsout;

%% Plot flow speed at the vehicle center
figure('Name','Variable Flow Flow Speed',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
plot(tscVarFlowILC.vhclFlowVecs.Time(2:end)/60,squeeze(sqrt(sum(tscVarFlowILC.vhclFlowVecs.Data(:,5,2:end).^2))),...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tscVarFlowILC.estGradient.Time/60);
xlabel('Time, t [min]')
xlim([tscVarFlowILC.basisParams.Time(1) tscVarFlowILC.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel({'Flow Speed [m/s]'},'FontSize',36)


%% Plot basis parameters vs time and iteration number
figure('Name','Variable Flow Basis Parameters',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
plot(tscVarFlowILC.basisParams.Time/60,squeeze(tscVarFlowILC.basisParams.Data(1,:,:)),...
    'LineWidth',1.5,'Color','k','DisplayName','$b_1$')
hold on
plot(tscVarFlowILC.basisParams.Time/60,squeeze(tscVarFlowILC.basisParams.Data(2,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','$b_2$')
drawIterationTicks(gca,tscVarFlowILC.estGradient.Time/60);
h.leg = legend;
h.leg.FontSize = 36;
h.leg.Location = 'best';
xlabel('Time, t [min]')
xlim([tscVarFlowILC.basisParams.Time(1) tscVarFlowILC.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel({'Basis Parameter'},'FontSize',36)


%% Plot Performance Index
% Resample to plot against iteration index
figure('Name','Variable Flow Performance Index',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterPerfIdx = resample(tscVarFlowILC.perfIndx,tscVarFlowILC.estGradient.Time);
stairs(iterPerfIdx.Time./60,iterPerfIdx.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tscVarFlowILC.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tscVarFlowILC.basisParams.Time(1) tscVarFlowILC.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Performance Index','FontSize',36)

%% Plot Mean Power
% Resample to plot against iteration index
figure('Name','Variable Flow Mean Power',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterMeanPower = resample(tscVarFlowILC.meanPower,tscVarFlowILC.estGradient.Time);
stairs(iterMeanPower.Time./60,iterMeanPower.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tscVarFlowILC.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tscVarFlowILC.basisParams.Time(1) tscVarFlowILC.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Mean Power','FontSize',36)


%% Plot Penalty Term in Performance Index
figure('Name','Variable Flow Penalty Term',...
    'Position',[1.0000    0.0370    1.0000    0.8917])
iterPenaltyTerm = resample(tscVarFlowILC.penaltyTerm,tscVarFlowILC.estGradient.Time);
stairs(iterPenaltyTerm.Time./60,iterPenaltyTerm.Data,...
    'LineWidth',1.5,'Color','k')
drawIterationTicks(gca,tscVarFlowILC.estGradient.Time/60);xlabel('Time, t [min]')
xlim([tscVarFlowILC.basisParams.Time(1) tscVarFlowILC.basisParams.Time(end)/60])
set(findall(gcf,'Type','axes'),'FontSize',24)
ylabel('Penalty Term','FontSize',36)
