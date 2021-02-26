clear
clc
format compact

% this is the build script for creating winches using class definition
% 'winches' for a three tethered system that is being used by ayaz
% the script saves the variable 'wnch' to a 'pathFollowingWinch.mat'

WINCH                 = 'winch000';

%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build;

% Set values
wnch.winch1.maxSpeed.setValue(3,'m/s');
wnch.winch1.timeConst.setValue(1,'s');
wnch.winch1.maxAccel.setValue(1e6,'m/s^2');
wnch.winch1.motorEfficiency.setValue(0.8,'')
wnch.winch1.generatorEfficiency.setValue(1.2,'')

%% save file in its respective directory
saveBuildFile('wnch',mfilename,'variant','WINCH');