close all
clear
clc

%% Set up environment
loadComponent('pathFollowingTether');
env = ENV.env; % Create generalized high-level environment object
env.gravAccel.setValue(9.81,'m/s^2') % Set gravity
% Add a flow profile to the environment
env.addFlow({'water'},{'CNAPS'})

env.water.setStartTime(8.6857e+05,'s');
env.water.setEndTime(env.water.startTime.Value+3600*3,'s');
env.water.setDensity(1000,'kg/m^3');
env.water.setXGridPoints(1:75:150,'m');
env.water.setYGridPoints(-150:25:150,'m');


env.addFlow({'waterTurb'},{'FAUTurb'})


env.waterTurb.setIntensity(0.1,'');
env.waterTurb.setMinFreqHz(0.1,'Hz');
env.waterTurb.setMaxFreqHz(1,'Hz');
env.waterTurb.setNumMidFreqs(2,'');
env.waterTurb.setLateralStDevRatio(0.1,'');
env.waterTurb.setVerticalStDevRatio(0.1,'');
env.waterTurb.setSpatialCorrFactor(5,'');
env.waterTurb.process(env.water,'Verbose',true);

FLOWCALCULATION = 'combinedHighLowFreqData';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');

