function val = upperConfidenceBound(predMean,postVar,other)

% local variables
exploreCons = other.explorationConstant;
exploitCons =  other.exploitationConstant;
% output
val = exploitCons.*predMean + 2^(exploreCons).*postVar;

end