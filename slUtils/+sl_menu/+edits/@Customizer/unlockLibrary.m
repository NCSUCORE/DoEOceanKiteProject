function schema = unlockLibrary(callbackInfo)
% Schema function: defines unlockLibrary menu item
% Currently does not work because Simulink locks out the entire menu when
% the library is locked.  Have yet to figure out a workaround -MC

schema              = sl_action_schema();           % Initialize schema
schema.tag          = 'SimulinkUtils:UnlockLibrary'; % Set menu item tag
schema.label        = 'Unlock Library (Does Not Work)';       % Set menu item label
schema.accelerator  = 'CTRL+ALT+E';                 % Set accelerator/short-cut
schema.callback     = @unlockLibraryCB;         % Set callback function

end

function unlockLibraryCB(callbackInfo)
% Callback function: autoArrangeDiagram menu item
set_param(gcs,'Lock','off')
end
