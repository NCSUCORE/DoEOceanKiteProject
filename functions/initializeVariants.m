function initializeVariants(name)

% This script works by searching the apppriate folder, then creating a
% variant object in the base workspace for each of the found directories.
basePath = fileparts(which('OCTProject.prj'));

files = dir(fullfile(basePath,'compositions',name)); % Search the folder
files = files([files.isdir]); % Get directories
files = files(3:end); % Delete first two which are always '.' and '..'
% Code to exclude the example file if you want to remove it later
% files = files(~strcmpi({files.name},'example'));

for ii = 1:length(files)
    % Create the Simulink.Variant object
    evalin('base',...
        sprintf('VSS_%s_%s = Simulink.Variant(''strcmpi(%s,''''%s'''')'');',...
        name(1:end-1),files(ii).name,upper(name(1:end-1)),files(ii).name));
    % If statement that sets the "default" active controller to the example
    % controller
    if ii == 1
       evalin('base',sprintf('%s = ''%s'';',upper(name(1:end-1)),files(ii).name))
    end
end

end