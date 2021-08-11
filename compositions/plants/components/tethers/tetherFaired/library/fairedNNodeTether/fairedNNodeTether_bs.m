%%  This build script is for a multi-node tether with fairings
TETHERS               = 'tetherFaired';

%% Tethers
% Create
thr = OCT.tethers;
thr.setNumTethers(1,'');
thr.setNumNodes(7,'');
thr.build('TetherClass','tetherF');

% Set parameter values
thr.tether1.setDiameter(18e-3,'m');
thr.tether1.nomDragCoeff.setValue(1.2,'');
thr.tether1.fairedDragCoeff.setValue(.1,'');
thr.tether1.fairedLength.setValue(100,'m');
thr.tether1.maxThrLength.setValue(600,'m');
thr.tether1.youngsMod.setValue(57e9,'Pa');
thr.tether1.dampingRatio.setValue(0.75,'');
thr.tether1.density.setValue(1500,'kg/m^3');
thr.tether1.setDragEnable(true,'');
thr.tether1.setSpringDamperEnable(true,'');
thr.tether1.setNetBuoyEnable(true,'');
thr.tether1.transVoltage.setValue(1000,'V');
% check if all the initial conditions are empty
testEmpty = NaN(4,3);
for ii = 1:thr.numTethers.Value
testEmpty(1,ii) = isempty(thr.(strcat('tether',num2str(ii))).initAirNodePos.Value);
testEmpty(2,ii) = isempty(thr.(strcat('tether',num2str(ii))).initAirNodeVel.Value);
testEmpty(3,ii) = isempty(thr.(strcat('tether',num2str(ii))).initGndNodePos.Value);
testEmpty(4,ii) = isempty(thr.(strcat('tether',num2str(ii))).initGndNodeVel.Value);

end

%% save file in its respective directory
saveBuildFile('thr',mfilename,'variant','TETHERS');