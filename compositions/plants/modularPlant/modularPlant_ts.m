% Test script to test initial, coarse modularization of Ayazs model
format compact
% Initialize the highest level model
% OCTModel_init
% Initialize all the parameters that Ayaz's model needs to run
modularPlant_init


createModularPlantBus
createaAyazCtrlBus
createUniformFlowEnvironmentBus

elevonDeflection = [0 0]'*pi/180;
winchSpeeds      = 0.1*[1 1 1]';
windSpeed        = 1.5;
windDir          = 0;

sim_time = 100;


sim('ayazPlant_th')
tsc = parseLogsout();

%%
% Plot euler angles
figure
subplot(3,1,1)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.data(1,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,7),'LineWidth',2)
xlabel('Time, [s]')
ylabel('Roll, [rad]')

subplot(3,1,2)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.data(2,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,8),'LineWidth',2)
xlabel('Time, [s]')
ylabel('Pitch, [rad]')

subplot(3,1,3)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.data(3,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,9),'LineWidth',2)
xlabel('Time, [s]')
ylabel('Yaw, [rad]')

set(findall(gcf,'Type','axes'),'FontSize',24)

% Plot position
figure
subplot(3,1,1)
plot(tsc.posVec.Time,squeeze(tsc.posVec.data(1,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,1),'LineWidth',2)
xlabel('Time, [s]')
ylabel('x, [m]')

subplot(3,1,2)
plot(tsc.posVec.Time,squeeze(tsc.posVec.data(2,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,2),'LineWidth',2)
xlabel('Time, [s]')
ylabel('y, [m]')

subplot(3,1,3)
plot(tsc.posVec.Time,squeeze(tsc.posVec.data(3,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,3),'LineWidth',2)
xlabel('Time, [s]')
ylabel('z, [m]')

set(findall(gcf,'Type','axes'),'FontSize',24)

% Plot the velocity
figure
subplot(3,1,1)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.data(1,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,4),'LineWidth',2)
xlabel('Time, [s]')
ylabel('x velocity, [m/s]')

subplot(3,1,2)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.data(2,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,5),'LineWidth',2)
xlabel('Time, [s]')
ylabel('y velocity, [m/s]')

subplot(3,1,3)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.data(3,:,:)),'LineWidth',2)
hold on
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,6),'LineWidth',2)
xlabel('Time, [s]')
ylabel('z velocity, [m/s]')

set(findall(gcf,'Type','axes'),'FontSize',24)