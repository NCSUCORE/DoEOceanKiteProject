function J = thrDragOpt(simIn,beta)


assignin('base','A',beta(1));
assignin('base','B',beta(2));
assignin('base','phi',beta(3));

try
simOut = sim(simIn);
ref = signalcontainer(simOut.logsout);
J = -ref.netPow1.mean;
catch
    J = 1e6;
end