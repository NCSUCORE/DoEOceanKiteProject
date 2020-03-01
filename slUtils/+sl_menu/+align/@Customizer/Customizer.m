% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

classdef Customizer < sl_menu.Customizer
    
    methods (Static)
        % Customizing Methods
        schema = autoArrangeDiagram(callbackInfo)
        schema = alignLeft(callbackInfo)
        schema = alignRight(callbackInfo)
        schema = alignTop(callbackInfo)
        schema = alignBottom(callbackInfo)
                
        % Implement Abstract
        setFilters(cm)
    end
end
