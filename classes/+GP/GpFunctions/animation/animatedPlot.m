function val = animatedPlot(flowData,altData,varargin)

% prase input
pp = inputParser;
addParameter(pp,'plotTimeStep',1,@isnumeric);
addParameter(pp,'regressionResults',struct);
addParameter(pp,'waitForButton',true,@islogical);

parse(pp,varargin{:});

% time vec
tVec = flowData.Time(1):pp.Results.plotTimeStep*60:flowData.Time(end);

% resample data
flowTs = resample(flowData,tVec);
altTs  = resample(altData,tVec);
% local variables
flowVals = flowTs.Data;
altVals  = altTs.Data;
lbFlow = min(flowVals,[],'all');
ubFlow = max(flowVals,[],'all');

colorOrder = [228,26,28
    55,126,184
    77,175,74
    152,78,16]./255;

% number of time steps
nTs = numel(tVec);

% regression data availabe
regDataAvailable = ~any(ismember(pp.UsingDefaults,{'regressionResults'}));

if regDataAvailable
    regRes = pp.Results.regressionResults;
    tVecData = regRes(1).predMean.Time(1):pp.Results.plotTimeStep*60:...
        regRes(1).predMean.Time(end);
    nTs = numel(tVecData);
    ub = nan(numel(regRes),1);
    lb = nan(numel(regRes),1);
    
    for ii = 1:numel(regRes)
        regRes(ii).predMean = resample(regRes(ii).predMean,tVecData);
        regRes(ii).loBound  = resample(regRes(ii).loBound,tVecData);
        regRes(ii).upBound  = resample(regRes(ii).upBound,tVecData);
        regRes(ii).dataSamp = resample(regRes(ii).dataSamp,tVecData);
        
        ub(ii) = max(cat(3,regRes(ii).loBound.Data,regRes(ii).upBound.Data),[],'all');
        lb(ii) = min(cat(3,regRes(ii).loBound.Data,regRes(ii).upBound.Data),[],'all');
        
    end
    lb = min([lb(:);lbFlow]);
    ub = max([ub(:);ubFlow]);
    dataAltVals  = regRes(1).dataAlts.Data(:,1);
    
else
    lb = lbFlow;
    ub = ubFlow;
end



% create axis object
axisObj = axes;
% set axis properties
grid(axisObj,'on');
hold(axisObj,'on');
xlabel(axisObj,'Flow speed (m/s)');
ylabel(axisObj,'Altitude (m)');
set(axisObj,'FontSize',11);
axisObj.YLim = [altVals(1,1,1) altVals(end,1,1)];
% xlimits
xlimRes = 2;
% fancy rounding
xLoLim = floor(lb) - mod(floor(lb),xlimRes);
xHiLim = ceil(ub) + mod(ceil(ub),xlimRes);
% set value
axisObj.XLim = [xLoLim xHiLim];

% create flow plot object
plotFlowObj = plot(flowVals(:,:,1),altVals(:,1,1),'k-',...
    'linewidth',1);
legend(plotFlowObj,'Flow');

if regDataAvailable
    pMeanData = gobjects;
    plbData   = gobjects;
    pubData   = gobjects;
    pSampData = gobjects;
    
    for ii = 1:numel(regRes)
        pMeanData(ii) = plot(regRes(ii).predMean.Data(:,1,1),dataAltVals,'-',...
            'color',colorOrder(ii,:));
        plbData(ii) = plot(regRes(ii).loBound.Data(:,1,1),dataAltVals,'--',...
            'color',colorOrder(ii,:));
        pubData(ii) = plot(regRes(ii).upBound.Data(:,1,1),dataAltVals,'--',...
            'color',colorOrder(ii,:));
        pSampData(ii) = plot(regRes(ii).dataSamp.Data(2,1,1),...
            regRes(ii).dataSamp.Data(1,1,1),'mo');
    end
    legend([plotFlowObj;pMeanData(:)],[{'Flow'},{regRes(:).legend}]);
    
end

% make animation
% val = struct('cdata',uint8(zeros(840,1680,3)),'colormap',[]);
val = struct('cdata',uint8(zeros(525,700,3)),'colormap',[]);
val(1) = acquireFrame;

for ii = 2:nTs
    
    % update plot
    plotFlowObj.XData = flowVals(:,:,ii);
    
    if regDataAvailable && tVec(ii) <= max(tVecData)
        for jj = 1:numel(regRes)
            pMeanData(jj).XData = regRes(jj).predMean.Data(:,1,ii);
            plbData(jj).XData = real(regRes(jj).loBound.Data(:,1,ii));
            pubData(jj).XData = real(regRes(jj).upBound.Data(:,1,ii));
            pSampData(jj).XData = regRes(jj).dataSamp.Data(2,1,ii);
            pSampData(jj).YData = regRes(jj).dataSamp.Data(1,1,ii);
            
        end
    end
    
    title(sprintf('Time = %.2f min',tVec(ii)/60));
    
    % get frame for animation
    val(ii) = acquireFrame;
    
    if pp.Results.waitForButton
        waitforbuttonpress;
    end
    
end

end

function F = acquireFrame()
F = getframe;
% cdata = print('-RGBImage','-r120');
% F = im2frame(cdata);
end