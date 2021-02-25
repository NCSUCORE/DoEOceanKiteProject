clear all;clc;format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'steppedLateralFlow'},'FlowDensities',1000);


%% set variants
FLOWCALCULATION = 'steppedLateralFlow';
ENVIRONMENT     = 'environmentDOE';

%% save
saveBuildFile('env',mfilename,'variant',["FLOWCALCULATION","ENVIRONMENT"]);
