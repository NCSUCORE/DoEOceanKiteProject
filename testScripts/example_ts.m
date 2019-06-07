% Example script to run the model
% Created 6/7/2019 -MC
close all;clear;clc;

% Initialize model variants
OCTModel_init

% Select the apropriate variants
CONTROLLER  = 'threeTetherThreeSurfaceCtrl';
PLANT       = 'modularPlant';
ENVIRONMENT = 'constantUniformFlow';

% Initialize the appropriate busses for the variants we selected
createThreeTetherThreeSurfaceCtrlBus
createModularPlantBus
createConstantUniformFlowEnvironmentBus

% Create all constants necessary for simulation.
% At the time of writing, this was accomplished
% by the script ./compositions/plants/modularPlant/modularPlant_init.m
% however, this will very likely change in the future
modularPlant_init

% Set the simulation duration, in seconds.
duration_s = 100; 

% The selected controller requires three timeseries objects to specify the
% three setpoints, altitude, roll, and pitch.  These are not initialized by
% the script above
timeVec = 0:0.01:duration_s;
set_alt   = timeseries(200*ones(size(timeVec)),timeVec);
set_pitch = timeseries(7*ones(size(timeVec)),timeVec);
set_roll  = timeseries(0*ones(size(timeVec)),timeVec);

% Simulate the model
sim('OCTModel')

% Data is logged in the logsout variable in the worspace.  The function
% ./functions/parseLogsout.m takes all the logged data and puts it into a
% structure called tsc where the field names match the signal names
parseLogsout;

% As an example, plot some data
tsc.posVec.plot
