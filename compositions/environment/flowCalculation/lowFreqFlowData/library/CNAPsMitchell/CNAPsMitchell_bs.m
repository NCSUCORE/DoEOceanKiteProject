close all;clear;clc

%% Set up environment
loadComponent('pathFollowingTether');
env = ENV.env; % Create generalized high-level environment object
env.gravAccel.setValue(9.81,'m/s^2') % Set gravity
% Add a flow profile to the environment
env.addFlow({'water'},{'CNAPS'})

env.water.setStartTime(8.6857e+05,'s');
env.water.setEndTime(env.water.startTime.Value+3600*3,'s');
env.water.setDensity(1000,'kg/m^3');
env.water.setXGridPoints(0:1,'m');
env.water.setYGridPoints(-1:1,'m');

FLOWCALCULATION = 'lowFreqFlowData';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
