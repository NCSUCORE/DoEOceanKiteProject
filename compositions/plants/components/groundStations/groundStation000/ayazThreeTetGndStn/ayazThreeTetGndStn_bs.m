clear
clc
format compact

% this is the build script for creating a ground station using class definition
% 'oneDoFStation' for a three tethered system that is being used by ayaz

% the script saves the variable 'gndStn' to a 'ayazThreeTetGndStn.mat'

%% Ground Station
GROUNDSTATION         = 'groundStation000';

% Create
gndStn = OCT.oneDoFStation;
gndStn.numTethers.setValue(3,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue(1e-2*[-10 0 0],'m');
gndStn.dampCoeff.setValue(100,'(N*m)/(rad/s)');
gndStn.thrAttch1.setPosVec([0 0 0]','m');
gndStn.thrAttch2.setPosVec([0 0 0]','m');
gndStn.thrAttch3.setPosVec([0 0 0]','m');
gndStn.setFreeSpnEnbl(false,'');

%dummy , allows the env. to work for this ground station and the other
%ground station (1DoF and 6DoF). I couldn't think of another way yet. -James
gndStn.anchThrs.numNodes.setValue(2,'')
gndStn.anchThrs.numTethers.setValue(3,'')


%% save file in its respective directory
saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');

