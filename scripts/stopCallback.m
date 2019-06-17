% Notify the user, and parse logsout object
fprintf('\nRunning stopcallback.m \nParsing logsout\n')
parseLogsout

% Create folder name to dump all results
folderName = datestr(now,'ddmmmyy_HHMMSS');
folderName = fullfile(fileparts(which('OCTModel')),'output',folderName);
% If the folder doesn't exist, create it
if ~(7==exist(fullfile(folderName),'dir'))
    fprintf('Creating directory  %s\n',folderName)
    mkdir(fullfile(folderName))
end

% Save data
fprintf('Saving all data to workspace.mat \n')
save('workspace.mat')

% Plot Everything
fprintf('Running all plot script in ./scripts/plotScripts \n')
plotEverything

% Get handles to all the figures
fprintf('Saving all resulting plots. \n')
figHandles = findobj('Type', 'figure');
for ii = 1:length(figHandles)
    fileName = regexp(figHandles(ii).Name,'[\w*]','match');
    fileName = [fileName{:}];
    savePlot(figHandles(ii),folderName,fileName)
end
fprintf('Done. \n')