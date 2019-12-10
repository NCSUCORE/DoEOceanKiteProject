clear all;clc;format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'constXYZT'},'FlowDensities',995);

FLOWCALCULATION = 'constXYZT';

saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
