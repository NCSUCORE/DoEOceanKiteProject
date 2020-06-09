% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function setFilters(cm)

cm.addCustomFilterFcn('SimulinkUtils:SignalGotoFrom', @sl_menu.Customizer.checkOneSignal);

end
