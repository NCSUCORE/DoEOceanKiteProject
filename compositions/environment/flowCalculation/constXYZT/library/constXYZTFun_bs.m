

function constXYZTFun_bs(flwSpd) 

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'constXYZT'},'FlowDensities',1000);
env.addFlow({'waterWave'},{'planarWaves'});
env.waterWave.setNumWaves(3,'');
env.waterWave.build;


env.water.setflowVec([flwSpd 0 0],'m/s'); 
FLOWCALCULATION = 'constXYZT';
ENVIRONMENT     = 'environmentDOE';

saveBuildFile('env',mfilename,'variant',["FLOWCALCULATION","ENVIRONMENT"]);
