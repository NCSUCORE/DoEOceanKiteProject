
% Test script to test Ayaz's three tether + aero surfaces model
close all;clear;clc
format compact
% Initialize the highest level model
OCTModel_init

% Initialize all of ayaz's parameters
ayazParams_init


ayazPlant_init

duration_s = 10;

ENVIRONMENT = 1;
CONTROLLER = 2;
PLANT = 2;

createAyazPlantBus
createAyazFlowEnvironmentBus
createaAyazCtrlBus


sim('OCTModel')
tsc = parseLogsout;

tsc.eulerAngles.plot
