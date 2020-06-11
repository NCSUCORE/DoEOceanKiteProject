
% this is the build script is the first build of a new tether model for 
% extra short lengths

TETHERS               = 'tether001';

%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(5,'');
thr.build('TetherClass','tether001');

% Set parameter values
thrDia = 0.0144;

thr.tether1.setYoungsMod(50e9,'Pa');
thr.tether1.setDampingRatio(0.75,'');
thr.tether1.setDragCoeff(0.5,'');
thr.tether1.setDensity(1300,'kg/m^3');

thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
thr.tether1.setDiameter(thrDia,'m');

thr.tether1.setMaxLength(400,'m');

%% save file in its respective directory
saveBuildFile('thr',mfilename,'variant','TETHERS');
