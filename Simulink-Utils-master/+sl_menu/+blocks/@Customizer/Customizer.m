% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

classdef Customizer < sl_menu.Customizer
    
    methods (Static)
        % Customizing Methods
        schema = matchSizeOfBlocks(callbackInfo)
        schema = showHideBlockName(callbackInfo)
        schema = createBusObject(callbackInfo)
        schema = inheritPortNames(callbackInfo)
        
        % Implement Abstract
        setFilters(cm)
    end
end
