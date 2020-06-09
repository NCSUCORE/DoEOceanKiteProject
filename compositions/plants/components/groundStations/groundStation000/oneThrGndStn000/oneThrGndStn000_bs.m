% Creates fixed ground station with one tether attachment points
% Create
gndStn = OCT.oneDoFStation;
gndStn.setNumTethers(1,'');
gndStn.build;

% Set values
gndStn.setInertia(1,'kg*m^2');
gndStn.setPosVec([0 0 0],'m');
gndStn.setDampCoeff(1,'(N*m)/(rad/s)');
gndStn.setFreeSpnEnbl(false,'');

gndStn.thrAttch1.posVec.setValue([0 0 0]','m');

% Save the variable
save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'gndStn')
clearvars gndStn ans