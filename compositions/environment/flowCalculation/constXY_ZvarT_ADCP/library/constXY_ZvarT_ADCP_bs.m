%% Set up environment
env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXY_ZvarT_ADCP'},'FlowDensities',1000)

env.water = env.water.setStartADCPTime(35000,'s');
%sets adcp time to be 100 minutes
env.water = env.water.setEndADCPTime(38000,'s');
% env.setFlowTSeries('')
environment_bc
% env.water.nominal100mFlowVec.setValue( 1.5,'m/s') 

FLOWCALCULATION = 'constXY_ZvarT_ADCP';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
