% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = matchSizeOfBlocks(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines matchSizeOfBlocks menu item

schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:MatchSize';    % Set menu item tag
schema.label        = 'Match Size';                 % Set menu item label
schema.accelerator  = 'CTRL+ALT+M';                 % Set accelerator/short-cut
schema.callback     = @matchSizeOfBlocksCb;         % Set callback function

end

function matchSizeOfBlocksCb(callbackInfo)
% Callback function: matchSizeOfBlocks menu item

% Resize selected blocks to the size of the highlighted block
callbackInfo.studio.App.getActiveEditor().resizeItems('both');

end
