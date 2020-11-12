clear
clc

HILVLCONTROLLER = 'gpkfPathOpt';

loadComponent('ayazSynFlow');

% z grid
xMeasure            = env.water.zGridPoints.Value;
% spatial covarirance kernel
spatialCovFn        = env.water.spatialCovFn;
% temporal covariance kernel
temporalCovFn       = env.water.temporalCovFn;
% mean function
meanFn              = env.water.meanFn;
% spatial covariance amplitude
spatialCovAmp       = env.water.spatialCovAmp.Value;
% spatial length scale
spatialLengthScale  = env.water.spatialLengthScale.Value;
% temporal length scale
temporalLengthScale = env.water.temporalLengthScale.Value;
% noise variance
noiseVar            = env.water.noiseVariance.Value;

% fast state estimate time step in MINUTES
fastTimeStep  = 0.2;
% MPC KFGP time step in MINUTES
mpckfgpTimeStep = 3;
% mpc prediction horizon
predictionHorz  = 6;
% MPC constants
exploitationConstant = 1;
explorationConstant  = 2^6;
% step limits and bounds
duMax = 6;
minElev = 5;
maxElev = 60;


hiLvlCtrl.spatialCovFn         = spatialCovFn;
hiLvlCtrl.temporalCovFn        = temporalCovFn;
hiLvlCtrl.meanFn               = meanFn;
hiLvlCtrl.kfgpTimeStep         = fastTimeStep;
hiLvlCtrl.xMeasure             = xMeasure;
hiLvlCtrl.spatialCovAmp        = spatialCovAmp;
hiLvlCtrl.spatialLengthScale   = spatialLengthScale;
hiLvlCtrl.temporalCovAmp       = 1;
hiLvlCtrl.temporalLengthScale  = temporalLengthScale;
hiLvlCtrl.noiseVariance        = noiseVar;
hiLvlCtrl.meanFnProps          = env.water.meanFnProps.Value;
%%
hiLvlCtrl.mpckfgpTimeStep      = mpckfgpTimeStep;
hiLvlCtrl.predictionHorz       = predictionHorz;
hiLvlCtrl.exploitationConstant = predictionHorz;
hiLvlCtrl.explorationConstant  = predictionHorz;
hiLvlCtrl.maxStepChange        = duMax;
hiLvlCtrl.minVal               = minElev;
hiLvlCtrl.maxVal               = maxElev;




saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');


