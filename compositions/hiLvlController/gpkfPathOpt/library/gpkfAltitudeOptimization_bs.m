clear
clc

HILVLCONTROLLER = 'gpkfAltitudeOpt';
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
fastTimeStep  = 12/60;
% MPC KFGP time step in MINUTES
mpckfgpTimeStep = 3;
% mpc prediction horizon
predictionHorz  = 6;
% MPC constants
exploitationConstant = 1;
explorationConstant  = 0;


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

%% mpc controller properties
hiLvlCtrl.mpckfgpTimeStep      = mpckfgpTimeStep;
hiLvlCtrl.predictionHorz       = predictionHorz;
hiLvlCtrl.exploitationConstant = exploitationConstant;
hiLvlCtrl.explorationConstant  = explorationConstant;

%% extract values from power map
load('PowStudyAir.mat');
R.Pmax(isnan(R.Pmax)) = -100;
hiLvlCtrl.pMaxVals  = R.Pmax;
[A,F] = meshgrid(altitude,flwSpd);
hiLvlCtrl.altVals   = A;
hiLvlCtrl.flowVals  = F;
hiLvlCtrl.powFunc   = griddedInterpolant(F,A,R.Pmax);
saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')

