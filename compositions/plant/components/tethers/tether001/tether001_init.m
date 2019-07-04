% If user specifies too few nodes, or noninteger value
if numNodes < 2  || floor(numNodes)~=numNodes
    warning('Invalid number of nodes, N.  N must be an integer and >=2.\nKeeping active variant: %s',get_param(gcb,'LabelModeActiveChoice'))
    return
end

if numNodes==2
    set_param(gcb,'LabelModeActiveChoice','twoNodeTether')
else
    set_param(gcb,'LabelModeActiveChoice','NNodeTether')
end

createThrTenVecBus
createThrNodeBus(numNodes)