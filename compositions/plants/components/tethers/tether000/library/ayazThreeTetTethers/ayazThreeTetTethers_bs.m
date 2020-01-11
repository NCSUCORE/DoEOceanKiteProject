% clear
clc
format compact

% this is the build script for creating a ground station using class definition
% 'tethers' for a three tethered system that is being used by ayaz

% the script saves the variable 'thr' to a 'ayazThreeTetTethers.mat'

%% Tethers
TETHERS               = 'tether000';

% scaling factor for lab scale testing
Lscale = 0.015;

% Create
thr = OCT.tethers;
thr.setNumTethers(3,'');
thr.setNumNodes(3,'');
thr.build;

% Set parameter values
thrDia = 0.3e-3;
thrYoungs = 50e9;
thrDamping = 0.05;
thrDensity = 1300;
thrDragCoeff = 1*1;
dragSwitch = true;
buoySwitch = true;

thr.tether1.youngsMod.setValue(thrYoungs,'Pa');
thr.tether1.dampingRatio.setValue(thrDamping,'');
thr.tether1.dragCoeff.setValue(thrDragCoeff,'');
thr.tether1.density.setValue(thrDensity,'kg/m^3');
thr.tether1.setDragEnable(dragSwitch,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(buoySwitch,'');
thr.tether1.setDiameter(thrDia,'m');

thr.tether2.youngsMod.setValue(thrYoungs,'Pa');
thr.tether2.dampingRatio.setValue(thrDamping,'');
thr.tether2.dragCoeff.setValue(thrDragCoeff,'');
thr.tether2.density.setValue(thrDensity,'kg/m^3');
thr.tether2.setDragEnable(dragSwitch,'');
thr.tether2.setSpringDamperEnable(true,'');
thr.tether2.setNetBuoyEnable(buoySwitch,'');
thr.tether2.setDiameter(thrDia,'m');

thr.tether3.youngsMod.setValue(thrYoungs,'Pa');
thr.tether3.dampingRatio.setValue(thrDamping,'');
thr.tether3.dragCoeff.setValue(thrDragCoeff,'');
thr.tether3.density.setValue(thrDensity,'kg/m^3');
thr.tether3.setDragEnable(dragSwitch,'');
thr.tether3.setSpringDamperEnable(true,'');
thr.tether3.setNetBuoyEnable(buoySwitch,'');
thr.tether3.setDiameter(thrDia,'m');

% check if all the initial conditions are empty
testEmpty = NaN(4,3);
for ii = 1:3
testEmpty(1,ii) = isempty(thr.(strcat('tether',num2str(ii))).initAirNodePos.Value);
testEmpty(2,ii) = isempty(thr.(strcat('tether',num2str(ii))).initAirNodeVel.Value);
testEmpty(3,ii) = isempty(thr.(strcat('tether',num2str(ii))).initGndNodePos.Value);
testEmpty(4,ii) = isempty(thr.(strcat('tether',num2str(ii))).initGndNodeVel.Value);

end

% scale it down before saving
% thr.scale(Lscale,1);

%% save file in its respective directory
saveBuildFile('thr',mfilename,'variant','TETHERS');
