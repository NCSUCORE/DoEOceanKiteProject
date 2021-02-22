% make kalman filter GP object using parameters from environment and
% hi-level controller
mpckfgp = GP.KalmanFilteredGaussianProcess(hiLvlCtrl.spatialCovFn,...
    hiLvlCtrl.temporalCovFn,hiLvlCtrl.meanFn,hiLvlCtrl.xMeasure,...
    hiLvlCtrl.mpckfgpTimeStep);

% set params
mpckfgp.spatialCovAmp       = hiLvlCtrl.spatialCovAmp;
mpckfgp.spatialLengthScale  = hiLvlCtrl.spatialLengthScale;
mpckfgp.temporalCovAmp      = 1;
mpckfgp.temporalLengthScale = hiLvlCtrl.temporalLengthScale;
mpckfgp.noiseVariance       = hiLvlCtrl.noiseVariance;
mpckfgp.meanFnProps         = hiLvlCtrl.meanFnProps;
% initialize
mpckfgp.initVals            = mpckfgp.initializeKFGP;
mpckfgp.spatialCovMat       = mpckfgp.makeSpatialCovarianceMatrix(hiLvlCtrl.xMeasure);
mpckfgp.spatialCovMatRoot   = mpckfgp.calcSpatialCovMatRoot;

%
mpckfgp.predictionHorizon    = hiLvlCtrl.predictionHorz;
mpckfgp.exploitationConstant = hiLvlCtrl.exploitationConstant;
mpckfgp.explorationConstant  = hiLvlCtrl.explorationConstant;

            


