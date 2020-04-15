function tether000_init
% Function to initialize tether000 model
% I made this a function because I'm being paranoid about which workspace
% it's evaluating in.  I know it shouldn't be the base workspace, but I'm
% paranoid.

dimInfo = getBusDims;
blkPath = split(gcb,'/');

switch blkPath{end}
    case 'anchorTethers'
        numNodes = dimInfo.numNodesAnchor;
    case 'tether000'
        numNodes = dimInfo.numNodes;
    otherwise
        error('Unknown tether000 block instance, IDK how to get the right number of nodes')
end

if numNodes < 2  || floor(numNodes)~=numNodes
    warning('Invalid number of nodes, N.  N must be an integer and >=2.\nKeeping active variant: %s',get_param(gcb,'LabelModeActiveChoice'))
    return
end

if numNodes > 2
    set_param(gcb,'OverrideUsingVariant','NNodeTether')
else
    set_param(gcb,'OverrideUsingVariant','twoNodeTether')
end
end