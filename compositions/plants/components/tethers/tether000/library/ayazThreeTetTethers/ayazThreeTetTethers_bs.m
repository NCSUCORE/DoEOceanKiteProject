clear
clc
format compact

% this is the build script for creating a ground station using class definition
% 'tethers' for a three tethered system that is being used by ayaz

% the script saves the variable 'thr' to a 'ayazThreeTetTethers.mat'

%% Tethers

TETHERS               = 'tether000';

% Create
thr = OCT.tethers;
thr.setNumTethers(3,'');
thr.setNumNodes(2,'');
thr.build;

% Set parameter values
thrDia = 0.0075;

thr.tether1.youngsMod.setValue(4e9,'Pa');
thr.tether1.dampingRatio.setValue(0.05,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(false,'');
thr.tether1.setDiameter(thrDia,'m');

thr.tether2.youngsMod.setValue(4e9,'Pa');
thr.tether2.dampingRatio.setValue(0.05,'');
thr.tether2.dragCoeff.setValue(0.5,'');
thr.tether2.density.setValue(1300,'kg/m^3');
thr.tether2.setDragEnable(true,'');
thr.tether2.setSpringDamperEnable(true,'');
thr.tether2.setNetBuoyEnable(false,'');
thr.tether2.setDiameter(thrDia*sqrt(2),'m');

thr.tether3.youngsMod.setValue(4e9,'Pa');
thr.tether3.dampingRatio.setValue(0.05,'');
thr.tether3.dragCoeff.setValue(0.5,'');
thr.tether3.density.setValue(1300,'kg/m^3');
thr.tether3.setDragEnable(true,'');
thr.tether3.setSpringDamperEnable(true,'');
thr.tether3.setNetBuoyEnable(false,'');
thr.tether3.setDiameter(thrDia,'m');

% check if all the initial conditions are empty
testEmpty = NaN(4,3);
for ii = 1:3
testEmpty(1,ii) = isempty(thr.(strcat('tether',num2str(ii))).initAirNodePos.Value);
testEmpty(2,ii) = isempty(thr.(strcat('tether',num2str(ii))).initAirNodeVel.Value);
testEmpty(3,ii) = isempty(thr.(strcat('tether',num2str(ii))).initGndNodePos.Value);
testEmpty(4,ii) = isempty(thr.(strcat('tether',num2str(ii))).initGndNodeVel.Value);

end

%% save file in its respective directory
saveBuildFile('thr',mfilename,'variant','TETHERS');
