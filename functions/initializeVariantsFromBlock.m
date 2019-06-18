function initializeVariantsFromBlock(blkPath)
% Determine which component we're working with
componentName = unique(regexpi(blkPath,'vehicle|tethers|groundStation|winch','match'));
switch lower(componentName{1})
    case 'vehicle'
        componentName = 'VHCL';
        controlName   = 'VEHICLE';
    case 'tethers'
        componentName = 'THRS';
        controlName   = 'TETHERS';
    case 'groundstation'
        componentName = 'GDST';
        controlName   = 'GROUNDSTATION';
    case 'winch'
        componentName = 'WNCH';
        controlName   = 'WINCHES';
end
% Get variants
vars = get_param(blkPath,'Variants');
for ii = 1:length(vars)
    % Get the name of the block as it appears in the variant subsystem
    varName = strsplit(vars(ii).BlockName,'/');
    varName = varName{end};
    blckName = varName;
    varName(1) = lower(varName(1));
    variantName = genvarname(['VSS_' componentName '_' varName]);
    evalin('base',sprintf('%s = Simulink.Variant(''strcmpi(%s,''''%s'''')'');',variantName,controlName,blckName));
end
end