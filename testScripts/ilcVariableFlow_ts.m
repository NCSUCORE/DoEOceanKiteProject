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
loadComponent('fig8ILC15mPs')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('CNAPsTurbMitchell');


%% Environment IC's and dependant properties
% env.water.setflowVec([2 0 0],'m/s')

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
    (11/2)*norm(squeeze(env.water.flowVecTimeseries.Value.Data(3,15,9,:,1)))) % Initial speed
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
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,squeeze(env.water.flowVecTimeseries.Value.Data(3,15,9,:,1)));
wnch.winch1.setMaxSpeed(inf,'m/s');

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.initBasisParams.Value,...
    gndStn.posVec.Value);


%% Run the simulation
simWithMonitor('OCTModel')
tscILC = parseLogsout;

%%
hiLvlCtrl.learningGain.setValue(0,'[]');
simWithMonitor('OCTModel')
tscBaseline = parseLogsout;

%% Things to plot
close all
fontSize = 48;
lineWidth = 3;
ilcLegendName = sprintf('ILC (%d Iterations)',tscILC.iterationNumber.Data(end));
baselineLegendName = sprintf('Baseline (%d Iterations)',tscBaseline.iterationNumber.Data(end));
ilcIterTimes        = tscILC.ilcTrigger.Time(tscILC.ilcTrigger.Data);
baselineIterTimes   = tscBaseline.ilcTrigger.Time(tscBaseline.ilcTrigger.Data);

% 1 Basis parameters
figure('Name','varFlwBasisParams')
% Plot the results from ILC
stairs(tscILC.basisParams.Time./60,...
    squeeze(tscILC.basisParams.Data(1,:,:)),...
    'LineWidth',lineWidth,'Color','k','LineStyle','-','DisplayName','$b_1$, ILC');
hold on
stairs(tscILC.basisParams.Time./60,...
    squeeze(tscILC.basisParams.Data(2,:,:)),...
    'LineWidth',lineWidth,'Color','k','LineStyle','--','DisplayName','$b_2$, ILC');
% Plot the results from the baseline
stairs(tscBaseline.basisParams.Time./60,...
    squeeze(tscBaseline.basisParams.Data(1,:,:)),...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'LineStyle','-','DisplayName','$b_1$, Baseline');
stairs(tscBaseline.basisParams.Time./60,...
    squeeze(tscBaseline.basisParams.Data(2,:,:)),...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'LineStyle','--','DisplayName','$b_2$, Baseline');

% Add figure annotations and set formatting
xlabel('Time [min]')
ylabel({'Basis Parameters [rad]'})
title(['Basis Parameters, ', 'Variable Flow'])
set(gca,'FontSize',fontSize)
box off
grid on
legend('Location','Best')
    

% 2 Performance index vs time (denote total number of iterations)
figure('Name','varFlwPerfIndx')
% Plot the ILC results
stairs(ilcIterTimes./60,tscILC.perfIndx.Data(tscILC.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
% Plot the baseline results
stairs(baselineIterTimes./60,tscBaseline.perfIndx.Data(tscBaseline.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
legend('Location','Best')
xlabel('Time [min]')
ylabel({'Performance Index [kW]'})
title(['Performance Index, ', 'Variable Flow'])
set(gca,'FontSize',fontSize)
box off
grid on

% 3 Mean power vs time
figure('Name','varFlwMeanPwr')
stairs(ilcIterTimes./60,tscILC.meanPower.Data(tscILC.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
stairs(baselineIterTimes./60,tscBaseline.meanPower.Data(tscBaseline.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
legend('Location','Best')
xlabel('Time [min]')
ylabel({'Mean Power [kW]'})
title(['Mean Power, ', 'Variable Flow'])
set(gca,'FontSize',fontSize)
box off
grid on

% 4 Penalty term vs time (denote total number of iterations)
figure('Name','varFlwPenTerm')
stairs(ilcIterTimes./60,tscILC.penaltyTerm.Data(tscILC.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
stairs(baselineIterTimes./60,tscBaseline.penaltyTerm.Data(tscBaseline.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
xlabel('Time [min]')
ylabel({'Penalty Term [rad]'})
title(['Penalty Term, ', 'Variable Flow'])
set(gca,'FontSize',fontSize)
legend('Location','Best')
box off
grid on

% 5 Mean flight speed
figure('Name','varFlwMeanSpeed')
stairs(ilcIterTimes./60,tscILC.meanSpeed.Data(tscILC.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
stairs(baselineIterTimes./60,tscBaseline.meanSpeed.Data(tscBaseline.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
xlabel('Time [min]')
ylabel({'Mean Speed [m/s]'})
title(['Mean Speed, ', 'Variable Flow'])
legend('Location','Best')
set(gca,'FontSize',fontSize)
box off
grid on


% 6 Mean tension over lap
figure('Name','varFlwMeanTen')
stairs(ilcIterTimes./60,tscILC.meanTen.Data(tscILC.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
stairs(baselineIterTimes./60,tscBaseline.meanTen.Data(tscBaseline.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
xlabel('Time [min]')
ylabel({'Mean Tension [kN]'})
title(['Mean Tether Tension, ', 'Variable Flow'])
set(gca,'FontSize',fontSize)
legend('Location','Best')
box off
grid on

% 7 Mean flow speed at CoM
figure('Name','varFlwMeanFlwSpeed')
stairs(ilcIterTimes./60,tscILC.meanFlow.Data(tscILC.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
stairs(baselineIterTimes./60,tscBaseline.meanFlow.Data(tscBaseline.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
xlabel('Time [min]')
ylabel({'Mean Flow Speed [m/s]'})
title(['Mean Flow Speed, ', 'Variable Flow'])
legend('Location','Best')
set(gca,'FontSize',fontSize)
box off
grid on

% 8 Initial and final path
figure('Name','varFlwPathShape')
initShape  = eval(sprintf('%s(linspace(0,1,1000),hiLvlCtrl.initBasisParams.Value,gndStn.posVec.Value)',PATHGEOMETRY));
finalShape = eval(sprintf('%s(linspace(0,1,1000),tscILC.basisParams.Data(:,:,end),gndStn.posVec.Value)',PATHGEOMETRY));
plot3(initShape(1,:),initShape(2,:),initShape(3,:),...
    'LineWidth',lineWidth,'Color','k','LineStyle','-','DisplayName','Initial Shape');
grid on
hold on
box off
plot3(finalShape(1,:),finalShape(2,:),finalShape(3,:),...
    'LineWidth',lineWidth,'Color','k','LineStyle','--','DisplayName','Final Shape');
h.scat3 = scatter3(gndStn.posVec.Value(1),gndStn.posVec.Value(2),gndStn.posVec.Value(3),...
    'Marker','o','CData',[1 0 0],'MarkerFaceColor',[1 0 0],'DisplayName','Platform Position');
legend
title({'Initial and Final Path Shape','Variable Flow'})
daspect([1 1 1])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
set(gca,'FontSize',fontSize)
view([54 5])
h.leg = findobj(gcf,'Type','Legend');
h.leg.Position = [0.5598    0.5763    0.1941    0.1667];

% 9 Plot instantaneous flow speed at CoM
figure('Name','varFlowInstFlwSpdCoM')
speed = squeeze(sqrt(sum(tscILC.vhclFlowVecs.Data(:,end,:).^2,1)));
plot(tscILC.vhclFlowVecs.Time,speed,...
    'LineWidth',lineWidth,'Color','k');
xlabel('Time [min]')
ylabel('Flow Speed [m/s]')
title('Instantaneous Flow Speed at CoM')
set(gca,'FontSize',fontSize)
box off
grid on


%%
filePath = ['output',filesep,'varFlwResults'];
saveAllPlots('Folder',filePath)
cropImages(filePath)

%%
save('varFlwResults','tscILC','tscBaseline','-v7.3');

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





