

%% Set up environment
env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constX_YZvarT_ADCPTurb'},'FlowDensities',1000)

env.water.setStartADCPTime(4000,'s')
env.water.setEndADCPTime(10000,'s')

env.water.yBreakPoints.setValue(0:1:10,'m');

env.water.setTI(0.1,'');
env.water.setF_min(0.01,'Hz');
env.water.setF_max(1,'Hz');
env.water.setP(0.1,'');
env.water.setQ(0.1,'Hz');
env.water.setC(5,'');
env.water.setN_mid_freq(5,'');

% env.water.process
env.water.buildTimeseries
environment_bc
FLOWCALCULATION = 'constX_YZvarT_ADCPTurb';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
