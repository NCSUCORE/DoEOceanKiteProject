% Create three tethers and set properties
% Script does NOT set number of nodes
thr = OCT.tethers;
thr.setNumTethers(3,'');
thr.build;

thr.tether1.setYoungsMod(4e9,'Pa');
thr.tether1.setDampingRatio(0.05,'');
thr.tether1.setDragCoeff(0.5,'');
thr.tether1.setDensity(1300,'kg/m^3');
thr.tether1.setDiameter(0.0075,'m');

thr.tether2.setYoungsMod(4e9,'Pa');
thr.tether2.setDampingRatio(0.05,'');
thr.tether2.setDragCoeff(0.5,'');
thr.tether2.setDensity(1300,'kg/m^3');
thr.tether2.setDiameter(0.0075*sqrt(2),'m');

thr.tether3.setYoungsMod(4e9,'Pa');
thr.tether3.setDampingRatio(0.05,'');
thr.tether3.setDragCoeff(0.5,'');
thr.tether3.setDensity(1300,'kg/m^3');
thr.tether3.setDiameter(0.0075,'m');

% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'thr')

clearvars thr ans