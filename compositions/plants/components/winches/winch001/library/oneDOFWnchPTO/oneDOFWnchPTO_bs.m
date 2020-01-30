clear
clc
format compact

% this is the build script for creating winches using class definition
% 'winches' for a three tethered system that is being used by ayaz

% the script saves the variable 'wnch' to a 'pathFollowingWinch.mat'

WINCH                 = 'winch001';

%% Winches
% Create
wnch = OCT.winches;
wnch.numWinches.setValue(1,'');
wnch.build('WinchClass','umWinch');

% Set values
wnch.winch1.maxSpeed.setValue(1e6,'m/s');
wnch.winch1.timeConst.setValue(1,'s');
wnch.winch1.maxAccel.setValue(1e6,'m/s^2');
wnch.winch1.rectifierEfficiency.setValue(0.96^2,'');
wnch.winch1.inverterEfficiency.setValue(0.96^2,'');
wnch.winch1.statorResistanceGen.setValue(0.04,'');
wnch.winch1.rotorMagneticFluxGen.setValue(0.3,'');
wnch.winch1.frictionCoefficiantGen.setValue(15/15000,'');
wnch.winch1.numPolePairsGen.setValue(40,'');
wnch.winch1.statorResistanceMot.setValue(0.036,'');
wnch.winch1.rotorMagneticFluxMot.setValue(0.3,'');
wnch.winch1.frictionCoefficiantMot.setValue(15/15000,'');
wnch.winch1.numPolePairsMot.setValue(40,'');


%% save file in its respective directory
saveBuildFile('wnch',mfilename,'variant','WINCH');