function schema = alignTop(callbackInfo)

schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:AlignTopEdge';    % Set menu item tag
schema.label        = 'Align Top Edge';                 % Set menu item label
schema.accelerator  = 'Ctrl+Alt+T';                 % Set accelerator/short-cut
schema.callback     = @alignTopCb;         % Set callback function

end

function alignTopCb(callbackInfo)
edObj = callbackInfo.studio.App.getActiveEditor();
edObj.alignItems('Top')
end
