clear all
clc
format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'constantUniformFlow'},'FlowDensities',1000)

ENVIRONMENT = 'constantUniformFlow';

saveBuildFile('env',mfilename,'variant','ENVIRONMENT');


