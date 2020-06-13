
% this is the build script is the first build of a new tether model for 
% extra short lengths

TETHERS               = 'tether000';

%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(5,'');
thr.build;

% Set parameter values
thrDia = 0.0144;

thr.tether1.youngsMod.setValue(50e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.dragCoeff.setValue(0.5,'');
thr.tether1.density.setValue(1300,'kg/m^3');

thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
thr.tether1.setDiameter(thrDia,'m');


%% save file in its respective directory
saveBuildFile('thr',mfilename,'variant','TETHERS');
