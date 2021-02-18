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
% load data from file
T = readtable('PowerWithPathShape.xlsx','Sheet','Sheet1');
tData = T{:,:};
tData(tData(:,end)>1.1,:) = [];
xMeasured   = tData(:,2:3)';
yMeasured   = tData(:,end-4);
pathWidths  = 15:2.5:45;
pathHeights = 6:1.5:15;
[PW,PH] = meshgrid(pathWidths,pathHeights);
% make an instant of the RGP class to optimize hyperparameters
rgpSpatialCovaraince = 'squaredExponential';
rgpMeanFn            = 'constantMean';
rgp = GP.RecursiveGaussianProcess(rgpSpatialCovaraince,rgpMeanFn,...
    [PW(:)';PH(:)']);

rgp.meanFnProps         = [0];
rgp.noiseVariance       = 1e-3;
optHyp = rgp.findOptSpatialHyperParams(xMeasured,yMeasured,...
    [1;1;1]);
% rgp.spatialCovAmp       = optHyp.opt_spatialCovAmp;
% rgp.spatialLengthScale  = optHyp.opt_spatialLengthScale;

rgp.spatialCovAmp       = 1;
rgp.spatialLengthScale  = [5;5];

rgp.spatialCovMat = rgp.makeSpatialCovarianceMatrix(rgp.xBasis);
rgp.meanFnVector  = rgp.meanFunction(rgp.xBasis);

% pick random measurement
randMeasure = randi(length(yMeasured));
[predMean,postVarMat] =...
    rgp.calcPredMeanAndPostVar(rgp.meanFnVector,rgp.spatialCovMat,...
    xMeasured(:,randMeasure),yMeasured(randMeasure));

scatter3(rgp.xBasis(1,:),rgp.xBasis(2,:),predMean);

hiLvlCtrl.RGPspatialCovFn       = rgpSpatialCovaraince;
hiLvlCtrl.RGPmeanFn             = rgpMeanFn;

hiLvlCtrl.RGPxBasis             = rgp.xBasis;

hiLvlCtrl.RGPspatialCovAmp      = rgp.spatialCovAmp;
hiLvlCtrl.RGPspatialLengthScale = rgp.spatialLengthScale;
hiLvlCtrl.RGPnoiseVariance      = 1e-1;
hiLvlCtrl.RGPmeanFnProps        = 0;
hiLvlCtrl.RGPdeviationPenalty   = 0.01;
hiLvlCtrl.initPathShape         = [50;12];
hiLvlCtrl.numLapBetweenRGP      = 4;


saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
save(saveFile,'PATHGEOMETRY','-append')

