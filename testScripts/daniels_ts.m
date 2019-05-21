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
duration_s = 200;

% Set active variants
ENVIRONMENT = 'ayazFlow';
CONTROLLER  = 'ayazController';
PLANT       = 'ayazPlant';
%% Setup setpoint timeseries
time = 0:0.1:duration_s;
set_pitch = 15*(pi/180)*ones(size(time));
set_roll = 0*ones(size(time));
set_yaw = 0*ones(size(time));
% set_roll = 15*square(time*2*pi/200);
% set_yaw = 30*square(time*2*pi/200);
set_alt = 200*ones(size(time));

set_pitch = timeseries(set_pitch,time);
set_roll  = timeseries(set_roll, time);
set_alt   = timeseries(set_alt,time);
set_yaw   = timeseries(set_yaw,time);
%% Elevator Elevon Control (off)
kp_elev = 0*1*10;
ki_elev = 0.0*kp_elev;
kd_elev = 0*sqrt(k_scale)*3*kp_elev;
%% Aileron Elevon Control (off)
kp_aileron = 0*1*4;
ki_aileron = 0.0*kp_aileron;
kd_aileron = 0*2*sqrt(k_scale)*kp_aileron;
%% altitude winch control(off)
Kp_z = 0;
Ki_z = 0;
Kd_z = 0;
%% pitch winch control(on)
Kp_p = 1*sqrt(k_scale)*1.5*0.5;
Ki_p = 0.0;
Kd_p = 2.5*sqrt(k_scale)*Kp_p;
%% roll winch control(on)
Kp_r = 1*(k_scale)*(Kp_p/(0.5*AR));
Ki_r = 0.0;
Kd_r = 2*sqrt(k_scale)*Kp_r;
%% yaw-motor control (on)
kd_yaw = 10^6;
kp_yaw = 10^5;
ki_yaw = 10^4*0;
tau_yaw = 2;

%% Run simulation
try
    sim_monitor_start('OCTModel')
    sim('OCTModel')
    sim_monitor_end('OCTModel')
catch
    sim_monitor_end('OCTModel')
end
%% Parse out the results
tsc = parseLogsout;
tsc.eulerAngles.Data=tsc.eulerAngles.Data*180/pi;

% Plot some things
tsc.posVec.plot
figure
tsc.velocityVec.plot
figure
tsc.eulerAngles.plot
