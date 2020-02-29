% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function setFilters(cm)

cm.addCustomFilterFcn('SimulinkUtils:MatchSize', @sl_menu.Customizer.checkBlocks);
cm.addCustomFilterFcn('SimulinkUtils:ShowHideName', @sl_menu.Customizer.checkBlocks);
cm.addCustomFilterFcn('SimulinkUtils:CreateBusObject', @checkCreateBusObject);
cm.addCustomFilterFcn('SimulinkUtils:InheritPortNames', @sl_menu.Customizer.checkOneSubsystem);

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
