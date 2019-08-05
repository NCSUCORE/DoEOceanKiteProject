% tether000_tsmc
% The purpose of this script is to spring-damper behavior of the tether
% model

%% Set-up test
clear; close all; clc;

% Test control parameters
simDuration = 100;        % seconds

totalMass = 945;

% Unstretched tether lengtsh, meters
tetherLengths = [200 200]; % m


%% Create busses
createThrTenVecBus
thrAttachPtKinematics_bc
createConstantUniformFlowEnvironmentBus

%% Construct objects
% environment
env = ENV.env;
env.addFlow({'water'},'FlowDensities',1000);
env.water.velVec.setValue([0 0 0],'m/s');

% tether
% Define variants then make tether object
TETHERS = 'tether000';             % Is this which tether model to use?
%%
thr = OCT.tethers;
thr.setNumTethers(2,''); % Two tethers, they will be identical except for Youngs mod.
thr.setNumNodes(2,'');
thr.build;

thr.tether1.initGndNodePos.setValue([0 0 0]','m');
thr.tether1.initAirNodePos.setValue([0 0 tetherLengths(1)]','m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue([0 0 0]','m/s');
thr.tether1.vehicleMass.setValue(totalMass,'kg');
thr.tether1.youngsMod.setValue(75e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(2000,'kg/m^3');
thr.tether1.setDragEnable(false,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
thr.tether1.setDiameter(0.015,'m');

thr.tether2.initGndNodePos.setValue([0 0 0]','m');
thr.tether2.initAirNodePos.setValue([0 0 tetherLengths(1)]','m');
thr.tether2.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether2.initAirNodeVel.setValue([0 0 0]','m/s');
thr.tether2.vehicleMass.setValue(totalMass,'kg');
thr.tether2.youngsMod.setValue(150e9,'Pa');
thr.tether2.dampingRatio.setValue(0.75,'');
thr.tether2.dragCoeff.setValue(0.5,'');
thr.tether2.density.setValue(1300,'kg/m^3');
thr.tether2.setDragEnable(false,'');
thr.tether2.setSpringDamperEnable(true,'');
thr.tether2.setNetBuoyEnable(true,'');
thr.tether2.setDiameter(0.015,'m');

createThrNodeBus(thr.numNodes.Value); % Can this not be a class method? It probably could be.

%% Create the position/velocities for the end nodes
thr1AirNodeStartPos  = [0 0 200];
thr1AirNodeEndPos    = [0 0 205];
thr1GndNodeStartPos  = [0 0 0];
thr1GndNodeEndPos    = [0 0 0];

thr2AirNodeStartPos  = [0 0 200];
thr2AirNodeEndPos    = [0 0 205];
thr2GndNodeStartPos  = [0 0 0];
thr2GndNodeEndPos    = [0 0 0];

timeVec = 0:0.1:simDuration;

thr1AirNodePos(1,1,:)  = linspace(thr1AirNodeStartPos(1),thr1AirNodeEndPos(1),numel(timeVec));
thr1AirNodePos(2,1,:)  = linspace(thr1AirNodeStartPos(2),thr1AirNodeEndPos(2),numel(timeVec));
thr1AirNodePos(3,1,:)  = linspace(thr1AirNodeStartPos(3),thr1AirNodeEndPos(3),numel(timeVec));
thr1AirNodePos = timeseries(thr1AirNodePos,timeVec);

thr1GndNodePos(1,1,:)  = linspace(thr1GndNodeStartPos(1),thr1GndNodeEndPos(1),numel(timeVec));
thr1GndNodePos(2,1,:)  = linspace(thr1GndNodeStartPos(2),thr1GndNodeEndPos(2),numel(timeVec));
thr1GndNodePos(3,1,:)  = linspace(thr1GndNodeStartPos(3),thr1GndNodeEndPos(3),numel(timeVec));
thr1GndNodePos = timeseries(thr1GndNodePos,timeVec);

thr2AirNodePos(1,1,:)  = linspace(thr2AirNodeStartPos(1),thr2AirNodeEndPos(1),numel(timeVec));
thr2AirNodePos(2,1,:)  = linspace(thr2AirNodeStartPos(2),thr2AirNodeEndPos(2),numel(timeVec));
thr2AirNodePos(3,1,:)  = linspace(thr2AirNodeStartPos(3),thr2AirNodeEndPos(3),numel(timeVec));
thr2AirNodePos = timeseries(thr2AirNodePos,timeVec);

thr2GndNodePos(1,1,:)  = linspace(thr2GndNodeStartPos(1),thr2GndNodeEndPos(1),numel(timeVec));
thr2GndNodePos(2,1,:)  = linspace(thr2GndNodeStartPos(2),thr2GndNodeEndPos(2),numel(timeVec));
thr2GndNodePos(3,1,:)  = linspace(thr2GndNodeStartPos(3),thr2GndNodeEndPos(3),numel(timeVec));
thr2GndNodePos = timeseries(thr2GndNodePos,timeVec);

thr1GndNodeVel = timeseries(zeros(size(thr1AirNodePos.Data)),timeVec);
thr2GndNodeVel = thr1GndNodeVel;
thr1AirNodeVel = thr1GndNodeVel;
thr2AirNodeVel = thr1GndNodeVel;

%% Run the simulation
sim('tether000_thmc')
     
%% Get results
parseLogsout

%% Plot results
close all
figure
subplot(1,2,1)
plot(squeeze(sqrt(sum((tsc.thr1AirNodePos.Data-tsc.thr1GndNodePos.Data).^2))),...
    squeeze(sqrt(sum(tsc.gndTenVecBusArry(1).tenVec.data.^2))),...
    'LineWidth',2,'Color','k','DisplayName','Air','LineStyle','-')
hold on
grid on
plot(squeeze(sqrt(sum((tsc.thr1AirNodePos.Data-tsc.thr1GndNodePos.Data).^2))),...
    squeeze(sqrt(sum(tsc.gndTenVecBusArry(1).tenVec.data.^2))),...
    'LineWidth',2,'Color',0.5*[1 1 1],'DisplayName','Gnd','LineStyle','--')
legend
xlabel('Length, [m]')
ylabel('Net Force Magnitude')
title({'Tether 1',...
    sprintf('Youngs Mod = %.1e',thr.tether1.youngsMod.Value),...
    sprintf('Diameter = %.3f',thr.tether1.diameter.Value),...
    sprintf('Num Nodes = %d',thr.tether1.numNodes.Value)})

subplot(1,2,2)
plot(squeeze(sqrt(sum((tsc.thr2AirNodePos.Data-tsc.thr2GndNodePos.Data).^2))),...
    squeeze(sqrt(sum(tsc.gndTenVecBusArry(2).tenVec.data.^2))),...
    'LineWidth',2,'Color','k','DisplayName','Air','LineStyle','-')
hold on
grid on
plot(squeeze(sqrt(sum((tsc.thr2AirNodePos.Data-tsc.thr2GndNodePos.Data).^2))),...
    squeeze(sqrt(sum(tsc.gndTenVecBusArry(2).tenVec.data.^2))),...
    'LineWidth',2,'Color',0.5*[1 1 1],'DisplayName','Gnd','LineStyle','--')
legend
xlabel('Time, [s]')
ylabel('Net Force Magnitude')
title({'Tether 2',...
    sprintf('Youngs Mod = %.1e',thr.tether2.youngsMod.Value),...
    sprintf('Diameter = %.3f',thr.tether2.diameter.Value),...
    sprintf('Num Nodes = %d',thr.tether2.numNodes.Value)});


linkaxes(findall(gcf,'Type','axes'),'y')

set(findall(gcf,'Type','axes'),'FontSize',18)