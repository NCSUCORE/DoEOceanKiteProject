% Test script to test modularized modle
clear;clc
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
duration_s = 900;

% Set active variants
ENVIRONMENT = 'ayazFlow';
CONTROLLER  = 'ayazController';
PLANT       = 'ayazPlant';

% Setup setpoint timeseries
time = 0:0.1:duration_s;
set_alt = set_alti*ones(size(time));
set_pitch = set_pitch*ones(size(time));
rollPeriod = 200;
set_roll = set_roll*square(2*pi*time/rollPeriod);

set_roll(1:2000) = zeros(1,2000);

set_pitch = timeseries(set_pitch,time);
set_roll  = timeseries(set_roll, time);
set_alt = timeseries(set_alt, time);

% Run simulation
sim('OCTModel')

% Parse out the results
tsc = parseLogsout;

% Plot some things
figure
tsc.posVec.plot
hold on
legend('x','y','z')

figure
tsc.eulerAngles.Data = tsc.eulerAngles.Data*180/pi;
tsc.eulerAngles.plot
legend('roll','pitch','yaw')

% Plot euler angles
figure
subplot(3,1,1)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.data(1,:,:)),'LineWidth',2)
hold on
tsc.ayazStates.data(:,7) = tsc.ayazStates.data(:,7)*180/pi;
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,7),'LineWidth',2)
xlabel('Time, [s]')
ylabel('Roll, [deg]')
legend('Modularized','Ayaz''s')

subplot(3,1,2)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.data(2,:,:)),'LineWidth',2)
hold on
tsc.ayazStates.data(:,8) = tsc.ayazStates.data(:,8)*180/pi;
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,8),'LineWidth',2)
xlabel('Time, [s]')
ylabel('Pitch, [deg]')

subplot(3,1,3)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.data(3,:,:)),'LineWidth',2)
hold on
tsc.ayazStates.data(:,9) = tsc.ayazStates.data(:,9)*180/pi;
plot(tsc.ayazStates.Time,tsc.ayazStates.data(:,9),'LineWidth',2)
xlabel('Time, [s]')
ylabel('Yaw, [deg]')
