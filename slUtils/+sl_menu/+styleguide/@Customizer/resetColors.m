% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = resetColors(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines resetColors menu item

schema          = sl_action_schema();           % Initialize schema
schema.tag      = 'SimulinkUtils:ResetColors';  % Set menu item tag
schema.label    = 'Reset block colors';         % Set menu item label
schema.callback = @resetColorsCb;               % Set callback function

end

function resetColorsCb(callbackInfo)
% Callback function: resetColors menu item

% Get all selected block handles
partsH = SLStudio.Utils.partitionSelectionHandles(callbackInfo);

% Set the colors to the default black and white
set(partsH.blocks, 'ForegroundColor', 'black');
set(partsH.blocks, 'BackgroundColor', 'white');

end
