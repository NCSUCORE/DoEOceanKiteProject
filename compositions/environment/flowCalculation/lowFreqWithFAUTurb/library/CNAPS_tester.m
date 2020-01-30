% close all
% clear
% clc
% 
% %% Set up environment
% loadComponent('pathFollowingTether');
% env = ENV.env; % Create generalized high-level environment object
% env.gravAccel.setValue(9.81,'m/s^2'); % Set gravity
% % Add a flow profile to the environment
% env.addFlow({'water'},{'ADCP'});
% 
% env.water.setStartTime(3600*459,'s');
% env.water.setEndTime(env.water.startTime.Value+3600*3,'s');
% env.water.setDensity(1000,'kg/m^3');
% env.water.setXGridPoints(0:75:150,'m');
% env.water.setYGridPoints(-150:25:150,'m');
% 
% % env.water.setDepthMin(13,''); %minimum index, not meters
% % env.water.setDepthMax(60,'');  %maximum index, not meters
% % env.water = env.water.setStartADCPTime(3600*459,'s');
% % env.water =   env.water.setEndADCPTime(3600*461,'s');
% % env.water.yBreakPoints.setValue(-140:10:140,'m');
% 
% env.addFlow({'waterTurb'},{'FAUTurb'});
% 
% 
% env.waterTurb.setIntensity(0.1,'');
% env.waterTurb.setMinFreqHz(0.1,'Hz');
% env.waterTurb.setMaxFreqHz(1,'Hz');
% env.waterTurb.setNumMidFreqs(4,'');
% env.waterTurb.setLateralStDevRatio(0.1,'');
% env.waterTurb.setVerticalStDevRatio(0.1,'');
% env.waterTurb.setSpatialCorrFactor(5,'');
% env.waterTurb.process(env.water,'Verbose',true);
% 
% FLOWCALCULATION = 'combinedHighLowFreqData';
% saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');

close all
clear
clc

%% Set up environment
loadComponent('pathFollowingTether');
env = ENV.env; % Create generalized high-level environment object
env.gravAccel.setValue(9.81,'m/s^2'); % Set gravity
% Add a flow profile to the environment
env.addFlow({'water'},{'CNAPS'});

env.water.setStartTime(8.6857e+05,'s');
env.water.setEndTime(env.water.startTime.Value+3600*3,'s');
env.water.setDensity(1000,'kg/m^3');
env.water.setXGridPoints(0:50:200,'m');
env.water.setYGridPoints(-150:10:150,'m');

env.addFlow({'waterTurb'},{'FAUTurb'});

env.waterTurb.setIntensity(0.1,'');
env.waterTurb.setMinFreqHz(0.1,'Hz');
env.waterTurb.setMaxFreqHz(1,'Hz');
env.waterTurb.setNumMidFreqs(4,'');
env.waterTurb.setLateralStDevRatio(0.1,'');
env.waterTurb.setVerticalStDevRatio(0.1,'');
env.waterTurb.setSpatialCorrFactor(5,'');
env.waterTurb.process(env.water,'Verbose',true);

FLOWCALCULATION = 'combinedHighLowFreqData';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');

