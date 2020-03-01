% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = makeConstantsOrange(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines makeConstantsOrange menu item
 
schema              = sl_action_schema();               % Initialize schema
schema.tag          = 'SimulinkUtils:OrangeConstants';  % Set menu item tag
schema.label        = 'Make Constants Orange';          % Set menu item label
schema.accelerator  = 'CTRL+SHIFT+O';                   % Set accelerator/short-cut
schema.callback     = @makeConstantsOrangeCb;           % Set callback function 

end

function makeConstantsOrangeCb(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Callback function: makeConstantsOrange menu item
 
% Find all blocks in the current system (gcs) of type 'Constant' 
blocks = find_system(gcs, 'blocktype', 'Constant');
 
% Loop over all Constant blocks and change the properties 
for iBlock = 1 : length(blocks)
    block = blocks{iBlock};                        % select item from cell array
    set_param(block, 'BackgroundColor', 'orange'); % set background color orange for this block
    set_param(block, 'ForegroundColor', 'black');  % set foreground color black for this block
end

end
