function schema = alignRight(callbackInfo)
schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:AlignRightEdge';    % Set menu item tag
schema.label        = 'Align Right Edge';                 % Set menu item label
schema.accelerator  = 'Ctrl+Alt+R';                 % Set accelerator/short-cut
schema.callback     = @alignRightCb;         % Set callback function

end

function alignRightCb(callbackInfo)
edObj = callbackInfo.studio.App.getActiveEditor();
edObj.alignItems('right')
end
