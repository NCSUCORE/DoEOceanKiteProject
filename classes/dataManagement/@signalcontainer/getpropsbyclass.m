function sigNames = getpropsbyclass(obj,clssNms)
%% Get a cell array of property names filtered by the class of the property
if isa(clssNms,'char')
    clssNms = {clssNms};
elseif ~isa(clssNms,'cell')
    error('Input must be a cell array of strings or a string')
end
sigNames = properties(obj);
msk = zeros(numel(sigNames,1));
for ii = 1:numel(clssNms)
    msk = or(msk ,cellfun(@(x)isa(obj.(x),clssNms{ii}),sigNames));
end
sigNames = sigNames(msk);
end