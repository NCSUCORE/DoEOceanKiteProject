% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = inheritPortNames(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines inheritPortNames menu item

schema              = sl_action_schema();               % Initialize schema
schema.tag          = 'SimulinkUtils:InheritPortNames'; % Set menu item tag
schema.label        = 'Inherit subsystem port names';   % Set menu item label
schema.accelerator  = 'CTRL+ALT+G';                     % Set accelerator/short-cut
schema.callback     = @inheritPortNamesCb;              % Set callback function

end

function inheritPortNamesCb(callbackInfo)
% Callback function: createBusObject menu item

% Get selected subsystem
partH   = SLStudio.Utils.partitionSelectionHandles(callbackInfo);
blockH  = partH.blocks;

% Get port handles
ports = get(blockH, 'PortHandles');

% Process input ports
for iInport = 1 : numel(ports.Inport)
    % Get the port
    port = ports.Inport(iInport);
    
    % Find the related port block
    portBlock = find_system(blockH, 'SearchDepth', 1, 'BlockType', 'Inport', 'Port', num2str(iInport));
    
    % Get name of the the connected signal - outside of the subsystem
    sigOutside  = get(port, 'Line');
    
    if sigOutside > 0
        rawName     = get(sigOutside, 'Name');
        newName     = regexprep(rawName, '[<>]', '');
    else
        newName = '';
    end
    
    if isempty(newName)
        % No signal name outside: check for signal name inside.
        tempH       = get(portBlock, 'LineHandles');
        sigInside   = tempH.Outport;
        rawName     = get(sigInside, 'Name');
        newName     = regexprep(rawName, '[<>]', '');
        
        if isempty(newName)
            % No signal name: check for connection to the input port of a
            % subsystem - inside of the subsystem
            dstPortHandle   = get(sigInside, 'DstPortHandle');
            dstBlockHandle  = get(sigInside, 'DstBlockHandle');
            
            if dstBlockHandle > 0
                dstPortNumber = get(dstPortHandle, 'PortNumber');
                
                if strcmp(get(dstBlockHandle, 'BlockType'), 'SubSystem')
                    % Find related block
                    dstInportBlock  = find_system(dstBlockHandle, 'SearchDepth', 1, 'BlockType', 'Inport', 'Port', num2str(dstPortNumber));
                    newName         = get(dstInportBlock, 'Name');
                elseif strcmp(get(dstBlockHandle, 'BlockType'), 'ModelReference')
                    % In case the possible source is a model reference block
                    refModel        = get(dstBlockHandle, 'ModelName');
                    load_system(refModel);
                    dstInportBlock  = find_system(get_param(refModel, 'Handle'), 'SearchDepth', 1, 'BlockType', 'Inport', 'Port', num2str(dstPortNumber));
                    newName         = get(dstInportBlock, 'Name');
                end
            end
            
            if isempty(newName) && sigOutside > 0
                % No signal name: check for connection to an input port
                % - outside of the subsystem
                srcBlockHandle = get(sigOutside, 'SrcBlockHandle');
                
                if srcBlockHandle > 0 && strcmp(get(srcBlockHandle, 'BlockType'), 'Inport')
                    newName = get(srcBlockHandle, 'Name');
                end
            end
        end
    end
    
    % Apply the new name to the port block
    if ~isempty(newName)
        
        try
            % The name might already be in use for another block in the
            % subsystem
            set(portBlock, 'Name', newName);
        catch ME
            fprintf(2, 'Unable to rename: "%s."\n', ME.message);
        end
    end
end

% Process output ports
for iOutport = 1 : numel(ports.Outport)
    % Get the port
    port = ports.Outport(iOutport);
    
    % Find the related port block
    portBlock = find_system(blockH, 'SearchDepth', 1, 'BlockType', 'Outport', 'Port', num2str(iOutport));
    
    % Get name of the the connected signal - outside of the subsystem
    sigOutside  = get(port, 'Line');
    
    if sigOutside > 0
        rawName     = get(sigOutside, 'Name');
        newName     = regexprep(rawName, '[<>]', '');
    else
        newName = '';
    end
    
    if isempty(newName)
        % No signal name outside: check for signal name inside.
        tempH       = get(portBlock, 'LineHandles');
        sigInside   = tempH.Inport;
        rawName     = get(sigInside, 'Name');
        newName     = regexprep(rawName, '[<>]', '');
        
        if isempty(newName)
            % No signal name: check for connection to the input port of a
            % subsystem - inside of the subsystem
            srcPortHandle   = get(sigInside, 'SrcPortHandle');
            srcBlockHandle  = get(sigInside, 'SrcBlockHandle');
            
            if srcBlockHandle > 0
                srcPortNumber = get(srcPortHandle, 'PortNumber');
                
                if strcmp(get(srcBlockHandle, 'BlockType'), 'SubSystem')
                    % Find related block
                    srcOutportBlock = find_system(srcBlockHandle, 'SearchDepth', 1, 'BlockType', 'Outport', 'Port', num2str(srcPortNumber));
                    newName         = get(srcOutportBlock, 'Name');
                elseif strcmp(get(srcBlockHandle, 'BlockType'), 'ModelReference')
                    % In case the possible source is a model reference block
                    refModel       = get(srcBlockHandle, 'ModelName');
                    load_system(refModel);
                    srcOutportBlock = find_system(get_param(refModel, 'Handle'), 'SearchDepth', 1, 'BlockType', 'Outport', 'Port', num2str(srcPortNumber));
                    newName         = get(srcOutportBlock, 'Name');
                end
            end
            
            if isempty(newName) && sigOutside > 0
                % No signal name: check for connection to an output port
                % - outside of the subsystem
                dstBlockHandle = get(sigOutside, 'DstBlockHandle');
                
                if dstBlockHandle > 0 && strcmp(get(srcBlockHandle, 'BlockType'), 'Outport')
                    newName = get(dstBlockHandle, 'Name');
                end
            end
        end
    end
    
    % Apply the new name to the port block
    if ~isempty(newName)
        
        try
            % The name might already be in use for another block in the
            % subsystem
            set(portBlock, 'Name', newName);
        catch ME
            fprintf(2, 'Unable to rename: "%s."\n', ME.message);
        end
    end
end

end
