% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function state = checkMultiBlocks(callbackInfo)
% Check if two or more blocks are selected.

partH = SLStudio.Utils.partitionSelectionHandles(callbackInfo);

if numel(partH.blocks) < 2
    state = 'Disabled';
else
    state = 'Enabled';
end

end
