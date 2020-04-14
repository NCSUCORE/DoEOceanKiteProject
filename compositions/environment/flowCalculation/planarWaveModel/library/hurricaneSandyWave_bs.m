clear all;clc;format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'constXYZT'},'FlowDensities',995);
env.addFlow({'waterWave'},{'planarWaves'});
env.waterWave.setNumWaves(2,'');
env.waterWave.build;


%% calm waves

% Hs = .27   % meters
% tp = 3; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(8.5)%(w^2)/9.81 %rad/m

% Hs = 1.5;   % meters
% tp = 5.7; % seconds
% w =   2*pi/tp % rad/s
% k = (2*pi)/(33.8)%(w^2)/9.81 %rad/m
Hs = 1.33;   % meters
tp = 8.4; % seconds
w =   2*pi/tp; % rad/s
k = (w^2)/9.8; %rad/m



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
