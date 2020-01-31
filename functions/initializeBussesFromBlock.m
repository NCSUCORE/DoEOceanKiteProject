function initializeBussesFromBlock(blkPth)
% Get the name of the block
blkName = get_param(blkPth,'Name');
% Run the bus creator function
try
    evalin('base',sprintf('%s_bc;',blkName));
catch me
    dbstack
%     error('Failed to initialize variant for \n %s',blkPth)
    rethrow(me)
end
end