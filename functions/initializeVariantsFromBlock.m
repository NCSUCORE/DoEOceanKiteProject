function initializeVariantsFromBlock(blkPath)
% Determine the name of the block that we're working with
blkName = strsplit(blkPath,'/');
blkName = blkName(end);
blkName = blkName{1};
blkName = genvarname(blkName);
controlName = upper(blkName);
controlName = genvarname(controlName);
% Get variants
vars = get_param(blkPath,'Variants');
for ii = 1:length(vars)
    % Get the name of the block as it appears in the variant subsystem
    varName = strsplit(vars(ii).BlockName,'/');
    varName = varName{end};
    varName(1) = genvarname(lower(varName(1)));
    
%     if strcmpi(varName,'tether000')
%         x = 1;
%     end
        
    try
        evalin('base',sprintf('VSS_%s_%s = Simulink.Variant(''strcmpi(%s,''''%s'''')'');',blkName,varName,controlName,varName));
    catch
        dbstack
        error('Failed to create VSS object VSS_%s_%s in base workspace',blkName,varName)
    end
end