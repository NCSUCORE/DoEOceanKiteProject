%% Set up environment
env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXY_ZvarT_ADCP'},'FlowDensities',1000)

env.water.setStartADCPTime(4000,'s')
%sets adcp time to be 100 minutes
env.water.setEndADCPTime(10000-env.water.startADCPTime.Value,'s')
% env.setFlowTSeries('')
environment_bc
% env.water.nominal100mFlowVec.setValue( 1.5,'m/s') 

FLOWCALCULATION = 'constXY_ZvarT_ADCP';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
