% plot(tsc.tetherLengths.diffMC-tsc.tetherLengths.diff)
% figure
% plot(tsc.eulerAngles.diffMC-tsc.eulerAngles.diff)
figure
mcts = (tsc.eulerAngles - tsc.eulerAngles.diffMC.cumtrapz(tsc.eulerAngles.getdatasamples(1)))
figure
jdts = (tsc.eulerAngles - tsc.eulerAngles.diff.cumtrapz(tsc.eulerAngles.getdatasamples(1)))



