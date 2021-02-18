clear
clc

%% load matlab data
load('testRes.mat');

%%
zTraj = regressionRes.dataSamp;

hiLvlCtrl.spatialCovFn        = 'squaredExponential';
hiLvlCtrl.temporalCovFn       = 'squaredExponential';
hiLvlCtrl.meanFn              = 'windPowerLaw';
hiLvlCtrl.kfgpTimeStep        = kfgp.kfgpTimeStep;
hiLvlCtrl.xMeasure            = kfgp.xMeasure;
hiLvlCtrl.spatialCovAmp       = kfgp.spatialCovAmp;
hiLvlCtrl.spatialLengthScale  = kfgp.spatialLengthScale;
hiLvlCtrl.temporalLengthScale = kfgp.temporalLengthScale;
hiLvlCtrl.noiseVariance       = kfgp.noiseVariance;
hiLvlCtrl.meanFnProps         = kfgp.meanFnProps;

% ss = sim('calcKalmanEstimate_th');

hiLvlCtrl.mpckfgpTimeStep      = mpckfgp.kfgpTimeStep;
hiLvlCtrl.predictionHorz       = mpckfgp.predictionHorizon;
hiLvlCtrl.exploitationConstant = mpckfgp.exploitationConstant;
hiLvlCtrl.explorationConstant  = mpckfgp.explorationConstant;
hiLvlCtrl.maxStepChange        = duMax;
hiLvlCtrl.minVal               = minElev;
hiLvlCtrl.maxVal               = maxElev;
hiLvlCtrl.initVals             = (180/pi)*asin(zTraj.Data(1,1,1)/mpckfgp.tetherLength);
hiLvlCtrl.basisParams.Value    = ones(5,1);
hiLvlCtrl.rateLimit    = 5;


sss = sim('gpkfPathOpt_th');

plot(regressionRes(1).dataSamp.Time(:),squeeze(regressionRes(1).dataSamp.Data(1,:,:)));
hold on
sss.optAlts.plot;

regressionRes(2).predMean  = sss.predMean;
regressionRes(2).loBound   = sss.loBound;
regressionRes(2).upBound   = sss.upBound;
regressionRes(2).dataSamp  = regressionRes(1).dataSamp;
regressionRes(2).dataAlts  = synAlt;
regressionRes(2).legend    = 'SIM';
regressionRes(1).legend    = 'MAT';

% figure
% F = animatedPlot(synFlow,synAlt,'plotTimeStep',0.25,...
%     'regressionResults',regressionRes...
%     ,'waitforbutton',false);


