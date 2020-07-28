env = ENV.env;
env.addFlow({'water'},{'constT_XYZvarZ_Ramp'},'FlowDensities',1000)

FLOWCALCULATION = 'constT_XYZvarZ_Ramp';
ENVIRONMENT     = 'environmentDOE';

saveBuildFile('env',mfilename,'variant',["FLOWCALCULATION","ENVIRONMENT"]);
