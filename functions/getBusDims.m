function resultsStruct = getBusDims
% This is a function that figures out the dimensions of a lot of things
% needed in the busses

% Get the number of tethers and number of nodes in each tethers
if evalin('base','~exist(''thr'',''var'')')
    dbstack
    error('thr object not defined in base workspace')
end
numNodes    = evalin('base','thr.numNodes.Value');   % Get the number of nodes
numTethers  = evalin('base','thr.numTethers.Value'); % Get the number of tethers
if numTethers == 1
    thrLinkFlowVecsSize = [3 numNodes-1];
else
    thrLinkFlowVecsSize = [3 numNodes-1 numTethers];
end


% make sure that a ground station object exists in the base workspace
if evalin('base','~exist(''gndStn'',''var'')')
    dbstack
    error('gndStn object does not exist in base workspace')
end

% Get the number of anchor tethers and number of nodes in each tether
switch evalin('base','class(gndStn)')
    case 'OCT.oneDoFStation'
        numNodesAnchor    = 2;
        numTethersAnchor  = 1;
        gndStnLmpMasPos = [0;0;0];
    case 'OCT.sixDoFStation'
        numNodesAnchor    = evalin('base','thr.numNodes.Value');   % Get the number of nodes
        numTethersAnchor  = evalin('base','gndStn.anchThrs.numTethers.Value'); % Get the number of tethers
        gndStnLmpMasPos = evalin('base','gndStn.lumpedMassPositionMatrixBdy.Value');
    otherwise
        dbstack
        error('Unknown ground station class')
end

if numTethersAnchor == 1
    anchThrLinkFlowVecsSize = [3 numNodesAnchor-1];
else
    anchThrLinkFlowVecsSize = [ 3 numNodesAnchor-1 numTethersAnchor];
end

gndStnLmpMasPosSize = size(gndStnLmpMasPos);

resultsStruct.numNodesAnchor = numNodesAnchor;
resultsStruct.numTethersAnchor = numTethersAnchor;
resultsStruct.gndStnLmpMasPos = gndStnLmpMasPos;
resultsStruct.gndStnLmpMasPosSize = gndStnLmpMasPosSize;
resultsStruct.anchThrLinkFlowVecsSize = anchThrLinkFlowVecsSize;

resultsStruct.numNodes = numNodes;
resultsStruct.numTethers = numTethers;
resultsStruct.thrLinkFlowVecsSize = thrLinkFlowVecsSize;

end