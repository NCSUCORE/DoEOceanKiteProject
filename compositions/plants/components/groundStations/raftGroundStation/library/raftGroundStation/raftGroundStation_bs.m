% Creates fixed ground station with one tether attachment points
% Create
gndStn = OCT.threeDoFStation;
GROUNDSTATION = 'raftGroundStation';
% Set values
gndStn.mass.setValue(1,'kg');
gndStn.inertia.setValue(1,'kg*m^2');
gndStn.initPos.setValue([0 0 0],'m');
gndStn.initVel.setValue([0 0 0],'m/s');
gndStn.initAngPos.setValue([0 0 0],'rad');
gndStn.initAngVel.setValue([0 0 0],'rad/s');

% Save the variable
% save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'gndStn')
saveFile = saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
save(saveFile,'PATHGEOMETRY','-append')