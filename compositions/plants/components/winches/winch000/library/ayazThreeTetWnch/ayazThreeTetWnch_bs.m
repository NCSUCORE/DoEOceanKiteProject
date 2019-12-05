clear
clc
format compact

% this is the build script for creating winches using class definition
% 'winches' for a three tethered system that is being used by ayaz

% the script saves the variable 'wnch' to a 'ayazThreeTetWnch.mat'

%% Winches
%% winch variant
WINCH                 = 'winch000';

Lscale = 0.015;
maxMotorSpeedRPM = 35;
pulleyDia = 30.3e-3;
maxReleaseSpeed = (maxMotorSpeedRPM/60)*pulleyDia;
timeConstant = 0.01;
motorEfficiency = 1;
generatorEfficiency = 1;

% Create
wnch = OCT.winches;
wnch.numWinches.setValue(3,'');
wnch.build;

% Set values
wnch.winch1.maxSpeed.setValue(maxReleaseSpeed,'m/s');
wnch.winch1.timeConst.setValue(timeConstant,'s');
wnch.winch1.maxAccel.setValue(inf,'m/s^2');
wnch.winch1.motorEfficiency.setValue(motorEfficiency,'');
wnch.winch1.generatorEfficiency.setValue(generatorEfficiency,'');

wnch.winch2.maxSpeed.setValue(maxReleaseSpeed,'m/s');
wnch.winch2.timeConst.setValue(timeConstant,'s');
wnch.winch2.maxAccel.setValue(inf,'m/s^2');
wnch.winch2.motorEfficiency.setValue(motorEfficiency,'');
wnch.winch2.generatorEfficiency.setValue(generatorEfficiency,'');

wnch.winch3.maxSpeed.setValue(maxReleaseSpeed,'m/s');
wnch.winch3.timeConst.setValue(timeConstant,'s');
wnch.winch3.maxAccel.setValue(inf,'m/s^2');
wnch.winch3.motorEfficiency.setValue(motorEfficiency,'');
wnch.winch3.generatorEfficiency.setValue(generatorEfficiency,'');

% check if all the initial conditions are empty
testEmpty = NaN(1,3);
for ii = 1:3
    testEmpty(1,ii) = isempty(wnch.(strcat('winch',num2str(ii))).initLength.Value);
    
end

% scale it to lab scale before saving
% wnch.scale(Lscale,1);

%% save file in its respective directory
saveBuildFile('wnch',mfilename,'variant','WINCH');

