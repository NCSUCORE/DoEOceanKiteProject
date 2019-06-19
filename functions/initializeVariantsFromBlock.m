function initializeVariantsFromBlock(blkPath)
% Determine which component we're working with
componentName = unique(regexpi(blkPath,'vehicle|tethers|groundStation|winch','match'));
controlName = upper(componentName{1});
% Get variants
vars = get_param(blkPath,'Variants');
for ii = 1:length(vars)
    % Get the name of the block as it appears in the variant subsystem
    varName = strsplit(vars(ii).BlockName,'/');
    subSysName = genvarname(varName{end-1});
    varName = varName{end};
    blckName = varName;
    varName(1) = genvarname(lower(varName(1)));
    variantName = ['VSS_' subSysName '_' varName];
    evalin('base',sprintf('%s = Simulink.Variant(''strcmpi(%s,''''%s'''')'');',variantName,controlName,blckName));
end
end