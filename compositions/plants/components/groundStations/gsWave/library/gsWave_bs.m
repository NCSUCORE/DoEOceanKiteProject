GROUNDSTATION         = 'gsWave';
% this is the build script for creating a ground station using class definition
% 'station' for a three tethered system that is being used by ayaz

% the script saves the variable 'gndStn' to a 'prescribedGndStn.mat'
%% Ground Station
% Create
gndStn = OCT.prescribedGndStation001;
gndStn.numTethers.setValue(1,'');
gndStn.build;

% Set values
%gndStn.inertia.setValue(1,'kg*m^2');
gndStn.pathVar.setValue(1,'');
gndStn.waveAmplitude.setValue(2,'m');
gndStn.wavePeriod.setValue(8,'s');

gndStn.initPosVecGnd.setValue([0 0 0]','m');
gndStn.initEulAng.setValue([0;0;0],'rad');
gndStn.thrAttach.setPosVec([0 0 0]','m');
gndStn.lumpedMassPositionMatrixBdy.setValue([0,0,0]','m');

%dummy , allows the env. to work for this ground station and the other
%ground station (1DoF and 6DoF). I couldn't think of another way yet. -James
gndStn.anchThrs.numNodes.setValue(2,'')
gndStn.anchThrs.numTethers.setValue(1,'')
%% save file in its respective directory
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');

