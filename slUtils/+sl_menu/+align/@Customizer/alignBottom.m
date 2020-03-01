function schema = alignBottom(callbackInfo)

schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:AlignBottomEdge';    % Set menu item tag
schema.label        = 'Align Bottom Edge';                 % Set menu item label
schema.accelerator  = 'Ctrl+Alt+B';                 % Set accelerator/short-cut
schema.callback     = @alignBottomCb;         % Set callback function

end

function alignBottomCb(callbackInfo)
% Callback function: alignLeft menu item
edObj = callbackInfo.studio.App.getActiveEditor();
edObj.alignItems('Bottom')
end
