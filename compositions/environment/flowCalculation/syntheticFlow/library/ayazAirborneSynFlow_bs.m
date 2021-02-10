clear all;clc;format compact

%% Set up environment
% Create
env = ENV.env;
env.addFlow({'water'},{'syntheticFlow'},'FlowDensities',1.225);

env.water.spatialCovFn = 'squaredExponential';
env.water.spatialLengthScale.setValue(220,'m');
env.water.spatialCovAmp.setValue(5.1^2,'m^2');
env.water.temporalCovFn = 'squaredExponential';
env.water.temporalLengthScale.setValue(22*60,'s');
env.water.meanFn = 'windPowerLaw';
env.water.noiseVariance.setValue(1e-3,'');
env.water.rngSeed.setValue(8,'');
env.water.zGridPoints.setValue(0:100:1000,'m');
env.water.stdDevSynData.setValue(2,'m/s');
env.water.timeStepSynData.setValue(3*60,'s');
env.water.tFinData.setValue(600*60,'s');
env.water.meanFnProps.setValue([3.77,0.14],'');
env.water.minFlowVal.setValue(7,'m/s');

[synFlow,synAlt] = env.water.generateData();

FLOWCALCULATION = 'syntheticFlow';
ENVIRONMENT     = 'environmentSyntheticFLow';

saveBuildFile('env',mfilename,'variant',["FLOWCALCULATION","ENVIRONMENT"]);

figure
animatedPlot(synFlow,synAlt,'plotTimeStep',1);