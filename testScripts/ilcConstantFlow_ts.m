%% Script to run ILC path optimization
clear;clc;close all
sim = SIM.sim;
sim.setDuration(2*3600,'s');
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
loadComponent('constXYZT');


%% Environment IC's and dependant properties
env.water.setflowVec([2 0 0],'m/s')

%% Set basis parameters for high level controller
hiLvlCtrl.initBasisParams.setValue([0.3,1,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 200],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.initBasisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value)) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.setMaxSpeed(inf,'m/s');

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.initBasisParams.Value,...
    gndStn.posVec.Value);


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;


%% Things to plot



iterTimes = tsc.ilcTrigger.Time(tsc.ilcTrigger.Data);

% 0 Basis parameters
figure('Name','cnstFlwBasisParams')
stairs(tsc.basisParams.Time./60,...
    squeeze(tsc.basisParams.Data(1,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','$b_1$');
hold on
stairs(tsc.basisParams.Time./60,...
    squeeze(tsc.basisParams.Data(2,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','$b_2$');
xlabel('Time [min]')
ylabel({'Basis','Parameters [kW]'})
title('Basis Parameters, Constant Flow Speed')
set(gca,'FontSize',36)
box off
grid on
legend
    


% 1 Performance index vs time (denote total number of iterations)
figure('Name','cnstFlwPerfIndx')
stairs(iterTimes./60,tsc.perfIndx.Data(tsc.ilcTrigger.Data)./1000,...
    'LineWidth',1.5,'Color','k');
xlabel('Time [min]')
ylabel({'Performance','Index [kW]'})
title('Performance Index, Constant Flow Speed')
set(gca,'FontSize',36)
box off
grid on

% 2 Mean power vs time (denote total number of iterations)
figure('Name','cnstFlwMeanPwr')
stairs(iterTimes./60,tsc.meanPower.Data(tsc.ilcTrigger.Data)./1000,...
    'LineWidth',1.5,'Color','k');
xlabel('Time [min]')
ylabel({'Mean','Power [kW]'})
title('Mean Power, Constant Flow Speed')
set(gca,'FontSize',36)
box off
grid on

% 3 Penalty term vs time (denote total number of iterations)
figure('Name','cnstFlwPenTerm')
stairs(iterTimes./60,tsc.penaltyTerm.Data(tsc.ilcTrigger.Data),...
    'LineWidth',1.5,'Color','k');
xlabel('Time [min]')
ylabel({'Penalty','Term [rad]'})
title('Penalty Term, Constant Flow Speed')
set(gca,'FontSize',36)
box off
grid on

% 4 Mean flow speed at CoM
figure('Name','cnstFlwMeanFlwSpeed')
stairs(iterTimes./60,tsc.meanFlow.Data(tsc.ilcTrigger.Data),...
    'LineWidth',1.5,'Color','k');
xlabel('Time [min]')
ylabel({'Mean Flow','Speed [m/s]'})
title('Mean Flow Speed, Constant Flow Speed')
set(gca,'FontSize',36)
box off
grid on


% 5 Mean flight speed
figure('Name','cnstFlwMeanSpeed')
stairs(iterTimes./60,tsc.meanSpeed.Data(tsc.ilcTrigger.Data),...
    'LineWidth',1.5,'Color','k');
xlabel('Time [min]')
ylabel({'Mean','Speed [m/s]'})
title('Mean Speed, Constant Flow Speed')
set(gca,'FontSize',36)
box off
grid on


% 6 Mean tension over lap
figure('Name','cnstFlwMeanTen')
stairs(iterTimes./60,tsc.meanTen.Data(tsc.ilcTrigger.Data)./1000,...
    'LineWidth',1.5,'Color','k');
xlabel('Time [min]')
ylabel({'Mean','Tension [kN]'})
title('Mean Tether Tension, Constant Flow Speed')
set(gca,'FontSize',36)
box off
grid on

% 8 Initial and final path
initShape = eval(sprintf('%s(linspace(0,1,1000),hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value)',PATHGEOMETRY));
finalShape = eval(sprintf('%s(linspace(0,1,1000),tsc.basisParams.Data(:,:,end),gndStn.posVec.Value)',PATHGEOMETRY));
plot3(initShape(1,:),initShape(2,:),initShape(3,:),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Initial Shape');
grid on
hold on
box off
plot3(finalShape(1,:),finalShape(2,:),finalShape(3,:),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','Final Shape');
h.scat3 = scatter3(gndStn.posVec.Value(1),gndStn.posVec.Value(2),gndStn.posVec.Value(3),...
    'Marker','o','CData',[1 0 0],'MarkerFaceColor',[1 0 0],'DisplayName','Ground Stn. Pos');
legend
title({'Initial and Final Path Shape','Constant Flow'})
daspect([1 1 1])
xlabel('x [m')
ylabel('y [m')
zlabel('z [m')
set(gca,'FontSize',36)

%%
% saveAllPlots('Folder',['output',filesep,'cnstFlwResults'])

%%
% vhcl.animateSim(tsc,1,...
%     'PathFunc',fltCtrl.fcnName.Value,...
%     'PathPosition',false,...
%     'ZoomIn',false,...
%     'NavigationVecs',true,...
%     'TangentCoordSys',false,...
%     'VelocityVec',true,...
%     'Pause',false,...
%     'PlotTracer',true,...
%     'LocalAero',false,...
%     'SaveMPEG',false)




