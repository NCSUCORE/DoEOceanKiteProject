% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function state = checkOneSubsystem(callbackInfo)
% Check if one subsystem is selected.

partH = SLStudio.Utils.partitionSelectionHandles(callbackInfo);

if numel(partH.blocks) ~= 1 || ~strcmp(get(partH.blocks, 'BlockType'), 'SubSystem')
    state = 'Disabled';
else
    state = 'Enabled';
end

end
