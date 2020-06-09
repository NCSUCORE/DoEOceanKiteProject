% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = showHideBlockName(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines showHideBlockName menu item

schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:ShowHideName'; % Set menu item tag
schema.label        = 'Show/hide block name';       % Set menu item label
schema.accelerator  = 'CTRL+ALT+N';                 % Set accelerator/short-cut
schema.callback     = @showHideBlockNameCb;         % Set callback function

end

function showHideBlockNameCb(callbackInfo)
% Callback function: showHideBlockName menu item

% Check if the blocks are showing their name
partsH  = SLStudio.Utils.partitionSelectionHandles(callbackInfo);
for ii = 1:numel(partsH)
set_param(partsH.blocks(ii), 'HideAutomaticName','off')
end
if any(strcmp(get_param(partsH.blocks, 'ShowName'),'on'))
    onOff = 'on';
else
    onOff = 'off';
end
    
% Make all selected blocks show or hide their name
if all(strcmp(onOff, 'on'))
    setting = 'off';
else
    setting = 'on';
end

for iterator = 1 : length(partsH.blocks)
    set_param(partsH.blocks(iterator), 'ShowName', setting);
end

end
