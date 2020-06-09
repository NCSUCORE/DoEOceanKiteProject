% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function state = checkSFBlocks(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stage
% Check if one or more states/junctions are selected.

selectedBlocks = sfgco();

if length(selectedBlocks) >= 1 ...
        && all(ismember(arrayfun(@class, selectedBlocks, 'UniformOutput', false), {'Stateflow.State', 'Stateflow.Junction'}))
    state = 'Enabled';
else
    state = 'Disabled';
end

end
