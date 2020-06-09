% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function setFilters(cm)

cm.addCustomFilterFcn('SimulinkUtils:SF:AutoConnect', @checkTwoSFBlocks);
cm.addCustomFilterFcn('SimulinkUtils:SF:MatchSize', @sl_menu.Customizer.checkSFBlocks);

end

function state = checkTwoSFBlocks(callbackInfo) %#ok<INUSD>
% Check if two Stateflow blocks are selected.

selectedBlocks = sfgco();

if length(selectedBlocks) == 2 ...
        && all(ismember(arrayfun(@class, selectedBlocks, 'UniformOutput', false), {'Stateflow.State', 'Stateflow.Junction'}))
    state = 'Enabled';
else
    state = 'Disabled';
end

end
