

%% Set up environment
env = ENV.constX_YZTvarADCPTurb;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXY_ZTvarADCP'},'FlowDensities',1000)
env.setStartADCPTime(4000,'s')

env.setEndADCPTime(10000-env.startADCPTime.Value,'s')
% env.setFlowTSeries('')

env.water.nominal100mFlowVec.setValue( 1.5,'m/s') 
[x,y,z] = createADCPTimeSeriesTurb(env)

environment_bc
FLOWCALCULATION = 'constXY_ZTvarADCPTurb';

 saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
