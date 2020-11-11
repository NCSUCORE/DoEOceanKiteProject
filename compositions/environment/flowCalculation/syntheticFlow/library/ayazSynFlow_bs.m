clear all;clc;format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'syntheticFlow'},'FlowDensities',1000);

env.water.spatialCovFn = 'squaredExponential';
env.water.spatialLengthScale.setValue(40,'m');
env.water.spatialCovAmp.setValue(4^2,'m^2');
env.water.temporalCovFn = 'squaredExponential';
env.water.temporalLengthScale.setValue(20*60,'s');
env.water.meanFn = 'constantMean';
env.water.noiseVariance.setValue(1e-3,'');
env.water.rngSeed.setValue(1,'');
env.water.zGridPoints.setValue(10:10:200,'m');
env.water.stdDevSynData.setValue(0.5,'m/s');
env.water.timeStepSynData.setValue(1*60,'s');
env.water.tFinData.setValue(500*60,'s');
env.water.meanFnProps.setValue(1.5,'');

% env.waterWave.waveParamMat.setValue(env.waterWave.structAssem,'');
% FLOWCALCULATION = 'constXYZT_planarWave';
FLOWCALCULATION = 'syntheticFlow';
ENVIRONMENT     = 'environmentSyntheticFLow';

saveBuildFile('env',mfilename,'variant',["FLOWCALCULATION","ENVIRONMENT"]);
