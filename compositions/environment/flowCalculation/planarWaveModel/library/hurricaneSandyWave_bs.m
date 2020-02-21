clear all;clc;format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'constXYZT'},'FlowDensities',995);
env.addFlow({'waterWave'},{'planarWaves'});
env.waterWave.setNumWaves(2,'');
env.waterWave.build;

% Hs = 7.6;   % meters
% tp = 13.33; % seconds
% w =   2*pi/tp; % rad/s
% k = (w^2)/9.81; %rad/m

%% calm waves

Hs = 2.08;   % meters
tp = 9.68; % seconds
w =   2*pi/tp; % rad/s
k = (w^2)/9.81; %rad/m



% env.waterWave.wave1.waveNumber.setValue(k,'rad/m')
% env.waterWave.wave1.frequency.setValue(w,'rad/s')
% env.waterWave.wave1.amplitude.setValue(Hs,'m')
% env.waterWave.wave1.phase.setValue(0,'rad')
% 
% env.waterWave.wave2.waveNumber.setValue(0,'rad/m')
% env.waterWave.wave2.frequency.setValue(0,'rad/s')
% env.waterWave.wave2.amplitude.setValue(0,'m')
% env.waterWave.wave2.phase.setValue(0,'rad')
env.waterWave.wave1.waveNumber.setValue(k ,'rad/m')
env.waterWave.wave1.frequency.setValue(w,'rad/s')
env.waterWave.wave1.amplitude.setValue(Hs,'m')
env.waterWave.wave1.phase.setValue(0,'rad')

env.waterWave.wave2.waveNumber.setValue(0,'rad/m')
env.waterWave.wave2.frequency.setValue(0,'rad/s')
env.waterWave.wave2.amplitude.setValue(0,'m')
env.waterWave.wave2.phase.setValue(0,'rad')
% 





% 
% env.waterWave.wave3.waveNumber.setValue(1,'rad/m')
% env.waterWave.wave3.frequency.setValue(.6,'rad/s')
% env.waterWave.wave3.amplitude.setValue(.1,'m')
% env.waterWave.wave3.phase.setValue(0,'rad')

env.waterWave.waveParamMat.setValue(env.waterWave.structAssem,'');
FLOWCALCULATION = 'constXYZT_planarWave';

saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
