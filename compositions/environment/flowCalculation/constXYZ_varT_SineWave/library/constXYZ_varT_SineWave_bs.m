% Set up environment
env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXYZ_varT_SineWave'},'FlowDensities',1000)
env.water.waveBias.setValue(1.5,'')
env.water.amplitude.setValue(0,'')
env.water.frequency.setValue(0.001,'1/s')
env.water.phase.setValue(0,'rad')
env.water.azimuth.setValue(0,'rad')
env.water.elevation.setValue(0,'rad')
environmentDOE_bc

FLOWCALCULATION = 'constXYZ_varT_SineWave';
ENVIRONMENT     = 'environmentDOE';

saveBuildFile('env',mfilename,'variant',["FLOWCALCULATION","ENVIRONMENT"]);
