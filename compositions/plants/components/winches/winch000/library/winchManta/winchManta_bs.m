clear;clc
format compact

% this is the build script for creating winches using class definition
% 'winches' for the Manta Ray project 

% the script saves the variable 'wnch' to a 'winchManta.mat'

WINCH                 = 'winch000';

%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build;

% Set values
wnch.winch1.maxSpeed.setValue(1.5,'m/s');
wnch.winch1.timeConst.setValue(1,'s');
wnch.winch1.maxAccel.setValue(1,'m/s^2');
wnch.winch1.motorEfficiency.setValue(1,'')
wnch.winch1.generatorEfficiency.setValue(1,'')
wnch.winch1.LaRspeed.setValue(1,'m/s');
wnch.winch1.elevError.setValue(3,'deg');

%% save file in its respective directory
saveBuildFile('wnch',mfilename,'variant','WINCH');