function saveAllPlots(varargin)
p = inputParser;
addParameter(p,'Folder',[],@(x) exist(x, 'dir'))
parse(p,varargin{:})

% If the user didnt provide a folder name, use a default name
if isempty(p.Results.Folder)
    folder = datestr(now,'ddmmmyy_HHMMSS');
    folder = fullfile(fileparts(which('OCTModel')),'output',folder);
else
    folder =p.Results.Folder;
end
% Append full full path


% If it doesn't exist, create it (and subfolders)
if ~exist(folder, 'dir')
    mkdir(folder)
end

figHandles = findobj('Type', 'figure');
for ii = 1:length(figHandles)
    fileName = regexp(figHandles(ii).Name,'[\w*]','match');
    fileName = [fileName{:}];
    if isempty(fileName)
        fileName = sprintf('Fig%d',ii);
    end
    savePlot(figHandles(ii),folder,fileName)
end

end