% make kalman filter GP object using parameters from environment and
% hi-level controller
rgp = GP.RecursiveGaussianProcess(hiLvlCtrl.RGPspatialCovFn,...
    hiLvlCtrl.RGPmeanFn,hiLvlCtrl.RGPxBasis);

% set params
rgp.spatialCovAmp       = hiLvlCtrl.RGPspatialCovAmp;
rgp.spatialLengthScale  = hiLvlCtrl.RGPspatialLengthScale;
rgp.noiseVariance       = hiLvlCtrl.RGPnoiseVariance;
rgp.meanFnProps         = hiLvlCtrl.RGPmeanFnProps;
% initialize
rgp.spatialCovMat = rgp.makeSpatialCovarianceMatrix(hiLvlCtrl.RGPxBasis);
rgp.meanFnVector  = rgp.meanFunction(hiLvlCtrl.RGPxBasis,rgp.meanFnProps);
% control params
rgp.deviationPenalty = hiLvlCtrl.RGPdeviationPenalty;
rgp.numLapBetweenRGP = hiLvlCtrl.numLapBetweenRGP;

