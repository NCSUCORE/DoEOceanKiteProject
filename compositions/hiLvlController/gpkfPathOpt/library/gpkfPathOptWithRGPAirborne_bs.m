clear
clc

HILVLCONTROLLER = 'gpkfPathOptWithRGPinnerLoop';
PATHGEOMETRY = 'lemOfBooth';

loadComponent('ayazAirborneSynFlow');

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
fastTimeStep  = 10/60;
% MPC KFGP time step in MINUTES
mpckfgpTimeStep = 3;
% mpc prediction horizon
predictionHorz  = 6;
% MPC constants
exploitationConstant = 1;
explorationConstant  = 2^6;


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
hiLvlCtrl.exploitationConstant = exploitationConstant;
hiLvlCtrl.explorationConstant  = explorationConstant;

%% inner loop control parameters
hiLvlCtrl.RGPspatialCovFn       = 'squaredExponential';
hiLvlCtrl.RGPmeanFn             = 'constantMean';
hiLvlCtrl.RGPxBasis             = 100*rand(2,20);
hiLvlCtrl.RGPspatialCovAmp      = 1;
hiLvlCtrl.RGPspatialLengthScale = 5;
hiLvlCtrl.RGPnoiseVariance      = 1e-3;
hiLvlCtrl.RGPmeanFnProps        = 0;
hiLvlCtrl.RGPdeviationPenalty   = 0.01;
hiLvlCtrl.initPathShape         = rand(2,1);
hiLvlCtrl.numLapBetweenRGP      = 8;


saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')

