function schema = alignLeft(callbackInfo)
schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:AlignLeftEdge';    % Set menu item tag
schema.label        = 'Align Left Edge';                 % Set menu item label
schema.accelerator  = 'Ctrl+Alt+L';                 % Set accelerator/short-cut
schema.callback     = @alignLeftCb;         % Set callback function

end

function alignLeftCb(callbackInfo)
% Callback function: alignLeft menu item
edObj = callbackInfo.studio.App.getActiveEditor();
edObj.alignItems('left')
end
