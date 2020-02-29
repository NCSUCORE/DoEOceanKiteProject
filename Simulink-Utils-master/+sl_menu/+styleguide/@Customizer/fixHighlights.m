% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = fixHighlights(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines fixHighlights menu item

schema          = sl_action_schema();               % Initialize schema
schema.tag      = 'SimulinkUtils:FixHighlights';    % Set menu item tag
schema.label    = 'Fix persistent highlights';      % Set menu item label
schema.callback = @fixHighlightsCb;                 % Set callback function

end

function fixHighlightsCb(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium

% Find all blocks in the current system
sys             = gcs;
selectedBlocks  = find_system(sys, 'FollowLinks', 'on', 'Findall', 'on', 'LookUnderMasks', 'all', 'Type', 'block');
iBlock          = 1;

% Loop over the blocks to find the ones where highlight colors are stuck
while iBlock <= numel(selectedBlocks)
    selectedBlock = selectedBlocks(iBlock);
    
    if (strcmp(get(selectedBlock, 'ForegroundColor'), 'red') && strcmp(get(selectedBlock, 'BackgroundColor'), 'yellow')) ...
            || (strcmp(get(selectedBlock, 'ForegroundColor'), 'blue') && strcmp(get(selectedBlock, 'BackgroundColor'), 'cyan'))
        set(selectedBlock, 'ForegroundColor', 'black');
        set(selectedBlock, 'BackgroundColor', 'white');
    end
    
    iBlock = iBlock + 1;
end

end
