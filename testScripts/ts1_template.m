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
duration_s = 100;

% Set active variants
ENVIRONMENT = 'ayazFlow';
CONTROLLER  = 'ayazController';
PLANT       = 'ayazPlant';

% Setup setpoint timeseries
time = 0:0.1:duration_s;
set_pitch = set_pitch*ones(size(time));
set_roll = set_roll*ones(size(time));
set_alt = set_alti*ones(size(time));

set_pitch = timeseries(set_pitch,time);
set_roll  = timeseries(set_roll, time);
set_alt   = timeseries(set_alt,time);

% Run simulation
sim('OCTModel')

% Parse out the results
tsc = parseLogsout;

% Plot some things
tsc.eulerAngles.plot
