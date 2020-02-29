% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function sl_customization(cm)

% Register custom menu in the Simulink Editor's menu bar.
cm.addCustomMenuFcn('Simulink:MenuBar', @getCustomSimulinkMenu);

% Register custom menu in the Simulink context menu.
cm.addCustomMenuFcn('Simulink:ContextMenu', @getCustomSimulinkContext);

% Register custom menu in the Stateflow Editor's menu bar.
cm.addCustomMenuFcn('Stateflow:MenuBar', @getCustomStateflowMenu);

% Register custom menu in the Stateflow Editor's context menu.
cm.addCustomMenuFcn('Stateflow:ContextMenu', @getCustomStateflowContext);

% Add custom filters
sl_menu.styleguide.Customizer.setFilters(cm);
sl_menu.blocks.Customizer.setFilters(cm);
sl_menu.stateflow.blocks.Customizer.setFilters(cm);
sl_menu.signals.Customizer.setFilters(cm);

end
