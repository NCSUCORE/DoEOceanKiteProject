clear all
clc
format compact

% this is the build script for creating controller using class definition
% 'env' for a three tethered system that is being used by ayaz

% the script saves the variable 'ctrl' to a 'ayazThreeTetEnv.mat'

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'constantUniformFlow'},'FlowDensities',1000)
% env.density.setValue(1000,'kg/m^3');

%% save file in its respective directory
currentMfileLoc = fileparts(mfilename('fullpath'));

if isempty(env.water.velVec.Value)
    save(strcat(currentMfileLoc,'\ayazThreeTetEnv.mat'),'env');
else
    error('Please do not specify flow velocity in build script')
end

