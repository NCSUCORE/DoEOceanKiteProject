% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function state = checkOneSignal(callbackInfo)
% Check if 1 signal is selected

partH = SLStudio.Utils.partitionSelectionHandles(callbackInfo);

segments = partH.segments;
segments = segments(strcmp(get(segments, 'SegmentType'), 'trunk'));

if numel(segments) ~= 1
    state = 'Disabled';
else
    state = 'Enabled';
end

end
