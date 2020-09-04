
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
thrDia = 0.0115;

thr.tether1.setYoungsMod(40e9,'Pa');
thr.tether1.setDampingRatio(1,'');
thr.tether1.setDragCoeff(0.5,'');
thr.tether1.setDensity(1300,'kg/m^3');

thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
thr.tether1.setDiameter(thrDia,'m');

thr.tether1.setMaxLength(400,'m');
thr.tether1.setMinLinkLength(1,'m');
thr.tether1.setMinLinkDeviation(.01,'m');
thr.tether1.setMinSoftLength(0,'m');

thr.tether1.minMaxLength.upperLimit.setValue(425,'')
thr.tether1.minMaxLength.lowerLimit.setValue(.00000000001,'')

%% save file in its respective directory
saveBuildFile('thr',mfilename,'variant','TETHERS');
