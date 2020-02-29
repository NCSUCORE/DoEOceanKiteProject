% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function setFilters(cm)

cm.addCustomFilterFcn('SimulinkUtils:OrangeConstants', @hide);
cm.addCustomFilterFcn('SimulinkUtils:ResetColors', @sl_menu.Customizer.checkBlocks);

end

function state = hide(callbackInfo) %#ok<INUSD> Might be used in a later stadium.

state = 'Hidden';

end
