% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function setFilters(cm)

cm.addCustomFilterFcn('SimulinkUtils:GenerateMATLABFunction', @checkConditions);

end

function state = checkConditions(callbackInfo)
% Custom check for SimulinkUtils:GenerateMATLABFunction menu item

state = 'Enabled';

end
