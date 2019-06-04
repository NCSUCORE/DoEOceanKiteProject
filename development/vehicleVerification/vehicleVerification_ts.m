% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init

modularPlant_init;

duration_s = 200;

CONTROLLER = 'threeTetherThreeSurfaceCtrl';
createThreeTetherThreeSurfaceCtrlBus;

PLANT = 'origionalPlant';
createOrigionalPlantBus;

ENVIRONMENT = 'constantUniformFlow';
createConstantUniformFlowEnvironmentBus;


% Calculate setpoints
timeVec = 0:0.1:duration_s;
set_alt = timeseries(set_alti*ones(size(timeVec)),timeVec);
set_pitch = timeseries(set_pitch*ones(size(timeVec))*180/pi,timeVec);
set_roll = timeseries(set_roll*ones(size(timeVec))*180/pi,timeVec);

sim('OCTModel')
tscOrig = parseLogsout;

PLANT = 'modularPlant';
createModularPlantBus;

sim('OCTModel')
tscMod = parseLogsout;


%% Plot Positions
figure('Position',[ 0.5005    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(tscOrig.posVec.Time,squeeze(tscOrig.posVec.Data(1,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(1,:,:)),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('x Pos. [m]')

subplot(3,1,2)
plot(tscOrig.posVec.Time,squeeze(tscOrig.posVec.Data(2,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(2,:,:)),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('y Pos. [m]')

subplot(3,1,3)
plot(tscOrig.posVec.Time,squeeze(tscOrig.posVec.Data(3,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(3,:,:)),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')

plot(set_alt.Time,squeeze(set_alt.Data),...
    'LineWidth',1.5,'Color',[1 0 0],'LineStyle','--')
xlabel('Time, [s]')
ylabel('z Setpoint. [m]')

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')


%% Plot Euler Angles
figure('Position',[ 0.0005    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(tscOrig.eulerAngles.Time,squeeze(tscOrig.eulerAngles.Data(1,:,:))*180/pi,...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(1,:,:))*180/pi,...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
plot(set_roll.Time,squeeze(set_roll.Data),...
    'LineWidth',1.5,'Color',[1 0 0],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Roll, [deg]')

subplot(3,1,2)
plot(tscOrig.eulerAngles.Time,squeeze(tscOrig.eulerAngles.Data(2,:,:))*180/pi,...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(2,:,:))*180/pi,...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
plot(set_pitch.Time,squeeze(set_pitch.Data),...
    'LineWidth',1.5,'Color',[1 0 0],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Pitch, [deg]')

subplot(3,1,3)
plot(tscOrig.eulerAngles.Time,squeeze(tscOrig.eulerAngles.Data(3,:,:))*180/pi,...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(3,:,:))*180/pi,...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Yaw, [deg]')

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot tether lenghts
figure
subplot(3,1,1)
plot(tscOrig.tetherLengths.Time,squeeze(tscOrig.tetherLengths.Data(1,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.tetherLengths.Time,tscMod.tetherLengths.Data(:,1),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Tether 1 Length, [m]')

subplot(3,1,2)
plot(tscOrig.tetherLengths.Time,squeeze(tscOrig.tetherLengths.Data(2,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.tetherLengths.Time,tscMod.tetherLengths.Data(:,2),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Tether 2 Length, [m]')

subplot(3,1,3)
plot(tscOrig.tetherLengths.Time,squeeze(tscOrig.tetherLengths.Data(3,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.tetherLengths.Time,tscMod.tetherLengths.Data(:,3),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Tether 3 Length, [m]')

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot platform angle

