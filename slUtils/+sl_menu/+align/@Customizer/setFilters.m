% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function setFilters(cm)

cm.addCustomFilterFcn('SimulinkUtils:AlignLeftEdge', @sl_menu.Customizer.checkMultiBlocks);
cm.addCustomFilterFcn('SimulinkUtils:AlignBottomEdge', @sl_menu.Customizer.checkMultiBlocks);
cm.addCustomFilterFcn('SimulinkUtils:AlignRightEdge', @sl_menu.Customizer.checkMultiBlocks);
cm.addCustomFilterFcn('SimulinkUtils:AlignTopEdge', @sl_menu.Customizer.checkMultiBlocks);
cm.addCustomFilterFcn('SimulinkUtils:AutoArrangeDiagram', @sl_menu.Customizer.checkMultiBlocks);
end

function state = checkCreateBusObject(callbackInfo)
% Custom check for SimulinkUtils:CreateBusObject menu item

% Check if just one block is selected.
state = sl_menu.Customizer.checkOneBlock(callbackInfo);

if strcmp(state, 'Enabled')
    % Continue checking.
    partH   = SLStudio.Utils.partitionSelectionHandles(callbackInfo);
    type    = get(partH.blocks, 'BlockType');
    
    switch type
        case 'BusCreator'
            % Implemented for BusCreator blocks.
            state = 'Enabled';
            
        otherwise
            % Not implemented for other block types.
            state = 'Disabled';
    end
end

end
