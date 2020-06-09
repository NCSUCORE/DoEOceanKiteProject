function parsedStruct = avlParseAtEqual(raw);
% function that takes a raw string, splits at equal signs and creates
% struct from results
raw = textscan(raw,...
    '%s', 'delimiter', {'\n','\t',' '},'whitespace', '');
% Get the first cell, since for some reason it's returning a nested call
% array
raw = raw{1};
% Get all non-empty cells
raw = raw(~cellfun('isempty',raw));
% Get indices to all cells containing an equal sign
equalCells = find(cellfun(@(x) strcmpi(x,'='),raw));
% For each cell containing an equal sign,
% Create field in output struct with name equal to that before the equal
% sign, and store value equal to the string after the equal sign.
for ii = 1:length(equalCells)
    fieldName = genvarname(raw{equalCells(ii)-1});
    fieldValue = str2double(raw{equalCells(ii)+1});
    parsedStruct.(fieldName) = fieldValue;
end
end
