% Copyright (c) 2008-2017 MonkeyProof Solutions B.V.
% Use is subject to the LGPL license.

function schema = generateMATLABFunction(callbackInfo) %#ok<INUSD> callbackInfo might be used in a later stadium
% Schema function: defines generateMATLABFunction menu item

schema          = sl_action_schema();                       % Initialize schema
schema.tag      = 'SimulinkUtils:GenerateMATLABFunction';   % Set menu item tag
schema.label    = 'Generate MATLAB Function block';         % Set menu item label
schema.callback = @generateMATLABFunctionCb;                % Set callback function

end

function generateMATLABFunctionCb(callbackInfo)
% Callback function: createBusObject menu item

% try to create Matlab Function block
mdl = sfroot();
load_system('eml_lib');

tryName = 'MATLAB Function';
success = false;

while ~success
    
    try
        add_block('eml_lib/MATLAB Function', [gcs '/' tryName]);
        success = true;
    catch ME %#ok<NASGU>
        % unable to create block: name in use? locked?
        answer = inputdlg('Please specify a valid name for the block:', 'MATLAB Function', 1, {tryName});
        
        if isempty(answer)
            return
        else
            tryName = answer{1};
        end
    end
end

% obtain the created object
ch = mdl.find('-isa','Stateflow.EMChart', 'Path', [gcs '/' tryName]);

% find selected unconnected line segments
partH = SLStudio.Utils.partitionSelectionHandles(callbackInfo);
portH = get(partH.segments, {'SrcPortHandle', 'DstPortHandle'});

destIdx = cellfun(@(c) any(eq(c, -1)), portH(:, 1));
srcIdx  = cellfun(@(c) any(eq(c, -1)), portH(:, 2));

destH   = unique(cat(1, portH{destIdx, 2}));
srcH    = unique(cat(1, portH{srcIdx, 1}));
destH   = destH(destH > 0);
srcH    = srcH(srcH > 0);

% determine input and output names for ports
inputNames = cell(1, numel(srcH));

for iInput = 1 : numel(srcH)
    name = get(srcH(iInput), 'Name');
    inputNames{iInput} = name;
end

outputNames = cell(1, numel(destH));

for iOutput = 1 : numel(destH)
    name = get(destH(iOutput), 'Name');
    outputNames{iOutput} = name;
end

inputNames  = genvarname(inputNames); %#ok<DEPGENAM> backwards compatibility
outputNames = genvarname(outputNames); %#ok<DEPGENAM> backwards compatibility

% create function declaration string
functionName = 'fcn';

switch numel(outputNames)
    case 0
        outputString = '';
        
    case 1
        outputString = sprintf('%s = ', outputNames{1});
        
    otherwise
        outputs         = sprintf('    %s, ...\n', outputNames{1:end-1});
        lastOutput      = sprintf('    %s', outputNames{end});
        outputString    = sprintf('[...\n%s%s ...\n    ] = ', outputs, lastOutput);
end

switch numel(inputNames)
    case 0
        inputString = '()\n';
        
    case 1
        inputString = sprintf('(%s)\n', inputNames{1});
        
    otherwise
        inputs         = sprintf('    %s, ...\n', inputNames{1:end-1});
        lastInput      = sprintf('    %s', inputNames{end});
        inputString    = sprintf('(...\n%s%s ...\n    )\n', inputs, lastInput);
end

% set function declaration string to created block
ch.set('Script', ['function ', outputString, functionName, inputString '%#codegen']);

% connect ports to created block
portHandles = get_param([gcs '/' tryName], 'PortHandles');

for iSrc = 1 : numel(srcH)
    % loop over input ports and connect with line
    lineH       = get(srcH(iSrc), 'Line');
    linePortH   = get(lineH, 'DstPortHandle');
    
    if numel(linePortH) > 1
        % branched line: connect to the first unconnected child
        lineChldH   = get(lineH, 'LineChildren');
        linePortH   = get(lineChldH, 'DstPortHandle');
        I           = find(cellfun(@(c) c < 0, linePortH), 1);
        lineH       = lineChldH(I);
    end
    
    % remove the current line and add a new one
    delete_line(lineH)
    add_line(gcs, srcH(iSrc), portHandles.Inport(iSrc), 'autorouting', 'on');
end

for iDst = 1 : numel(destH)
    % loop over output ports and connect with line
    lineH       = get(destH(iDst), 'Line');
    linePortH   = get(lineH, 'SrcPortHandle');
    
    if numel(linePortH) > 1
        % branched line: connect to the first unconnected child
        lineChldH   = get(lineH, 'LineChildren');
        linePortH   = get(lineChldH, 'SrcPortHandle');
        I           = find(cellfun(@(c) c < 0, linePortH), 1);
        lineH       = lineChldH(I);
    end
    
    % remove the current line and add a new one
    delete_line(lineH)
    add_line(gcs, portHandles.Outport(iDst), destH(iDst), 'autorouting', 'on');
end

end
