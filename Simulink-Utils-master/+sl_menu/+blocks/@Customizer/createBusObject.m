% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = createBusObject(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines createBusObject menu item

schema              = sl_action_schema();                           % Initialize schema
schema.tag          = 'SimulinkUtils:CreateBusObject';              % Set menu item tag
schema.label        = 'Create bus object from BusCreator block';    % Set menu item label
schema.callback     = @createBusObjectCb;                           % Set callback function

end

function createBusObjectCb(callbackInfo)
% Callback function: createBusObject menu item

partH   = SLStudio.Utils.partitionSelectionHandles(callbackInfo);
bh      = partH.blocks;
busInfo = Simulink.Bus.createObject(bdroot(bh), bh);

newName = inputdlg('New bus object name:', 'Create bus object');

if ~isempty(newName)
    newName = newName{1};
    
    try
        evalin('base', [newName '=' busInfo.busName ';clear ' busInfo.busName ])
    catch ME
        % no valid name provided
        warning (ME.message);
        warning ('simulinkUtils:createBusObject:CreateError', 'Could not create bus with name "%s", renamed to "%s".', newName, busInfo.busName);
        newName = busInfo.busName;
    end
else
    % no name provided
    newName = busInfo.busName;
end

disp (['Created Simulink.Bus "' newName '"']);

switch get(bh, 'BlockType')
    case 'BusCreator'
        % update output bus def.
        set(bh, 'OutDataTypeStr', ['Bus: ' newName]);
end

end
