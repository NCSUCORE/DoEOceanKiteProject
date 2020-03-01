% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function state = checkSignals(callbackInfo)
% Check if one or more signals are selected

partH = SLStudio.Utils.partitionSelectionHandles(callbackInfo);

if numel(partH.segments) < 1
    state = 'Disabled';
else
    state = 'Enabled';
end

end
