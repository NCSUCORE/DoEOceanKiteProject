clear
clc
format compact

% this is the build script for creating a ground station using class definition
% 'station' for a three tethered system that is being used by ayaz

% the script saves the variable 'gndStn' to a 'pathFollowingGndStn.mat'
%% Ground Station
% Create
gndStn = OCT.station;
gndStn.numTethers.setValue(3,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad/s)');
gndStn.thrAttch1.posVec.setValue([0 0 0]','m');
gndStn.freeSpnEnbl.setValue(false,'');

%% save file in its respective directory
currentMfileLoc = fileparts(mfilename('fullpath'));

if isempty(gndStn.initAngPos.Value) || isempty(gndStn.initAngVel.Value)
    save(strcat(currentMfileLoc,'\pathFollowingGndStn.mat'),'gndStn');
else
    error('Please do not specify initial conditions in build script')
end

