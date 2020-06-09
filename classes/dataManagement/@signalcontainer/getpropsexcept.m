function sigNames = getpropsexcept(obj,excptPrpNms)
%% Get property names except those with the specified names
if isa(excptPrpNms,'char')
    excptPrpNms = {excptPrpNms};
elseif ~isa(excptPrpNms,'cell')
    error('Input must be a cell array of strings or a string')
end
sigNames = properties(obj);
msk = zeros(numel(sigNames,1));
for ii = 1:numel(excptPrpNms)
    msk = or(msk ,cellfun(@(x)strcmp(x,excptPrpNms{ii}),sigNames));
end
sigNames = sigNames(~msk);
end