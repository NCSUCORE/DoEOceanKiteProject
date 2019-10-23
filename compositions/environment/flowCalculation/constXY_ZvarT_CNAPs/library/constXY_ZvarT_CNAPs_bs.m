loadComponent('pathFollowingTether');
env = ENV.env;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXY_ZvarT_CNAPS'},'FlowDensities',1000)

env.water = env.water.setStartCNAPSTime(0,'s');
env.water = env.water.setEndCNAPSTime(3600*1000,'s');

environment_bc

FLOWCALCULATION = 'constXY_ZvarT_ADCP';
saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');

env.water.plotMags
title('Magnitude of Flow Speeds at (35.138''  , -75.106'') ' )
