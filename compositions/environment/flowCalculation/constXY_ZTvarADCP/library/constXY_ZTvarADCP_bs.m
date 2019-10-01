

%% Set up environment
env = ENV.constXY_ZTvarADCP;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXY_ZTvarADCP'},'FlowDensities',1000)
env.flowType.setValue('adcpFlow','')
env.setStartADCPTime(4000,'s')
%sets adcp time to be 100 minutes
env.setEndADCPTime(10000-env.startADCPTime.Value,'s')
env.setFlowTSeries('')
environment_bc
env.water.nominal100mFlowVec.setValue( 1.5,'m/s') 
FLOWCALCULATION = 'constXY_ZTvarADCP';

 saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
