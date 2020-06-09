% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = inheritSignalNames(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines inheritSignalNames menu item

schema          = sl_action_schema();                   % Initialize schema
schema.tag      = 'SimulinkUtils:InheritSignalNames';   % Set menu item tag
schema.label    = 'Propagate signal names';             % Set menu item label
schema.callback = @inheritSignalNamesCb;                % Set callback function

end

function inheritSignalNamesCb(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium

% get handles of system, selected signals and source/destination blocks
sys         = gcs;
allLines    = find_system(sys, 'FollowLinks', 'on', 'Findall', 'on', 'LookUnderMasks', 'all', 'Type', 'line', 'LineParent', -1);

if isempty(allLines)
    error('simulinkUtils:converSignalToGoto:NoSignalSelected', 'No signal line selected.');
end

for iLines = 1 : numel(allLines)
    set(allLines(iLines), 'SignalPropagation', 'on');
end

end
