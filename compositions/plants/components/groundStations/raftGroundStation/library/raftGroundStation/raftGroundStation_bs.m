% Creates fixed ground station with one tether attachment points
% Create
gndStn = OCT.threeDoFStation;
GROUNDSTATION = 'raftGroundStation';


% PARAMETERS CALLED FROM TS





% Save the variable
% save(fullfile(fileparts(which(mfilename)),strrep(mfilename,'_bs','')),'gndStn')
saveFile = saveBuildFile('gndStn',mfilename,'variant','GROUNDSTATION');
% save(saveFile,'PATHGEOMETRY','-append')