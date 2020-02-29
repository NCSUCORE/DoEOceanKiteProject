% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = customSFMenu(callbackInfo) %#ok<INUSD>
% Schema function: defines the custom menu

schema          = sl_container_schema();% Initialize schema
schema.tag      = 'SimulinkUtils:SFMenu';% Set menu tag
schema.label    = 'Utils';% Set menu label

% Initialize Customizers to add
customizers = {sl_menu.stateflow.blocks.Customizer()};

% Generate childrenFcns for schema
schema.childrenFcns = sl_menu.Customizer.getCustomizeMethods(customizers);

end
