function results = avlLoadResults(fileName)
%% loadAVLResults(fileName) file to load output files from AVL
% Returns output as a structure with fieldnames that match the fieldnames
% of the file, subject to variable naming conventions.  Note that
% apostrophes and backslashes (commonly used in files) will be replaced
% with hexidecimal character codes (eg 0x2F etc.)

% I have only validated that this works on the output of the FT command in
% AVL.  I have not checked that any fields are not being accidentally
% redundantly written (due to redundant variable names) in the results of
% the ST or SB commands from AVL. -MC

% Get base path to directory containing results
basePath = fullfile(fileparts(which('avl.exe')),'designLibrary');
% Open the file
fid = fopen(fullfile(basePath,fileName),'r');
% Read in all the text
file = textscan(fid,...
    '%s', 'delimiter', {'\n','\t',' '},'whitespace', '');
% Close the file
fclose(fid);
% Get the first cell, since for some reason it's returning a nested call
% array
file = file{1};
% Get all non-empty cells
file = file(~cellfun('isempty',file));
% Get indices to all cells containing an equal sign
equalCells = find(cellfun(@(x) strcmpi(x,'='),file));
% For each cell containing an equal sign,
% Create field in output struct with name equal to that before the equal
% sign, and store value equal to the string after the equal sign.
for ii = 1:length(equalCells)
    fieldName = genvarname(file{equalCells(ii)-1});
    fieldValue = str2double(file{equalCells(ii)+1});
    results.(fieldName) = fieldValue;
end
end