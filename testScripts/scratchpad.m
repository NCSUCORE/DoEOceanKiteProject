% plot(tsc.tetherLengths.diffMC-tsc.tetherLengths.diff)
% figure
% plot(tsc.eulerAngles.diffMC-tsc.eulerAngles.diff)

mcts = (tsc.eulerAngles - tsc.eulerAngles.diffMC.cumtrapz(tsc.eulerAngles.getdatasamples(1)));

jdts = (tsc.eulerAngles - tsc.eulerAngles.diff.cumtrapz(tsc.eulerAngles.getdatasamples(1)));


mcts.plot
figure
jdts.plot

mcts.twoNorm
jdts.twoNorm


