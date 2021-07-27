if any(thr(1).numNodes ~= [thr.numNodes])
    error('Inconsistent number of nodes, all tethers must have same number of nodes.')
end
numNodes = thr(1).numNodes;