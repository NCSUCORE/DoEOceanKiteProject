% make kalman filter GP object using parameters from environment and
% hi-level controller
kfgp = GP.KalmanFilteredGaussianProcess(hiLvlCtrl.spatialCovFn,...
    hiLvlCtrl.temporalCovFn,hiLvlCtrl.meanFn,hiLvlCtrl.xMeasure,...
    hiLvlCtrl.kfgpTimeStep);

% set params
kfgp.spatialCovAmp       = hiLvlCtrl.spatialCovAmp;
kfgp.spatialLengthScale  = hiLvlCtrl.spatialLengthScale;
kfgp.temporalCovAmp      = 1;
kfgp.temporalLengthScale = hiLvlCtrl.temporalLengthScale;
kfgp.noiseVariance       = hiLvlCtrl.noiseVariance;
kfgp.meanFnProps         = hiLvlCtrl.meanFnProps;
% initialize
kfgp.initVals          = kfgp.initializeKFGP;
kfgp.spatialCovMat     = kfgp.makeSpatialCovarianceMatrix(hiLvlCtrl.xMeasure);
kfgp.spatialCovMatRoot = kfgp.calcSpatialCovMatRoot;

