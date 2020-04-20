% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function state = checkIsLibrary(callbackInfo)
% Check if current system is a library or not

if ~bdIsLibrary(gcs)
    state = 'Disabled';
else
    state = 'Enabled';
end

end
