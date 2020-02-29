function schema = autoArrangeDiagram(callbackInfo)
% Schema function: defines autoArrangeDiagram menu item

schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:AutoArrangeDiagram'; % Set menu item tag
schema.label        = 'Auto Arrange Diagram';       % Set menu item label
schema.accelerator  = 'CTRL+ALT+A';                 % Set accelerator/short-cut
schema.callback     = @autoArrangeDiagramCb;         % Set callback function

end

function autoArrangeDiagramCb(callbackInfo)
% Callback function: autoArrangeDiagram menu item
Simulink.BlockDiagram.arrangeSystem(gcs)
end
