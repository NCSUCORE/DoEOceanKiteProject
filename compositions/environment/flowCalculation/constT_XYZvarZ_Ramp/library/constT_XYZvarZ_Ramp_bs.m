env = ENV.env;
env.addFlow({'water'},{'constT_XYZvarZ_Ramp'},'FlowDensities',1000)

FLOWCALCULATION = 'constT_XYZvarZ_Ramp';

saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
