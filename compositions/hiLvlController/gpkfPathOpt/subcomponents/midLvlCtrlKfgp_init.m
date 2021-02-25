% make kalman filter GP object using parameters from environment and
% hi-level controller
midLvlKfgp = GP.KalmanFilteredGaussianProcess(hiLvlCtrl.spatialCovFn,...
    hiLvlCtrl.temporalCovFn,hiLvlCtrl.meanFn,hiLvlCtrl.xMeasure,...
    hiLvlCtrl.midLvlCtrl.dt);

% set params
midLvlKfgp.spatialCovAmp       = hiLvlCtrl.spatialCovAmp;
midLvlKfgp.spatialLengthScale  = hiLvlCtrl.spatialLengthScale;
midLvlKfgp.temporalCovAmp      = 1;
midLvlKfgp.temporalLengthScale = hiLvlCtrl.temporalLengthScale;
midLvlKfgp.noiseVariance       = hiLvlCtrl.noiseVariance;
midLvlKfgp.meanFnProps         = hiLvlCtrl.meanFnProps;
% initialize
midLvlKfgp.initVals            = midLvlKfgp.initializeKFGP;
midLvlKfgp.spatialCovMat       = midLvlKfgp.makeSpatialCovarianceMatrix(hiLvlCtrl.xMeasure);
midLvlKfgp.spatialCovMatRoot   = midLvlKfgp.calcSpatialCovMatRoot;

%
midLvlKfgp.predictionHorizon    = hiLvlCtrl.midLvlCtrl.predHorz;