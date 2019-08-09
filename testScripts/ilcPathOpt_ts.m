% Test script for the ILC path optimization -Mitchell
close all;clear;clc;format compact;

% Load the high level controller
loadComponent('basicILC');
% Load the path following controller
loadComponent('firstBuildPathFollowing');
% Load the ground station controller
loadComponent('oneDoFGSCtrlBasic');
% Load the environment
loadComponent('pathFollowingEnv');
% Load the vehicle
loadComponent('pathFollowingVhcl');
% Load the tethers
loadComponent('pathFollowingTether');
% Load the winches
loadComponent('oneWnch');
% Load the ground station
loadComponent('pathFollowingGndStn');

% Set parameters of each controller