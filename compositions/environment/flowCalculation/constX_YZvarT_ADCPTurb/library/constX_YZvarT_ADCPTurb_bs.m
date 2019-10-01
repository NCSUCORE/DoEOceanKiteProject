

%% Set up environment
env = ENV.constX_YZvarT_ADCPTurb;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constX_YZvarT_ADCPTurb'},'FlowDensities',1000)
env.setStartADCPTime(4000,'s')

env.setEndADCPTime(10000-env.startADCPTime.Value,'s')
env.setFlowTSeries('')
env.yBreakPoints.setValue(0:1:10,'m');
env.water.nominal100mFlowVec.setValue( 1.5,'m/s') 
environment_bc
FLOWCALCULATION = 'constX_YZvarT_ADCPTurb';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
