% Create three tethers and set properties
% Script does NOT set number of nodes
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.build;

thr.tether1.setYoungsMod(12e9,'Pa');
thr.tether1.setDampingRatio(0.05,'');
thr.tether1.setDragCoeff(0.5,'');
thr.tether1.setDensity(1300,'kg/m^3');
thr.tether1.setDiameter(0.0075,'m');

% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'thr')
clearvars thr ans