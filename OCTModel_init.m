% Script to initilize the OCTModel
fprintf('\nInitializing OCTModel')
close all;clear;clc;

fprintf('\nInitializing Plant')
plant_init

fprintf('\nInitializing Controller')
controller_init

fprintf('\nInitializing Environment')
environment_init

fprintf('\nInitializing Simulation Parameters')
simParameters_init

% fprintf('\nOpening main model')
% open('OCTModel.slx')

fprintf('\nDone\n')