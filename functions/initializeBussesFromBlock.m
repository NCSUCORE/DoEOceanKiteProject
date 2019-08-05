function initializeBussesFromBlock(blkPth)
% Get the name of the block
blkName = get_param(blkPth,'Name');
% Run the bus creator function
evalin('base',sprintf('%s_bc;',blkName));
end