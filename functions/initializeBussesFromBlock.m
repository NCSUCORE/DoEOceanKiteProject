function initializeBussesFromBlock(blkPth)
% Get the name of the block
blkName = get_param(blkPth,'Name');
% Run the bus creator function
try
    evalin('base',sprintf('%s_bc;',blkName));
catch me
    dbstack
    fprintf('\n Error attempting to run bus creator \n %s\n',sprintf('%s_bc;',blkName));
    rethrow(me)
end
end