% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = customContext(callbackInfo) %#ok<INUSD>
% Schema function: defines the custom menu

schema          = sl_container_schema();    % Initialize schema
schema.tag      = 'SimulinkUtils:Context';  % Set menu tag
schema.label    = 'Utils';                  % Set menu label

% Initialize Customizers to add
customizers = {
    sl_menu.blocks.Customizer()
    sl_menu.signals.Customizer()
    sl_menu.generation.Customizer()
    }';

% Generate childrenFcns for schema
schema.childrenFcns = sl_menu.Customizer.getCustomizeMethods(customizers);

end
