sim('th.slx')
tsc = signalcontainer(logsout);

tsc.chartState.plot
hold on
tsc.resample(0.1)
tsc.chartState.plot