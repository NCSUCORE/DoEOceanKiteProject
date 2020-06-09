function results = avlParseFT(raw)
% Function to parse the output of the FT command

startString = 'Configuration:';
endString = ' ---------------------------------------------------------------\n ---------------------------------------------------------------';
startIndex = regexp(raw,startString);
endIndex   = regexp(raw,endString);
raw = raw(startIndex:endIndex);

file = textscan(raw,...
    '%s', 'delimiter', {'\n','\t',' '},'whitespace', '');
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