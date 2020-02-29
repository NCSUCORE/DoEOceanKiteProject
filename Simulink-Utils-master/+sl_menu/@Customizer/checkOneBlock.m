% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function state = checkOneBlock(callbackInfo)
% Check if one block is selected.

partH = SLStudio.Utils.partitionSelectionHandles(callbackInfo);

if numel(partH.blocks) ~= 1
    state = 'Disabled';
else
    state = 'Enabled';
end

end
