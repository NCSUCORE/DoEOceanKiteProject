clear
clc
format compact

% this is the build script for creating a ground station using class definition
% 'oneDoFStation' for a three tethered system that is being used by ayaz

% the script saves the variable 'gndStn' to a 'ayazThreeTetGndStn.mat'

%% Ground Station
% Create
gndStn = OCT.oneDoFStation;
gndStn.numTethers.setValue(3,'');
gndStn.build;

% Set values
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.posVec.setValue([0 0 0],'m');
gndStn.dampCoeff.setValue(1,'(N*m)/(rad/s)');
gndStn.thrAttch1.setPosVec([-0.0254   -5.0000         0]','m');
gndStn.thrAttch2.setPosVec([6.4000         0         0]','m');
gndStn.thrAttch3.setPosVec([-0.0254    5.0000         0]','m');
gndStn.setFreeSpnEnbl(true,'');

%% save file in its respective directory
currentMfileLoc = fileparts(mfilename('fullpath'));

if isempty(gndStn.initAngPos.Value) || isempty(gndStn.initAngVel.Value)
    save(strcat(currentMfileLoc,'\ayazThreeTetGndStn.mat'),'gndStn');
else
    error('Please do not specify initial conditions in build script')
end


clearvars ans currentMfileLoc gndStn
