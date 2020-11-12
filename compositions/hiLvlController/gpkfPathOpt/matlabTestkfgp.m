clear
clc
close all

cd(fileparts(mfilename('fullpath')));


%% initialize KFGP
rng(8);

% altitudes
altitudes = 0:100:1000;
kfgpTimeStep = 0.2;

% spatial kernel
spaceKernel = 'squaredExponential';
timeKernel  = 'squaredExponential';

kfgp = GP.KalmanFilteredGaussianProcess(spaceKernel,timeKernel,...
    'windPowerLaw',altitudes,kfgpTimeStep);

kfgp.spatialCovAmp       = 5.1^2;
kfgp.spatialLengthScale  = 220;
kfgp.temporalCovAmp      = 1;
kfgp.temporalLengthScale = 22;
kfgp.noiseVariance       = 1e-3;
kfgp.meanFnProps         = [3.77 0.14];

kfgp.initVals = kfgp.initializeKFGP;
kfgp.spatialCovMat = kfgp.makeSpatialCovarianceMatrix(altitudes);
kfgp.spatialCovMatRoot = kfgp.calcSpatialCovMatRoot;

save('tt','kfgp');

%% generate synthetic flow data
% number of altitudes
nAlt = numel(altitudes);
% final time for data generation in minutes
tFinData = 600;
% time step for synthetic data generation
timeStepSynData = 3;
% standard deviation for synthetic data generation
stdDevSynData = 4;
% get the time series object
[synFlow,synAlt] = kfgp.generateSyntheticFlowData(altitudes,tFinData,stdDevSynData,...
    'timeStep',timeStepSynData);

% axisObj = paperFlowPlot(synFlow,altitudes,30,180);
% keyboard
close

%% regression using KFGP
% algorithm final time
algFinTime = 300;
% sampling time vector
tSamp = 0:kfgp.kfgpTimeStep:algFinTime;
% number of samples
nSamp = numel(tSamp);

% preallocat sampling matrices
xSamp   = NaN(1,nSamp);
ySamp   = NaN(nSamp,1);
flowVal = NaN(nSamp,1);
XTSamp  = NaN(2,nSamp);

% preallocate matrices for KFGP
predMeansKFGP = NaN(nAlt,nSamp);
postVarsKFGP  = NaN(nAlt,nSamp);
stdDevKFGP    = NaN(nAlt,nSamp);
upBoundKFGP   = NaN(nAlt,nSamp);
loBoundKFGP   = NaN(nAlt,nSamp);

% number of std deviations for bounds calculations
numStdDev = 1;

%% initialize MPC KFGP
% mpc time step
mpckfgpTimeStep = 3;
% mpc prediction horizon
predictionHorz  = 6;
% fmincon options
options = optimoptions('fmincon','algorithm','sqp','display','off');
% make new KFGP to maintain MPC calculations
mpckfgp = GP.KalmanFilteredGaussianProcess(spaceKernel,timeKernel,...
    'windPowerLaw',altitudes,mpckfgpTimeStep);

mpckfgp.spatialCovAmp       = kfgp.spatialCovAmp;
mpckfgp.spatialLengthScale  = kfgp.spatialLengthScale;
mpckfgp.temporalCovAmp      = kfgp.temporalCovAmp;
mpckfgp.temporalLengthScale = kfgp.temporalLengthScale;
mpckfgp.noiseVariance       = kfgp.noiseVariance;

mpckfgp.initVals            = mpckfgp.initializeKFGP;
mpckfgp.spatialCovMat       = mpckfgp.makeSpatialCovarianceMatrix(altitudes);
mpckfgp.spatialCovMatRoot   = mpckfgp.calcSpatialCovMatRoot;

mpckfgp.tetherLength        = 1000;

% acquistion function parameters
mpckfgp.exploitationConstant = 1;
mpckfgp.explorationConstant  = 2^6;
mpckfgp.predictionHorizon    = predictionHorz;

% max mean elevation angle step size
duMax = 6;
Astep = zeros(predictionHorz-1,predictionHorz);
bstep = duMax*ones(2*(predictionHorz-1),1);
for ii = 1:predictionHorz-1
    for jj = 1:predictionHorz
        if ii == jj
            Astep(ii,jj) = -1;
            Astep(ii,jj+1) = 1;
        end
        
    end
end
Astep = [Astep;-Astep];
% bounds on first step
fsBoundsA = zeros(2,predictionHorz);
fsBoundsA(1,1) = 1;
fsBoundsA(2,1) = -1;
A = [fsBoundsA;Astep];
% upper and lower bounds
minElev = 5;
lb      = minElev*ones(1,predictionHorz);
maxElev = 60;
ub      = maxElev*ones(1,predictionHorz);

uAllowable = linspace(-duMax,duMax,5);

% number of times mpc will trigger
nMPC         = floor(tSamp(end)/mpckfgpTimeStep);
tMPC         = nan(1,nMPC);
jObjFmin     = nan(1,nMPC);
jExploitFmin = nan(1,nMPC);
jExploreFmin = nan(1,nMPC);
uTrajFmin    = nan(predictionHorz,nMPC);

jObjBF     = nan(1,nMPC);
jExploitBF = nan(1,nMPC);
jExploreBF = nan(1,nMPC);
uTrajBF    = nan(predictionHorz,nMPC);

% omniscient controller preallocation
fValOmni       = nan(1,nSamp);
runAvgOmni     = nan(1,nSamp);
omniElev       = nan(1,nSamp);
elevsAtAllAlts = min(max(minElev,asin(altitudes/mpckfgp.tetherLength)*180/pi),maxElev);
omniAlts = mpckfgp.convertMeanElevToAlt(elevsAtAllAlts);
cosElevAtAllAlts = cosd(elevsAtAllAlts);
meanFnVec = kfgp.meanFunction(altitudes);

% baseline contoller
fValBaseline   = nan(1,nSamp);
runAvgbaseline = nan(1,nSamp);
% KFGP control
fValKFGP     = nan(1,nSamp);
KFGPElev     = nan(1,nSamp);
runAvgKFGP   = nan(1,nSamp);

% mpc counter
jj = 1;

%% omniscient
for ii = 1:nSamp
    % measure flow at xSamp(ii) at tSamp(ii)
    fData = resample(synFlow,tSamp(ii)*60).Data;
    hData = resample(synAlt,tSamp(ii)*60).Data;
    % calculate pseudo power
    % omniscient, uncontrained controller
    omnifData = interp1(hData,fData,omniAlts);
    [fValOmni(ii),omniIdx] = max(cosineFlowCubed(omnifData,cosElevAtAllAlts));
    runAvgOmni(ii) = mean(fValOmni(1:ii));
    omniElev(ii) = elevsAtAllAlts(omniIdx);
end

%% baseline
baselineElev   = ceil(mean(omniElev));
baselineAlt    = mpckfgp.tetherLength*sind(baselineElev);

for ii = 1:nSamp
    % measure flow at xSamp(ii) at tSamp(ii)
    fData = resample(synFlow,tSamp(ii)*60).Data;
    hData = resample(synAlt,tSamp(ii)*60).Data;
    % base line
    fValBaseline(ii) = cosineFlowCubed(interp1(hData,fData,baselineAlt),cosd(baselineElev));
    runAvgbaseline(ii) = mean(fValBaseline(1:ii));
end

%% do the regresson
for ii = 1:nSamp
    % go to xSamp
    if ii == 1
        nextPoint = baselineAlt;
    end
    xSamp(ii) = nextPoint;
    % measure flow at xSamp(ii) at tSamp(ii)
    fData = resample(synFlow,tSamp(ii)*60).Data;
    hData = resample(synAlt,tSamp(ii)*60).Data;
    flowVal(ii) = interp1(hData,fData,xSamp(ii));
    ySamp(ii) =  kfgp.meanFunction(xSamp(ii)) - flowVal(ii);
    % calculate pseudo power
    % KFGP
    KFGPElev(ii)  = asin(xSamp(ii)/mpckfgp.tetherLength)*180/pi;
    fValKFGP(ii)  = cosineFlowCubed(flowVal(ii),cosd(KFGPElev(ii)));
    runAvgKFGP(ii) = mean(fValKFGP(1:ii));
    % augment altitude and height in XTsamp
    XTSamp(:,ii) = [xSamp(ii);tSamp(ii)];
    % recursion
    if ii == 1
        % KFGP: initial state estimate
        sk_k   = kfgp.initVals.s0;
        ck_k   = kfgp.initVals.sig0Mat;
    else
        % KFGP: initial state estimate
        sk_k   = skp1_kp1;
        ck_k   = ckp1_kp1;
    end
    % KFGP: calculate kalman states
    [F_t,sigF_t,skp1_kp1,ckp1_kp1] = ...
        kfgp.calcKalmanStateEstimates(sk_k,ck_k,xSamp(ii),ySamp(ii));
    % KFGP: calculate prediction mean and posterior variance
    [muKFGP,sigKFGP] = kfgp.calcPredMeanAndPostVar(altitudes,F_t,sigF_t);
    % KFGP: store them
    predMeansKFGP(:,ii) = meanFnVec(:) - muKFGP;
    postVarsKFGP(:,ii)  = sigKFGP;
    % KFGP: calculate bounds
    stdDevKFGP(:,ii) = postVarsKFGP(:,ii).^0.5;
    % KFGP: upper bounds = mean + x*(standard deviation)
    upBoundKFGP(:,ii) = predMeansKFGP(:,ii) + numStdDev*stdDevKFGP(:,ii);
    % KFGP: lower bounds = mean - x*(standard deviation)
    loBoundKFGP(:,ii) = predMeansKFGP(:,ii) - numStdDev*stdDevKFGP(:,ii);
    % MPCKFGP: make decision about next point
    meanElevation = asin(xSamp(ii)/mpckfgp.tetherLength)*180/pi;
    fsBoundsB(1,1) = meanElevation + duMax;
    fsBoundsB(2,1) = -(meanElevation - duMax);
    b = [fsBoundsB;bstep];
    
    if ii>1 && mod(tSamp(ii),mpckfgp.kfgpTimeStep) == 0
        tMPC(jj) = tSamp(ii);
        % mpc kalman estimate
        [F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc] = ...
            mpckfgp.calcKalmanStateEstimates(sk_k,ck_k,xSamp(ii),ySamp(ii));
        
        % use fminc to solve for best trajectory
        [bestTraj,mpcObj] = ...
            fmincon(@(u) -mpckfgp.calcMpcObjectiveFn(...
            F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc...
            ,u),meanElevation*ones(predictionHorz,1),A,b,[],[]...
            ,lb,ub,[],options);
        uTrajFmin(:,jj) = mpckfgp.calcDelevTraj(meanElevation,bestTraj);
        % get other values
        [jObjFmin(jj),jExptFmin,jExpreFmin] = ...
            mpckfgp.calcMpcObjectiveFn(...
            F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc,...
            bestTraj);
        jExploitFmin(jj) = sum(jExptFmin);
        jExploreFmin(jj) = sum(jExpreFmin);
        
        % brute force
%         bruteForceTraj = mpckfgp.bruteForceTrajectoryOpt(...
%             F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc,...
%             meanElevation,uAllowable,lb(1),ub(1));
%         uTrajBF(:,jj) = mpckfgp.calcDelevTraj(meanElevation,bruteForceTraj);
%         % get other values
%         [jObjBF(jj),jExptBF,jExprBF] = ...
%             mpckfgp.calcMpcObjectiveFn(...
%             F_t_mpc,sigF_t_mpc,skp1_kp1_mpc,ckp1_kp1_mpc,...
%             bruteForceTraj);
%         jExploitBF(jj) = sum(jExptBF);
%         jExploreBF(jj) = sum(jExprBF);

        % next point
        nextPoint = mpckfgp.convertMeanElevToAlt(bestTraj(1));
%         nextPoint = mpckfgp.convertMeanElevToAlt(bruteForceTraj(1));
        disp(['FMINCON :',num2str(mpckfgp.convertMeanElevToAlt(bestTraj'),'%.3f ')]);
%         disp(['BF      :',num2str(mpckfgp.convertMeanElevToAlt(bruteForceTraj),'%.3f ')]);
        fprintf('\n');
        jj = jj+1;
    end
    
end



%% convert results to time series and store in strcut
regressionRes(1).predMean  = timeseries(predMeansKFGP,tSamp*60);
regressionRes(1).loBound   = timeseries(loBoundKFGP,tSamp*60);
regressionRes(1).upBound   = timeseries(upBoundKFGP,tSamp*60);
regressionRes(1).dataSamp  = timeseries([xSamp;flowVal'],tSamp*60);
regressionRes(1).dataAlts  = synAlt;
regressionRes(1).legend    = 'KFGP';

save('testRes','regressionRes','kfgp','synFlow','synAlt','algFinTime',...
    'mpckfgp','duMax','minElev','maxElev');

meanVals = [mean(fValOmni) mean(fValBaseline) mean(fValKFGP)];

basePerc = 100*mean(fValBaseline)/mean(fValOmni);
mpcPerc = 100*mean(fValKFGP)/mean(fValOmni);
fprintf('du exp baseline mpc\n');
fprintf('%0.0f & %.0f & %.2f & %.2f\n',...
    [duMax mpckfgp.explorationConstant basePerc mpcPerc]);

% fName = ['results\KFGPres ',strrep(datestr(datetime),':','-'),'.mat'];
% save(fName);

%% plot the data
cols = [228,26,28
    77,175,74
    55,126,184]/255;

spIdx = 1;
spAxes = gobjects;
spObj = gobjects;

lwd = 1.2;
tSampPlot = tSamp/60;

% plot elevation angle trajectory
pIdx = 1;
spAxes(spIdx) = subplot(3,1,spIdx);
hold(spAxes(spIdx),'on');
ylabel(spAxes(spIdx),'$\mathbf{\theta_{sp}}$ \textbf{[deg]}','fontweight','bold');
spObj(pIdx) = stairs(tSampPlot,omniElev...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);
pIdx = pIdx + 1;
spObj(pIdx) = plot([tSampPlot(1) tSampPlot(end)],baselineElev*[1 1]...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);
pIdx = pIdx + 1;
spObj(pIdx) = stairs(tSampPlot,KFGPElev...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);

% plot instantaenuos jExploit
spIdx = spIdx + 1;
spAxes(spIdx) = subplot(3,1,spIdx);
pIdx = 1;
hold(spAxes(spIdx),'on');
ylabel(spAxes(spIdx),'$\mathbf{J_{exploit}(t_{k})}$','fontweight','bold');
spObj(pIdx) = plot(tSampPlot,fValOmni...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);
pIdx = pIdx + 1;
spObj(pIdx) = plot(tSampPlot,fValBaseline...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);
pIdx = pIdx + 1;
spObj(pIdx) = plot(tSampPlot,fValKFGP...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);

% plot running average j_exploit
spIdx = spIdx + 1;
spAxes(spIdx) = subplot(3,1,spIdx);
pIdx = 1;
hold(spAxes(spIdx),'on');
ylabel(spAxes(spIdx),'\textbf{Avg.} $\mathbf{J_{exploit}}$','fontweight','bold');
spObj(pIdx) = plot(tSampPlot,runAvgOmni...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);
pIdx = pIdx + 1;
spObj(pIdx) = plot(tSampPlot,runAvgbaseline...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);
pIdx = pIdx + 1;
spObj(pIdx) = plot(tSampPlot,runAvgKFGP...
    ,'-'...
    ,'color',cols(pIdx,:)...
    ,'MarkerFaceColor',cols(pIdx,:)...
    ,'linewidth',lwd);
legend('Omniscient','Baseline','MPC','location','bestoutside'...
    ,'orientation','horizontal')

% axes props
grid(spAxes(1:end),'on');
set(spAxes(1:end),'GridLineStyle',':')
xlabel(spAxes(1:end),'\textbf{Time [hr]}','fontweight','bold');   
set(spAxes(1:end),'FontSize',12);
% spAxes(1).YTick = linspace(spAxes(1).YTick(1),spAxes(1).YTick(end),3);
% spAxes(2).YTick = linspace(spAxes(2).YTick(1),spAxes(2).YTick(end),3);
set(gcf,'InnerPosition',1*[-00 -00 560 1.8*420])

spAxes(1).YLabel.Position(1) = spAxes(2).YLabel.Position(1);
spAxes(3).YLabel.Position(1) = spAxes(2).YLabel.Position(1);

%%

% 
% saveFile = input('Save file? Options: Enter y or n\n','s');
% if strcmpi(saveFile,'y')
% filName = strcat('ctrlRes_',strrep(datestr(datetime),':','-'));
% save(filName);
% savefig(filName);
% exportgraphics(gcf,[filName,'.png'],'Resolution',600)
% end




%% animation
% figure
% F = animatedPlot(synFlow,synAlt,'plotTimeStep',0.25,...
%     'regressionResults',regressionRes...
%     ,'waitforbutton',false);


