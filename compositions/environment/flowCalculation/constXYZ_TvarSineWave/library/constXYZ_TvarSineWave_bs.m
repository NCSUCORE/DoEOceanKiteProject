%clear all
 %clc
% format compact

%% Set up environment
% Create
%duration_s is needed in workspace to run this file
env = ENV.constXYZ_TvarSineWave;
env.gravAccel.setValue(9.81,'m/s^2')
env.addFlow({'water'},{'constXYZ_TvarSineWave'},'FlowDensities',1000)
env.waveBias.setValue(1.5,'')
env.amplitude.setValue(0,'')
env.frequency.setValue(.001,'1/s')
env.phase.setValue(0,'rad')
env.azimuth.setValue(0,'rad')
env.elevation.setValue(0,'rad')
environment_bc
env.water.nominal100mFlowVec.setValue( 1.5,'m/s') 
FLOWCALCULATION = 'constXYZ_TvarSineWave';

 saveBuildFile('env',mfilename,'variant','FLOWCALCULATION');
