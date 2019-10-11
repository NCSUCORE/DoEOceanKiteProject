env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXY_ZvarT_ADCP'},'FlowDensities',1000)

environment_bc

FLOWCALCULATION = 'constXY_ZvarT_ADCP';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
