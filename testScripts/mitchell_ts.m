%% Script to run ILC path optimization
clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(500,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('pathFollowingVhclForComp');
% Environment
loadComponent('constXYZT');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')


%% Environment IC's and dependant properties
env.water.setflowVec([1 0 0],'m/s')

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([0.9,1.5,20*pi/180,0*pi/180,125],'') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value)) % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.initBasisParams.Value,...
    gndStn.posVec.Value);


%% Run the simulation
simWithMonitor('OCTModel')
tscILC = signalcontainer(logsout);

%%
if runBaseline
    hiLvlCtrl.learningGain.setValue(0,'[]');
    simWithMonitor('OCTModel')
    tscBaseline = signalcontainer(logsout);
end

%% Things to plot
close all
fontSize = 48;
lineWidth = 3;
ilcLegendName = sprintf('ILC (%d Iterations)',tscILC.iterationNumber.Data(end));
ilcIterTimes        = tscILC.ilcTrigger.Time(tscILC.ilcTrigger.Data);
if runBaseline
    baselineLegendName = sprintf('Baseline (%d Iterations)',tscBaseline.iterationNumber.Data(end));
    baselineIterTimes   = tscBaseline.ilcTrigger.Time(tscBaseline.ilcTrigger.Data);
end

%% 1 Basis parameters
figure('Name',sprintf('cnstFlwBasisParams%dmPs',env.water.flowVec.Value(1)))
% Plot the results from ILC
stairs(tscILC.basisParams.Time./60,...
    squeeze(tscILC.basisParams.Data(1,1,:)),...
    'LineWidth',lineWidth,'Color','k','LineStyle','-','DisplayName','$b_1$, ILC');
hold on
stairs(tscILC.basisParams.Time./60,...
    squeeze(tscILC.basisParams.Data(1,2,:)),...
    'LineWidth',lineWidth,'Color','k','LineStyle','--','DisplayName','$b_2$, ILC');
% Plot the results from the baseline
if runBaseline
    stairs(tscBaseline.basisParams.Time./60,...
        squeeze(tscBaseline.basisParams.Data(1,1,:)),...
        'LineWidth',lineWidth,'Color',0.5*[1 1 1],'LineStyle','-','DisplayName','$b_1$, Baseline');
    stairs(tscBaseline.basisParams.Time./60,...
        squeeze(tscBaseline.basisParams.Data(1,2,:)),...
        'LineWidth',lineWidth,'Color',0.5*[1 1 1],'LineStyle','--','DisplayName','$b_2$, Baseline');
end
% Add figure annotations and set formatting
xlabel('Time [min]')
ylabel({'Basis Parameters [rad]'})
title(['Basis Parameters, ', sprintf('Constant %d m/s Flow',env.water.flowVec.Value(1))])
set(gca,'FontSize',fontSize)
box off
grid on

ylim([0.25 1.25])
legend('Location','Best')
    

% 2 Performance index vs time (denote total number of iterations)
figure('Name',sprintf('cnstFlwPerfIndx%dmPs',env.water.flowVec.Value(1)))
% Plot the ILC results
stairs(ilcIterTimes./60,tscILC.perfIndx.Data(tscILC.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
% Plot the baseline results
if runBaseline
    stairs(baselineIterTimes./60,tscBaseline.perfIndx.Data(tscBaseline.ilcTrigger.Data)./1000,...
        'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
end
legend('Location','Best')
xlabel('Time [min]')
ylabel({'Performance Index [kW]'})
title(['Performance Index, ', sprintf('Constant %d m/s Flow',env.water.flowVec.Value(1))])
set(gca,'FontSize',fontSize)
box off
grid on

% 3 Mean power vs time
figure('Name',sprintf('cnstFlwMeanPwr%dmPs',env.water.flowVec.Value(1)))
stairs(ilcIterTimes./60,tscILC.meanPower.Data(tscILC.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
if runBaseline
    stairs(baselineIterTimes./60,tscBaseline.meanPower.Data(tscBaseline.ilcTrigger.Data)./1000,...
        'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
end
legend('Location','Best')
xlabel('Time [min]')
ylabel({'Mean Power [kW]'})
title(['Mean Power, ', sprintf('Constant %d m/s Flow',env.water.flowVec.Value(1))])
set(gca,'FontSize',fontSize)
box off
grid on

% 4 Penalty term vs time (denote total number of iterations)
figure('Name',sprintf('cnstFlwPenTerm%dmPs',env.water.flowVec.Value(1)))
stairs(ilcIterTimes./60,tscILC.penaltyTerm.Data(tscILC.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
if runBaseline
    stairs(baselineIterTimes./60,tscBaseline.penaltyTerm.Data(tscBaseline.ilcTrigger.Data),...
        'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
end
xlabel('Time [min]')
ylabel({'Penalty Term [rad]'})
title(['Penalty Term, ', sprintf('Constant %d m/s Flow',env.water.flowVec.Value(1))])
set(gca,'FontSize',fontSize)
legend('Location','Best')
box off
grid on

% 5 Mean flight speed
figure('Name',sprintf('cnstFlwMeanSpeed%dmPs',env.water.flowVec.Value(1)))
stairs(ilcIterTimes./60,tscILC.meanSpeed.Data(tscILC.ilcTrigger.Data),...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
if runBaseline
    stairs(baselineIterTimes./60,tscBaseline.meanSpeed.Data(tscBaseline.ilcTrigger.Data),...
        'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
end
xlabel('Time [min]')
ylabel({'Mean Speed [m/s]'})
title(['Mean Speed, ', sprintf('Constant %d m/s Flow',env.water.flowVec.Value(1))])
legend('Location','Best')
set(gca,'FontSize',fontSize)
box off
grid on


% 6 Mean tension over lap
figure('Name',sprintf('cnstFlwMeanTen%dmPs',env.water.flowVec.Value(1)))
stairs(ilcIterTimes./60,tscILC.meanTen.Data(tscILC.ilcTrigger.Data)./1000,...
    'LineWidth',lineWidth,'Color','k','DisplayName',ilcLegendName);
hold on
if runBaseline
    stairs(baselineIterTimes./60,tscBaseline.meanTen.Data(tscBaseline.ilcTrigger.Data)./1000,...
        'LineWidth',lineWidth,'Color',0.5*[1 1 1],'DisplayName',baselineLegendName);
end
xlabel('Time [min]')
ylabel({'Mean Tension [kN]'})
title(['Mean Tether Tension, ', sprintf('Constant %d m/s Flow',env.water.flowVec.Value(1))])
set(gca,'FontSize',fontSize)
legend('Location','Best')
box off
grid on

% 7 Initial and final path
figure('Name',sprintf('cnstFlwPathShape%dmPs',env.water.flowVec.Value(1)))
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
title({'Initial and Final Path Shape',sprintf('Constant %d m/s Flow',env.water.flowVec.Value(1))})
daspect([1 1 1])
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
set(gca,'FontSize',fontSize)
view([54 5])
h.leg = findobj(gcf,'Type','Legend');
h.leg.Position = [0.5598    0.5763    0.1941    0.1667];

%
filePath = ['output',filesep,sprintf('cnstFlwResults%dmPs',env.water.flowVec.Value(1))];
saveAllPlots('Folder',filePath)
cropImages(filePath)

%
save(sprintf('cnstFlwResults%dmPs',env.water.flowVec.Value(1)),'tscILC','tscBaseline','-v7.3');






