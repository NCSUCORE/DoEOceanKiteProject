% Script to test the origional model against the modularized model
clear all;clc;

OCTModel_init

modularPlant_init;

duration_s = 1000;

load('dsgnAyaz1_2D_Lookup');

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

set_roll.Data = 10*sign(sin(timeVec/(2*pi*200)));
set_roll.Data(timeVec<200) = 0;

% Set controller gains and time constants
% Uncomment this code to disable the controller
sim_param.elevons_param.elevator_control.kp_elev    = 0;
sim_param.elevons_param.elevator_control.ki_elev    = 0;
sim_param.elevons_param.elevator_control.kd_elev    = 0;
sim_param.elevons_param.elevator_control.t_elev     = 1;

sim_param.elevons_param.aileron_control.kp_aileron  = 0;
sim_param.elevons_param.aileron_control.ki_aileron  = 0;
sim_param.elevons_param.aileron_control.kd_aileron  = 0;
sim_param.elevons_param.aileron_control.t_aileron   = 1;

sim_param.controller_param.alti_control.Kp_z    = 0;
sim_param.controller_param.alti_control.Ki_z    = 0;
sim_param.controller_param.alti_control.Kd_z    = 0;
sim_param.controller_param.alti_control.wce_z   = 1;

sim_param.controller_param.pitch_control.Kp_p    = 0;
sim_param.controller_param.pitch_control.Ki_p    = 0;
sim_param.controller_param.pitch_control.Kd_p    = 0;
sim_param.controller_param.pitch_control.wce_p   = 0.1;

sim_param.controller_param.roll_control.Kp_r    = 0;
sim_param.controller_param.roll_control.Ki_r    = 0;
sim_param.controller_param.roll_control.Kd_r    = 0;
sim_param.controller_param.roll_control.wce_r   = 1;

% Run the origional plant model
fprintf('Running Origional Model\n')
sim('OCTModel')
tscOrig = parseLogsout; % Log the output data

% Switch to modular plant model
PLANT = 'modularPlant';
createModularPlantBus;

% Run the modular plant model
fprintf('Running Modular Model\n')
sim('OCTModel')
tscMod = parseLogsout; % Log the output data


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

%% Plot angular velocity vector
figure('Position',[ 0.0005    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(tscOrig.angVelVec.Time,squeeze(tscOrig.angVelVec.Data(1,:,:))*180/pi,...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.angVelVec.Time,squeeze(tscMod.angVelVec.Data(1,:,:))*180/pi,...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('$\omega_x$ [rad/s]')

subplot(3,1,2)
plot(tscOrig.angVelVec.Time,squeeze(tscOrig.angVelVec.Data(2,:,:))*180/pi,...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.angVelVec.Time,squeeze(tscMod.angVelVec.Data(2,:,:))*180/pi,...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('$\omega_y$ [rad/s]')

subplot(3,1,3)
plot(tscOrig.angVelVec.Time,squeeze(tscOrig.angVelVec.Data(3,:,:))*180/pi,...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.angVelVec.Time,squeeze(tscMod.angVelVec.Data(3,:,:))*180/pi,...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('$\omega_z$ [rad/s]')

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot tether lenghts
figure('Position',[-0.4995    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(tscOrig.tetherLengths.Time,squeeze(tscOrig.tetherLengths.Data(1,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.tetherLengths.Time,tscMod.tetherLengths.Data(:,1),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel({'Tether 1','Length, [m]'})

subplot(3,1,2)
plot(tscOrig.tetherLengths.Time,squeeze(tscOrig.tetherLengths.Data(2,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.tetherLengths.Time,tscMod.tetherLengths.Data(:,2),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel({'Tether 2','Length, [m]'})

subplot(3,1,3)
plot(tscOrig.tetherLengths.Time,squeeze(tscOrig.tetherLengths.Data(3,:,:)),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.tetherLengths.Time,tscMod.tetherLengths.Data(:,3),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel({'Tether 3','Length, [m]'})

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot platform angle
figure('Position',[-0.9995    0.0380    0.4990    0.8833])
subplot(3,1,1)
plot(tscOrig.platformAngle.Time,squeeze(tscOrig.platformAngle.Data*180/pi),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Original')
grid on
hold on
plot(tscMod.platformAngle.Time,squeeze(tscMod.platformAngle.Data),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Modular')
xlabel('Time, [s]')
ylabel({'Platform','Angle, [deg]'})
legend
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot controller commands
figure('Position',[-1.5625   -0.1824    0.5625    1.6694])
subplot(5,1,1)
plot(tscOrig.elevonPitchCmd.Time,squeeze(tscOrig.elevonPitchCmd.Data),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Original')
grid on
hold on
plot(tscMod.elevonPitchCmd.Time,squeeze(tscMod.elevonPitchCmd.Data),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Modular')
xlabel('Time, [s]')
ylabel('Elevon Pitch Cmd')

subplot(5,1,2)
plot(tscOrig.elevonRollCmd.Time,squeeze(tscOrig.elevonRollCmd.Data),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Original')
grid on
hold on
plot(tscMod.elevonRollCmd.Time,squeeze(tscMod.elevonRollCmd.Data),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Modular')
xlabel('Time, [s]')
ylabel('Elevon Roll Cmd')

subplot(5,1,3)
plot(tscOrig.winchAltitudeCmd.Time,squeeze(tscOrig.winchAltitudeCmd.Data),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Original')
grid on
hold on
plot(tscMod.winchAltitudeCmd.Time,squeeze(tscMod.winchAltitudeCmd.Data),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Modular')
xlabel('Time, [s]')
ylabel('Winch Alt Cmd')

subplot(5,1,4)
plot(tscOrig.winchPitchCmd.Time,squeeze(tscOrig.winchPitchCmd.Data),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Original')
grid on
hold on
plot(tscMod.winchPitchCmd.Time,squeeze(tscMod.winchPitchCmd.Data),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Modular')
xlabel('Time, [s]')
ylabel('Winch Ptch Cmd')

subplot(5,1,5)
plot(tscOrig.winchRollCmd.Time,squeeze(tscOrig.winchRollCmd.Data),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Original')
grid on
hold on
plot(tscMod.winchRollCmd.Time,squeeze(tscMod.winchRollCmd.Data),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Modular')
xlabel('Time, [s]')
ylabel('Winch Roll Cmd')

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot tether tensions
figure
subplot(3,1,1)
plot(tscOrig.thr1GrndNodeFVec.Time,squeeze(sqrt(sum(tscOrig.thr1GrndNodeFVec.Data.^2,2))),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','Orig. Grnd')
grid on
hold on
plot(tscOrig.thr1AirNodeFVec.Time,squeeze(sqrt(sum(tscOrig.thr1AirNodeFVec.Data.^2,2))),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Orig. Air')
plot(tscMod.thr1GrndNodeFVec.Time,squeeze(sqrt(sum(tscMod.thr1GrndNodeFVec.Data.^2,1))),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Mod Grnd')
plot(tscMod.thr1AirNodeFVec.Time,squeeze(sqrt(sum(tscMod.thr1AirNodeFVec.Data.^2,1))),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','-','DisplayName','Mod Air')
xlabel('Time, [s]')
ylabel('Thr1 Ten [N]')
legend

subplot(3,1,2)
plot(tscOrig.thr2GrndNodeFVec.Time,squeeze(sqrt(sum(tscOrig.thr2GrndNodeFVec.Data.^2,2))),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','Orig. Grnd')
grid on
hold on
plot(tscOrig.thr2AirNodeFVec.Time,squeeze(sqrt(sum(tscOrig.thr2AirNodeFVec.Data.^2,2))),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Orig. Air')
plot(tscMod.thr2GrndNodeFVec.Time,squeeze(sqrt(sum(tscMod.thr2GrndNodeFVec.Data.^2,1))),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Mod Grnd')
plot(tscMod.thr2AirNodeFVec.Time,squeeze(sqrt(sum(tscMod.thr2AirNodeFVec.Data.^2,1))),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','-','DisplayName','Mod Air')
xlabel('Time, [s]')
ylabel('Thr2 Ten [N]')

subplot(3,1,3)
plot(tscOrig.thr3GrndNodeFVec.Time,squeeze(sqrt(sum(tscOrig.thr3GrndNodeFVec.Data.^2,2))),...
    'LineWidth',1.5,'Color','k','LineStyle','--','DisplayName','Orig. Grnd')
grid on
hold on
plot(tscOrig.thr3AirNodeFVec.Time,squeeze(sqrt(sum(tscOrig.thr3AirNodeFVec.Data.^2,2))),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--','DisplayName','Orig. Air')
plot(tscMod.thr3GrndNodeFVec.Time,squeeze(sqrt(sum(tscMod.thr3GrndNodeFVec.Data.^2,1))),...
    'LineWidth',1.5,'Color','k','LineStyle','-','DisplayName','Mod Grnd')
plot(tscMod.thr3AirNodeFVec.Time,squeeze(sqrt(sum(tscMod.thr3AirNodeFVec.Data.^2,1))),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','-','DisplayName','Mod Air')
xlabel('Time, [s]')
ylabel('Thr3 Ten [N]')

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot Pitching Moments
figure('Position',[-1.5625   -0.1824    0.5625    1.6694])
subplot(5,1,1)
plot(tscOrig.aeroMWMmtBdy.Time,tscOrig.aeroMWMmtBdy.Data(:,2),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.aeroMWMmtBdy.Time,tscMod.aeroMWMmtBdy.Data(:,2),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Main Wing [Nm]')
title('Pitching Moment Comparison')

subplot(5,1,2)
plot(tscOrig.aeroVSMmtBdy.Time,tscOrig.aeroVSMmtBdy.Data(:,2),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.aeroVSMmtBdy.Time,tscMod.aeroVSMmtBdy.Data(:,2),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Vert. Stab. [Nm]')

subplot(5,1,3)
plot(tscOrig.thr1MmtVecBdy.Time,tscOrig.thr1MmtVecBdy.Data(:,2),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr1MmtVecBdy.Time,tscMod.thr1MmtVecBdy.Data(:,2),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 1 [Nm]')

subplot(5,1,4)
plot(tscOrig.thr2MmtVecBdy.Time,tscOrig.thr2MmtVecBdy.Data(:,2),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr2MmtVecBdy.Time,tscMod.thr2MmtVecBdy.Data(:,2),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 2 [Nm]')

subplot(5,1,5)
plot(tscOrig.thr3MmtVecBdy.Time,tscOrig.thr3MmtVecBdy.Data(:,2),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr3MmtVecBdy.Time,tscMod.thr3MmtVecBdy.Data(:,2),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 3 [Nm]')

%% Plot Rolling Moment comparison
figure('Position',[-1.5625   -0.1824    0.5625    1.6694])
subplot(5,1,1)
plot(tscOrig.aeroMWMmtBdy.Time,tscOrig.aeroMWMmtBdy.Data(:,1),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.aeroMWMmtBdy.Time,tscMod.aeroMWMmtBdy.Data(:,1),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Main Wing [Nm]')
title('Rolling Moment Comparison')

subplot(5,1,2)
plot(tscOrig.aeroVSMmtBdy.Time,tscOrig.aeroVSMmtBdy.Data(:,1),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.aeroVSMmtBdy.Time,tscMod.aeroVSMmtBdy.Data(:,1),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Vert. Stab. [Nm]')

subplot(5,1,3)
plot(tscOrig.thr1MmtVecBdy.Time,tscOrig.thr1MmtVecBdy.Data(:,1),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr1MmtVecBdy.Time,tscMod.thr1MmtVecBdy.Data(:,1),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 1 [Nm]')

subplot(5,1,4)
plot(tscOrig.thr2MmtVecBdy.Time,tscOrig.thr2MmtVecBdy.Data(:,1),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr2MmtVecBdy.Time,tscMod.thr2MmtVecBdy.Data(:,1),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 2 [Nm]')

subplot(5,1,5)
plot(tscOrig.thr3MmtVecBdy.Time,tscOrig.thr3MmtVecBdy.Data(:,1),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr3MmtVecBdy.Time,tscMod.thr3MmtVecBdy.Data(:,1),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 3 [Nm]')


set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Plot Yawing Moment comparison
figure('Position',[-1.5625   -0.1824    0.5625    1.6694])
subplot(5,1,1)
plot(tscOrig.aeroMWMmtBdy.Time,tscOrig.aeroMWMmtBdy.Data(:,3),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.aeroMWMmtBdy.Time,tscMod.aeroMWMmtBdy.Data(:,3),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Main Wing [Nm]')
title('Yawing Moment Comparison')

subplot(5,1,2)
plot(tscOrig.aeroVSMmtBdy.Time,tscOrig.aeroVSMmtBdy.Data(:,3),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.aeroVSMmtBdy.Time,tscMod.aeroVSMmtBdy.Data(:,3),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Vert. Stab. [Nm]')

subplot(5,1,3)
plot(tscOrig.thr1MmtVecBdy.Time,tscOrig.thr1MmtVecBdy.Data(:,3),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr1MmtVecBdy.Time,tscMod.thr1MmtVecBdy.Data(:,3),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 1 [Nm]')

subplot(5,1,4)
plot(tscOrig.thr2MmtVecBdy.Time,tscOrig.thr2MmtVecBdy.Data(:,3),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr2MmtVecBdy.Time,tscMod.thr2MmtVecBdy.Data(:,3),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 2 [Nm]')

subplot(5,1,5)
plot(tscOrig.thr3MmtVecBdy.Time,tscOrig.thr3MmtVecBdy.Data(:,3),...
    'LineWidth',1.5,'Color','k','LineStyle','-')
hold on
grid on
plot(tscMod.thr3MmtVecBdy.Time,tscMod.thr3MmtVecBdy.Data(:,3),...
    'LineWidth',1.5,'Color',[0.5 0.5 0.5],'LineStyle','--')
xlabel('Time, [s]')
ylabel('Thr 3 [Nm]')


set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')

%% Animate the tether geometry
% close all
figure('Position',[0    0.0370    1.0000    0.8917])
axes
set(gca,'NextPlot','add')

sampleRate = 1;
timeVecOrig = 0:sampleRate:tscOrig.posVec.Time(end);
fields = fieldnames(tscOrig);
for ii= 1:length(fields)
    tscOrig.(fields{ii}) = resample(tscOrig.(fields{ii}),timeVecOrig);
end

timeVecOrig = 0:sampleRate:tscMod.posVec.Time(end);
fields = fieldnames(tscMod);
for ii= 1:length(fields)
    tscMod.(fields{ii}) = resample(tscMod.(fields{ii}),timeVecOrig);
end

N = sim_param.N;

stateVec = squeeze(tscOrig.stateVector.Data);
thr1NodePos = stateVec(15:(14 + 3*N),:);
thr2NodePos = stateVec((15 + 3*N):(14 + 6*N),:);
thr3NodePos = stateVec((15 + 6*N):(14 + 9*N),:);

thr1NodeVel = stateVec((15 + 9*N):(14 + 12*N),:);
thr2NodeVel = stateVec((15 + 12*N):(14 + 15*N),:);
thr3NodeVel = stateVec((15 + 15*N):(14 + 18*N),:);

hOrig.thr1 = plot3(...
    thr1NodePos(1:3:end,1),...
    thr1NodePos(2:3:end,1),...
    thr1NodePos(3:3:end,1),...
    'LineWidth',1.5,'Marker','o','Color','k','LineStyle','-');
hold on
grid on
hOrig.thr2 = plot3(...
    thr2NodePos(1:3:end,1),...
    thr2NodePos(2:3:end,1),...
    thr2NodePos(3:3:end,1),...
    'LineWidth',1.5,'Marker','o','Color','k','LineStyle','-');

hOrig.thr3 = plot3(...
    thr3NodePos(1:3:end,1),...
    thr3NodePos(2:3:end,1),...
    thr3NodePos(3:3:end,1),...
    'LineWidth',1.5,'Marker','o','Color','k','LineStyle','-');

axis square
axis equal

hMod.thr1 = plot3(...
    tscMod.thr1NodePos.Data(1,:,1),...
    tscMod.thr1NodePos.Data(2,:,1),...
    tscMod.thr1NodePos.Data(3,:,1),...
    'LineWidth',1.5,'Marker','o','Color',[0.5 0.5 0.5],'LineStyle','--');
hold on
grid on
hMod.thr2 = plot3(...
    tscMod.thr2NodePos.Data(1,:,1),...
    tscMod.thr2NodePos.Data(2,:,1),...
    tscMod.thr2NodePos.Data(3,:,1),...
    'LineWidth',1.5,'Marker','o','Color',[0.5 0.5 0.5],'LineStyle','--');

hMod.thr3 = plot3(...
    tscMod.thr3NodePos.Data(1,:,1),...
    tscMod.thr3NodePos.Data(2,:,1),...
    tscMod.thr3NodePos.Data(3,:,1),...
    'LineWidth',1.5,'Marker','o','Color',[0.5 0.5 0.5],'LineStyle','--');


h.title = title(sprintf('Title = %0.2f',tscOrig.posVec.Time(1)));

for ii = 1:length(tscOrig.posVec.Time)
    hOrig.thr1.XData = thr1NodePos(1:3:end,ii);
    hOrig.thr1.YData = thr1NodePos(2:3:end,ii);
    hOrig.thr1.ZData = thr1NodePos(3:3:end,ii);
    
    hOrig.thr2.XData = thr2NodePos(1:3:end,ii);
    hOrig.thr2.YData = thr2NodePos(2:3:end,ii);
    hOrig.thr2.ZData = thr2NodePos(3:3:end,ii);
    
    hOrig.thr3.XData = thr3NodePos(1:3:end,ii);
    hOrig.thr3.YData = thr3NodePos(2:3:end,ii);
    hOrig.thr3.ZData = thr3NodePos(3:3:end,ii);
    
    hMod.thr1.XData = tscMod.thr1NodePos.Data(1,:,ii);
    hMod.thr1.YData = tscMod.thr1NodePos.Data(2,:,ii);
    hMod.thr1.ZData = tscMod.thr1NodePos.Data(3,:,ii);
    
    hMod.thr2.XData = tscMod.thr2NodePos.Data(1,:,ii);
    hMod.thr2.YData = tscMod.thr2NodePos.Data(2,:,ii);
    hMod.thr2.ZData = tscMod.thr2NodePos.Data(3,:,ii);
    
    hMod.thr3.XData = tscMod.thr3NodePos.Data(1,:,ii);
    hMod.thr3.YData = tscMod.thr3NodePos.Data(2,:,ii);
    hMod.thr3.ZData = tscMod.thr3NodePos.Data(3,:,ii);
    h.title.String = sprintf('Title = %0.2f',tscOrig.posVec.Time(ii));
    drawnow
    pause
end


