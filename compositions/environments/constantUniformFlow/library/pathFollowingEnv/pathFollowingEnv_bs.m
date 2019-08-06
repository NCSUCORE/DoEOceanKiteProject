clear all
clc
format compact

% this is the build script for creating controller using class definition
% 'env' for a three tethered system that is being used by ayaz

% the script saves the variable 'ctrl' to a 'ayazThreeTetEnv.mat'

%% Set up environment
ENVIRONMENT           = 'constantUniformFlow';

% Create
env = ENV.env;
env.addFlow({'water'},{'constantUniformFlow'},'FlowDensities',1000)
% env.density.setValue(1000,'kg/m^3');

%% save file in its respective directory
saveBuildFile('env',mfilename,'variant','ENVIRONMENT');

