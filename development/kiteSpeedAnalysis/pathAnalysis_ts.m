clear
clc
% close all
fIdx = 1;

%% initailize
% path widths
widths = [40,50,60]*pi/180;
heights = [15,12.5,10]*pi/180;

% initialize class
cIn = maneuverabilityAdvanced;
cIn.tetherLength = 60;
cIn.meanElevationInRadians = 30*pi/180;

% flow vel in ground frame
G_vFlow = [1;0;0];      

% tangent pitch angle
tgtPitch = 0*pi/180;

% load vehicle
load('ayazFullScaleOneThrVhcl.mat');

% wing parameters
cIn.wingChord = 1;
cIn.wingAspectRatio = 9;
cIn.wingAeroCenter = -[0.31;0;0];

% h-stab parameters
cIn.hstabChord = 0.5;
cIn.hstabAspectRatio = 8;
cIn.hstabAeroCenter = [-5.5;0;0] + [-0.16;0;0];
cIn.hstabControlSensitivity = 0.08;
elevatorDeflection = 0;

% v-stab parameters
cIn.vstabChord = 0.5;
cIn.vstabAspectRatio = 10;
cIn.vstabAeroCenter = [-5.35;0;-0.5];

% geometry parameters
cIn.buoyFactor = 1.0;
cIn.centerOfBuoy = [-0.02;0;0];
cIn.mass = 2857;

% test tether force and moment calculation
cIn.bridleLocation = [0;0;0];

%% path param
pathParam = linspace(0,2*pi,51);

%% radius of curvature analysis
pRc = gobjects;
kk = 1;
fIdx = fIdx+1;
figure(fIdx);


for ii = 1:numel(widths)
    for jj = 1:numel(heights)
        % Path basis parameters
        [a,b] = boothParamConversion(widths(ii),heights(jj));
        cIn.aBooth = a;
        cIn.bBooth = b;
        pRc(kk) = cIn.plotPathRadiusOfCurvature;
        legs{kk} = sprintf('w = %.1f, h =%.1f',widths(ii)*180/pi,...
            heights(jj)*180/pi);
        
        solVals = cIn.getAttainableVelocityOverPath(G_vFlow,...
            tgtPitch,pathParam);
        
        pathAnalysisRes(kk).pathSpeed  = solVals.vH_path;
        pathAnalysisRes(kk).rollAng    = solVals.roll_path;
        pathAnalysisRes(kk).pathWidth  = widths(ii)*180/pi;
        pathAnalysisRes(kk).pathHeight = heights(jj)*180/pi;
        pathAnalysisRes(kk).avgSpeed = mean(solVals.vH_path);
        avgSpeed(kk) = mean(solVals.vH_path);
        % increment counter
        kk = kk+1;
        
    end
end
legend(pRc,legs,'location','bestoutside')

%% save res
[status, msg, msgID] = mkdir(pwd,'pathAnalysisOutputs');
fName = ['pathAnalysisResults ',strrep(datestr(datetime),':','.'),'.mat'];
fName = [pwd,'\pathAnalysisOutputs\',fName];

%% acheivable velocity calcualtion
% find max of average speed
[~,maxIdx] = max(avgSpeed);

% best path parameters
[aOpt,bOpt] = boothParamConversion(pathAnalysisRes(maxIdx).pathWidth*pi/180,...
    pathAnalysisRes(maxIdx).pathHeight*pi/180);

cIn.aBooth = aOpt;
cIn.bBooth = bOpt;
% 
% solVals = cIn.getAttainableVelocityOverPath(G_vFlow,...
%     tgtPitch,pathParam);


%% plotting functions
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[0 0 2*560 2*420]);
cIn.plotAeroCoefficients;

%% animation functions
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[0 0 560*2.5 420*2]);
F = cIn.makeFancyAnimation(pathParam,'animate',true,...
    'addKiteTrajectory',true,...
    'rollInRad',pathAnalysisRes(maxIdx).rollAng,...
    'headingVel',pathAnalysisRes(maxIdx).pathSpeed,...
    'waitForButton',false);

% % % video settings
video = VideoWriter(strcat(fName,'_video'),'Motion JPEG AVI');
video.FrameRate = 1;
set(gca,'nextplot','replacechildren');

open(video)
for ii = 1:length(F)
    writeVideo(video, F(ii));
end
close(video)
