% Test script to test modularized modle
close all;clear;clc
format compact

% Initialize the highest level model
OCTModel_init

% Initialize all of ayaz's parameters
ayazPlant_init

% Create the bus objects in the workspace
createAyazPlantBus
createAyazFlowEnvironmentBus
createaAyazCtrlBus

% Set simulation duration
duration_s = 1000;

% Set active variants
ENVIRONMENT = 'ayazFlow';
CONTROLLER  = 'ayazController';
PLANT       = 'ayazPlant';

% Setup setpoint timeseries
time = 0:0.1:duration_s;
set_pitch = set_pitch*ones(size(time));
set_roll = 20*(pi/180)*sign(sin(2*pi*time./200));
set_roll(time<200) = 0;
set_alt = set_alti*ones(size(time));

set_pitch = timeseries(set_pitch,time);
set_roll  = timeseries(set_roll, time);
set_alt   = timeseries(set_alt,time);

% sim_param.platform_param.platform_Izz =sim_param.geom_param.MI(3);

try
    sim('origionalPlant_th')
catch
end
tscAyaz = parseLogsout;

try
    sim('groundStationVerify_th')
catch
end
tscMod = parseLogsout;

clearvars logsout

%%
close all
figure
subplot(3,1,1)
plot(tscAyaz.posVec.Time,tscAyaz.posVec.Data(:,1),'LineWidth',2)
hold on
plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(1,:,:)),'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('x pos [m]')

subplot(3,1,2)
plot(tscAyaz.posVec.Time,tscAyaz.posVec.Data(:,2),'LineWidth',2)
hold on
plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(2,:,:)),'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('y pos [m]')

subplot(3,1,3)
plot(tscAyaz.posVec.Time,tscAyaz.posVec.Data(:,3),'LineWidth',2)
hold on
plot(tscMod.posVec.Time,squeeze(tscMod.posVec.Data(3,:,:)),'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('z pos [m]')

set(findall(gcf,'Type','axes'),'FontSize',24)

figure
subplot(3,1,1)
plot(tscAyaz.velocityVec.Time,tscAyaz.velocityVec.Data(:,1),'LineWidth',2)
hold on
plot(tscMod.velocityVec.Time,squeeze(tscMod.velocityVec.Data(1,:,:)),'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('x vel [m]')

subplot(3,1,2)
plot(tscAyaz.velocityVec.Time,tscAyaz.velocityVec.Data(:,2),'LineWidth',2)
hold on
plot(tscMod.velocityVec.Time,squeeze(tscMod.velocityVec.Data(2,:,:)),'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('y vel [m]')

subplot(3,1,3)
plot(tscAyaz.velocityVec.Time,tscAyaz.velocityVec.Data(:,3),'LineWidth',2)
hold on
plot(tscMod.velocityVec.Time,squeeze(tscMod.velocityVec.Data(3,:,:)),'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('z vel [m]')

set(findall(gcf,'Type','axes'),'FontSize',24)

figure
subplot(3,1,1)
plot(tscAyaz.eulerAngles.Time,tscAyaz.eulerAngles.Data(:,1)*180/pi,'LineWidth',2)
hold on
plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(:,1))*180/pi,'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('Roll [deg]')

subplot(3,1,2)
plot(tscAyaz.eulerAngles.Time,tscAyaz.eulerAngles.Data(:,2)*180/pi,'LineWidth',2)
hold on
plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(:,2))*180/pi,'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('Pitch [deg]')

subplot(3,1,3)
plot(tscAyaz.eulerAngles.Time,tscAyaz.eulerAngles.Data(:,3)*180/pi,'LineWidth',2)
hold on
plot(tscMod.eulerAngles.Time,squeeze(tscMod.eulerAngles.Data(:,3))*180/pi,'LineWidth',2,'LineStyle','--')
xlabel('Time [s]')
ylabel('Yaw [deg]')

set(findall(gcf,'Type','axes'),'FontSize',24)

%%
figure
subplot(4,1,1)
tscMod.platformAngle.plot
hold on
tscAyaz.platformAngle.plot

subplot(4,1,2)
plot(tscMod.tether1Moment.Time,tscMod.tether1Moment.Data(:,3))
hold on
plot(tscMod.tether3Moment.Time,tscMod.tether3Moment.Data(:,3))

subplot(4,1,3)
plot(tscMod.tether3Moment.Time,tscMod.tether1Moment.Data(:,3)+tscMod.tether3Moment.Data(:,3))

subplot(4,1,4)
tscMod.netTetherMoment.plot

linkaxes(findall(gcf,'Type','axes'),'x')

figure
tscMod.platformAngle.plot
hold on
tscAyaz.platformAngle.plot


%%
figure
subplot(2,1,1)
tscMod.netTetherMoment.plot
subplot(2,1,2)
tscMod.platformAngle.plot
hold on
tscAyaz.platformAngle.plot
linkaxes(findall(gcf,'Type','axes'),'x')

%%
% close all
figure
indices = [1 length(tscMod.eulerAngles.Time)];
for ii = 1:length(indices)
    idx = indices(ii);
    thr1 = reshape(tscMod.thr1NodePositions.data(idx,:),[3 2]);
    thr2 = reshape(tscMod.thr2NodePositions.data(idx,:),[3 2]);
    thr3 = reshape(tscMod.thr3NodePositions.data(idx,:),[3 2]);
    plot3(thr1(1,:),thr1(2,:),thr1(3,:),'Color',[1 0 0])
    hold on
    plot3(thr2(1,:),thr2(2,:),thr2(3,:),'Color',[0 1 0])
    plot3(thr3(1,:),thr3(2,:),thr3(3,:),'Color',[0 0 1])
    scatter3(tscMod.thr1AttachPt.data(idx,1),tscMod.thr1AttachPt.data(idx,2),tscMod.thr1AttachPt.data(idx,3))
    scatter3(tscMod.thr2AttachPt.data(idx,1),tscMod.thr2AttachPt.data(idx,2),tscMod.thr2AttachPt.data(idx,3))
    scatter3(tscMod.thr3AttachPt.data(idx,1),tscMod.thr3AttachPt.data(idx,2),tscMod.thr3AttachPt.data(idx,3))
    axis square
    axis equal
    grid on   

end
%%
% close all
figure
plot(tscMod.thr1AttachPt.data(:,1),tscMod.thr1AttachPt.data(:,2))
hold on
grid on
plot(tscMod.thr2AttachPt.data(:,1),tscMod.thr2AttachPt.data(:,2))
plot(tscMod.thr3AttachPt.data(:,1),tscMod.thr3AttachPt.data(:,2))

plot(tscMod.thr1NodePositions.data(:,1),tscMod.thr1NodePositions.data(:,2))
plot(tscMod.thr2NodePositions.data(:,1),tscMod.thr2NodePositions.data(:,2))
plot(tscMod.thr3NodePositions.data(:,1),tscMod.thr3NodePositions.data(:,2))


scatter(sim_param.tether_imp_nodes.R11_g(1),sim_param.tether_imp_nodes.R11_g(2))
scatter(sim_param.tether_imp_nodes.R21_g(1),sim_param.tether_imp_nodes.R21_g(2))
scatter(sim_param.tether_imp_nodes.R31_g(1),sim_param.tether_imp_nodes.R31_g(2))
axis square
axis equal
grid on





    