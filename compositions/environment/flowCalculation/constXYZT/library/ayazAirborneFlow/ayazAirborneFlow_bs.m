clear all;clc;format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'constXYZT'},'FlowDensities',1.225);
% 
% env.waterWave.wave1.waveNumber.setValue(1,'rad/m')
% env.waterWave.wave1.frequency.setValue(.2,'rad/s')
% env.waterWave.wave1.amplitude.setValue(.1,'m')
% env.waterWave.wave1.phase.setValue(0,'rad')
% 
% env.waterWave.wave2.waveNumber.setValue(1,'rad/m')
% env.waterWave.wave2.frequency.setValue(.4,'rad/s')
% env.waterWave.wave2.amplitude.setValue(.1,'m')
% env.waterWave.wave2.phase.setValue(0,'rad')
% 
% env.waterWave.wave3.waveNumber.setValue(1,'rad/m')
% env.waterWave.wave3.frequency.setValue(.6,'rad/s')
% env.waterWave.wave3.amplitude.setValue(.1,'m')
% env.waterWave.wave3.phase.setValue(0,'rad')

% env.waterWave.waveParamMat.setValue(env.waterWave.structAssem,'');
% FLOWCALCULATION = 'constXYZT_planarWave';
FLOWCALCULATION = 'constXYZT';
ENVIRONMENT     = 'environmentDOE';

saveBuildFile('env',mfilename,'variant',["FLOWCALCULATION","ENVIRONMENT"]);
