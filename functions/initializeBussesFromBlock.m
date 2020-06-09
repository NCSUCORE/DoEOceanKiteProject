function initializeBussesFromBlock(blkPth)
% Get the name of the block
blkName = get_param(blkPth,'Name');
% Run the bus creator function
try
    evalin('base',sprintf('%s_bc;',blkName));
catch me
    fprintf('\n Error attempting to run bus creator \n %s_bc\n',blkName);
    dbstack
    rethrow(me)
end
end