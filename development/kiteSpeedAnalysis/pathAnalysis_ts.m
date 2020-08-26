clear
clc
% close all
fIdx = 1;

%% initailize
% path widths
widths = [40,50,60];
heights = [15,12.5,10];

widths = 40;
heights = 10;

% initialize class
cIn = maneuverabilityAdvanced;
cIn.fluidCoeffCalcMethod = 'fromTable';
cIn.tetherLength = 60;
cIn.meanElevationInRadians = 30*pi/180;

% flow vel in ground frame
G_vFlow = [1;0;0];      

% tangent pitch angle
tgtPitch = 7*pi/180;

% load vehicle
load('ayazFullScaleOneThrVhcl.mat');

% chnages is cordinate system
BcB = [cosd(180) 0 -sind(180);0 1 0;sind(180) 0 cosd(180)];

% wing parameters
cIn.wingChord = vhcl.wingRootChord.Value;
cIn.wingAspectRatio = vhcl.wingAR.Value;
cIn.wingArea = vhcl.fluidRefArea.Value;
cIn.wingAeroCenter = BcB*vhcl.stbdWing.rAeroCent_SurfLE.Value.*[1;0;1];
cIn.wingZerAoADrag = 2*vhcl.portWing.CD.Value(vhcl.portWing.alpha.Value == 0);
cIn.wingZeroAoALift = 2*vhcl.portWing.CL.Value(vhcl.portWing.alpha.Value == 0);
cIn.wingCL_Data = 2*vhcl.portWing.CL.Value;
cIn.wingCD_Data = 2*vhcl.portWing.CD.Value;
cIn.wingAoA_Data = vhcl.portWing.alpha.Value;


cIn.wingOswaldEff = 0.3;

% h-stab parameters
cIn.hstabChord = vhcl.hStab.rootChord.Value;
cIn.hstabAspectRatio = vhcl.hStab.AR.Value;
cIn.hstabArea = vhcl.hStab.planformArea.Value;
cIn.hstabAeroCenter = BcB*(vhcl.hStab.rSurfLE_WingLEBdy.Value + ...
    vhcl.hStab.rAeroCent_SurfLE.Value);
cIn.hstabControlSensitivity = vhcl.hStab.gainCL.Value(2);
cIn.hstabZeroAoALift = vhcl.hStab.CL.Value(vhcl.hStab.alpha.Value == 0)*...
    vhcl.fluidRefArea.Value/vhcl.hStab.planformArea.Value;
cIn.hstabZerAoADrag = vhcl.hStab.CD.Value(vhcl.hStab.alpha.Value == 0)*...
    vhcl.fluidRefArea.Value/vhcl.hStab.planformArea.Value;
cIn.hstabControlSensitivity = vhcl.hStab.gainCL.Value(2)*...
    vhcl.fluidRefArea.Value/vhcl.hStab.planformArea.Value;
cIn.hstabCL_Data = vhcl.hStab.CL.Value;
cIn.hstabCD_Data = vhcl.hStab.CD.Value;
cIn.hstabAoA_Data = vhcl.hStab.alpha.Value;


cIn.hstabOswaldEff = 0.6;
elevatorDeflection = 0;
cIn.hstabZerAoADrag = 0.1*cIn.hstabZerAoADrag;

% v-stab parameters
cIn.vstabChord = vhcl.vStab.rootChord.Value;
cIn.vstabAspectRatio = 2*vhcl.vStab.AR.Value;
cIn.vstabArea = vhcl.vStab.planformArea.Value;
cIn.vstabAeroCenter = BcB*(vhcl.vStab.rSurfLE_WingLEBdy.Value + ...
    [vhcl.vStab.rAeroCent_SurfLE.Value(1);0;vhcl.vStab.rAeroCent_SurfLE.Value(2)]);
cIn.vstabZeroAoALift = vhcl.vStab.CL.Value(vhcl.vStab.alpha.Value == 0)*...
    vhcl.fluidRefArea.Value/vhcl.vStab.planformArea.Value;
cIn.vstabZerAoADrag = vhcl.vStab.CD.Value(vhcl.vStab.alpha.Value == 0)*...
    vhcl.fluidRefArea.Value/vhcl.vStab.planformArea.Value;
cIn.vstabCL_Data = vhcl.vStab.CL.Value;
cIn.vstabCD_Data = vhcl.vStab.CD.Value;
cIn.vstabAoA_Data = vhcl.vStab.alpha.Value;

cIn.vstabOswaldEff = 0.3;

% geometry parameters
cIn.buoyFactor = vhcl.buoyFactor.Value;
cIn.centerOfBuoy = BcB*vhcl.rCentOfBuoy_LE.Value;
cIn.mass = vhcl.mass.Value;

% test tether force and moment calculation
cIn.bridleLocation = BcB*vhcl.rBridle_LE.Value;

%% path param
pathParam = linspace(0,2*pi,11);

%% radius of curvature analysis
% pRc = gobjects;
% fIdx = fIdx+1;
% figure(fIdx);
kk = 1;


for ii = 1:numel(widths)
    for jj = 1:numel(heights)
        % Path basis parameters
        cIn.pathWidth = widths(ii);
        cIn.pathHeight = heights(jj);
%         pRc(kk) = cIn.plotPathRadiusOfCurvature;
        legs{kk} = sprintf('w = %.1f, h =%.1f',widths(ii),...
            heights(jj));
        
        solVals = cIn.getAttainableVelocityOverPath(G_vFlow,...
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
