% Script to build a single winch based on the model from Uo Maryland
clear;clc;format compact
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

wnch.winch1.setDrumRadius(0.5,'m');
wnch.winch1.setDrumInertia(100,'kg*m^2');
wnch.winch1.setInitReleaseRate(0,'m/s');
wnch.winch1.setGearRatio(1/2.5,'');
wnch.winch1.setNumOfGearPairs(4,'');


%% save file in its respective directory
saveBuildFile('wnch',mfilename,'variant','WINCH');