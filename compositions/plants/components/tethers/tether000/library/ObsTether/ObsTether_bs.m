% clear
% clc
% format compact

% this is the build script for creating a ground station using class definition
% 'tethers' for a three tethered system that is being used by ayaz

% the script saves the variable 'thr' to a 'pathFollowingTether.mat'

TETHERS               = 'tether000';

%% Tethers
% Create
Obsthr = OCT.tethers;
Obsthr.setNumTethers(1,'');
Obsthr.setNumNodes(2,'');
Obsthr.build;

% Set parameter values
thrDia = 8.8e-3;

Obsthr.tether1.youngsMod.setValue(57e9,'Pa');
Obsthr.tether1.dampingRatio.setValue(0.75,'');
Obsthr.tether1.dragCoeff.setValue(1,'');
Obsthr.tether1.density.setValue(3550,'kg/m^3');
Obsthr.tether1.setDragEnable(true,'');
Obsthr.tether1.setSpringDamperEnable(true,'');
Obsthr.tether1.setNetBuoyEnable(true,'');
Obsthr.tether1.setDiameter(thrDia,'m');

% check if all the initial conditions are empty
testEmpty = NaN(4,3);
for ii = 1:Obsthr.numTethers.Value
testEmpty(1,ii) = isempty(Obsthr.(strcat('tether',num2str(ii))).initAirNodePos.Value);
testEmpty(2,ii) = isempty(Obsthr.(strcat('tether',num2str(ii))).initAirNodeVel.Value);
testEmpty(3,ii) = isempty(Obsthr.(strcat('tether',num2str(ii))).initGndNodePos.Value);
testEmpty(4,ii) = isempty(Obsthr.(strcat('tether',num2str(ii))).initGndNodeVel.Value);

end

%% save file in its respective directory
saveBuildFile('Obsthr',mfilename,'variant','TETHERS');