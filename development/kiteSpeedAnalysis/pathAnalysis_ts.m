clear
clc
% close all
fIdx = 1;

%% initailize
% load vehicle
load('ayazFullScaleOneThrVhcl.mat');

% initialize class
cIn = maneuverabilityAdvanced(vhcl);
cIn.fluidCoeffCalcMethod = 'fromTable';
cIn.wingOswaldEff = 0.3;
cIn.hstabOswaldEff = 0.6;
cIn.hstabZerAoADrag = 0.1*cIn.hstabZerAoADrag;
cIn.vstabOswaldEff = 0.3;

% tether length
cIn.tetherLength = 100;

%% analysis conditions
% path shapes
meanElevations = 10:5:40;
widths = 10:5:60;
heights = 2:2:16;

% flow speed
flows = 0.25:0.25:2;

% number of path shapes
numPathShapes = numel(meanElevations)*numel(widths)*numel(heights);

% number of flows
nFlows = numel(flows);

% make combination of path shapes
pShapeComb = NaN(numPathShapes,4);
cc = 1;
for ii = 1:numel(meanElevations)
    for jj = 1:numel(widths)
        for kk = 1:numel(heights)
            pShapeComb(cc,1:3) = [meanElevations(ii) widths(jj) heights(kk)];
            [a,b] = boothParamConversion(widths(jj)*pi/180,heights(kk)*pi/180);
            pLength = calculatePathLength(a,b,meanElevations(ii)*pi/180,...
                cIn.tetherLength);
            pShapeComb(cc,4) = pLength;
            cc = cc+1;
        end
    end
end

cIn.meanElevationInRadians = 30*pi/180;

% flow vel in ground frame
flowSpeed = 1;

% tangent pitch angle
tgtPitch = 6*pi/180;
elevatorDeflection = 0;

%% path param
pathParam = linspace(0,2*pi,11);

%% radius of curvature analysis
% pRc = gobjects;
% fIdx = fIdx+1;
% figure(fIdx);
kk = 1;

for ii = 1:numel(numFlows)
    for jj = 1:numel(numSims)
        
        % Path basis parameters
        cIn.pathWidth = widths(ii);
        cIn.pathHeight = heights(jj);
        
        solVals = cIn.getAttainableVelocityOverPath(flowSpeed,...
            tgtPitch,pathParam);
        
        pathAnalysisRes(kk).pathSpeed  = solVals.vH_path;
        pathAnalysisRes(kk).rollAng    = solVals.roll_path;
        pathAnalysisRes(kk).pathWidth  = widths(ii);
        pathAnalysisRes(kk).pathHeight = heights(jj);
        pathAnalysisRes(kk).avgSpeed = mean(solVals.vH_path);
        avgSpeed(kk) = mean(solVals.vH_path);
        % increment counter
        kk = kk+1;
        
    end
end
% legend(pRc,legs,'location','bestoutside');

%% acheivable velocity calcualtion
% find max of average speed
[~,maxIdx] = max(avgSpeed);


%% save res
[status, msg, msgID] = mkdir(pwd,'pathAnalysisOutputs');
fName = ['pathAnalysisResults_',strrep(strrep(datestr(datetime),':','-'),' ','_')...
    ,'.mat'];
fName = [pwd,'\pathAnalysisOutputs\',fName];
save(fName);

%
% solVals = cIn.getAttainableVelocityOverPath(G_vFlow,...
%     tgtPitch,pathParam);


%% plotting functions
% fIdx = fIdx+1;
% figure(fIdx);
% set(gcf,'Position',[0 0 2*560 2*420]);
% cIn.plotAeroCoefficients;

%% animation functions
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[0 0 560*2.5 420*2]);
F = cIn.makeFancyAnimation(pathParam,'animate',true,...
    'addKiteTrajectory',true,...
    'rollInRad',-pathAnalysisRes(maxIdx).rollAng,...
    'headingVel',pathAnalysisRes(maxIdx).pathSpeed,...
    'waitForButton',true);

%% % video settings
% video = VideoWriter(strcat(fName,'_video'),'Motion JPEG AVI');
% video.FrameRate = 1;
% set(gca,'nextplot','replacechildren');
%
% open(video)
% for ii = 1:length(F)
%     writeVideo(video, F(ii));
% end
% close(video)
