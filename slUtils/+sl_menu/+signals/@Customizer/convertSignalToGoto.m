% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = convertSignalToGoto(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines convertSignalToGoto menu item

schema          = sl_action_schema();               % Initialize schema
schema.tag      = 'SimulinkUtils:SignalGotoFrom';   % Set menu item tag
schema.label    = 'Convert signal to Goto-From';    % Set menu item label
schema.callback = @convertSignalToGotoCb;           % Set callback function

end

function convertSignalToGotoCb(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium

% get handles of system, selected signals and source/destination blocks
sys             = gcs;
selectedLines   = find_system(sys, 'FollowLinks', 'on', 'Findall', 'on', 'LookUnderMasks', 'all', 'Type', 'line', 'Selected', 'on', 'LineParent', -1);

if isempty(selectedLines)
    error('simulinkUtils:converSignalToGoto:NoSignalSelected', 'No signal line selected.');
end

selectedLine    = selectedLines(1);
sourcePort      = get(selectedLine, 'SrcPortHandle');

if sourcePort < 0
    error('simulinkUtils:converSignalToGoto:UnconnectedSignalSelected', 'Cannot convert unconnected signals.');
end

destPorts       = get(selectedLine, 'DstPortHandle');

% get tag for goto-from blocks
name            = get(selectedLine, 'Name');
tag             = inputdlg('Goto tag:', 'Convert signal to Goto-From', 1, {name});

if isempty(tag)
    % cancelled
    return;
else
    tag = tag{1};
    
    if isempty(tag)
        error('simulinkUtils:converSignalToGoto:NoTag', 'No goto tag specified.');
    end
end

delete(selectedLine);

% create goto and connect to source
currentBlocks       = find_system(sys, 'FollowLinks', 'on', 'Findall', 'on', 'LookUnderMasks', 'all', 'Type', 'block');
currentBlockNames   = get(currentBlocks, 'Name');
currentGotos        = find_system(sys, 'FollowLinks', 'on', 'Findall', 'on', 'LookUnderMasks', 'all', 'Type', 'block', 'BlockType', 'Goto');
currentGotoTags     = get(currentGotos, 'GotoTag');

if isempty(currentGotoTags)
    currentGotoTags = {};
end

newTag  = genvarname(regexprep(tag, '[<>]', ''), currentGotoTags); %#ok<*DEPGENAM> genvarname is the only backwards compatible alternative

pos     = get(sourcePort, 'Position');
start   = pos + [50 -10];
h       = add_block('simulink/Signal Routing/Goto', [sys '/' genvarname([newTag 'Goto'], currentBlockNames)], 'Position', [start, start + [100, 20]]);
set(h, 'GotoTag', newTag, 'ShowName', 'off');
ph      = get(h, 'PortHandles');
add_line(sys, sourcePort, ph.Inport, 'autorouting', 'on');

% create from(s) and connect destinations
for iDst = 1 : numel(destPorts)
    % skip unconnected lines
    if destPorts(iDst) > 0
        pos     = get(destPorts(iDst), 'Position');
        start   = pos + [-150 -10];
        h       = add_block('simulink/Signal Routing/From', [sys '/' genvarname([newTag 'From' sprintf('%d', iDst)], currentBlockNames)], 'Position', [start, start + [100, 20]]);
        set(h, 'GotoTag', newTag, 'ShowName', 'off');
        ph      = get(h, 'PortHandles');
        add_line(sys, ph.Outport, destPorts(iDst), 'autorouting', 'on');
    end
end

end
