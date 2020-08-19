clear
clc
% close all
fIdx = 1;

%% initailize
cIn = maneuverabilityAdvanced;
cIn.aBooth = 0.3491;
cIn.bBooth = 0.6391;
cIn.tetherLength = 60;
cIn.meanElevationInRadians = 30*pi/180;

%% define kite
% geometry
cIn.buoyFactor = 1.0;
cIn.centerOfBuoy = [1;0;0];
cIn.mass = 3e3;

% tether
cIn.bridleLocation = [0;0;8];

% wing
cIn.wingChord = 1;
cIn.wingAspectRatio = 10;
cIn.wingAeroCenter = [0.5;0;0];

% H-stab
cIn.hstabChord = 0.5;
cIn.hstabAspectRatio = 10;
cIn.hstabAeroCenter = [-6;0;0];
cIn.hstabControlSensitivity = 0.08;

% V-stab
cIn.vStabOn = false;
cIn.vstabChord = 0.5;
cIn.vstabAspectRatio = 10;
cIn.vstabAeroCenter = [-6;0;-0.5];

%% test values
% velocities
G_vFlow = [1;0;0];      % flow vel in ground frame
H_vKite = 2*G_vFlow;    % flow vel in heading frame

% pathParameter
pathParam = 0.6*2*pi;
% get azimuth,elevation, and head at path location
pathAzimElev = cIn.pathAndTangentEqs.AzimAndElev(pathParam);
pathHeading  = cIn.pathAndTangentEqs.reqHeading(pathParam);

% attitude
azimuth = pathAzimElev(1);
elevation = pathAzimElev(2);
heading = pathHeading;

% azimuth = 0*pi/180;
% elevation = 90*pi/180;
% heading = 0*pi/180;
tgtPitch = 0*pi/180;
roll = 0*pi/180;

% rotate velocity to tangent frame
T_vKite = cIn.calcKiteVelInTangentFrame(H_vKite,heading);

% tangent pitch angle sweep
tgtPitchSweep = linspace(-20,20,41)*pi/180;
elevatorDeflection = 0;

% sweep path param
sweepPathParm = linspace(0,2*pi,51);


%% tangent analysis
fIdx = fIdx + 1;
figure(fIdx);
set(gcf,'Position',[20 60 560*3 420*2]);

pTgt = cIn.plotPitchStabilityAnalysisResults(G_vFlow,T_vKite,azimuth,...
    elevation,heading,tgtPitchSweep,roll,elevatorDeflection);

set(findobj('-property','FontSize'),'FontSize',11);


%% animated plot
% keyboard
% fIdx = fIdx + 1;
% figure(fIdx);
% set(gcf,'Position',[20 60 560*3 420*2]);
% F = cIn.pitchStabAnalysisAnim(G_vFlow,H_vKite,...
%     tgtPitchSweep,elevatorDeflection,sweepPathParm);
% 
% %% video
% [status, msg, msgID] = mkdir(pwd,'outputs');
fName = [pwd,'\outputs\',strrep(datestr(datetime),':','_')];
% % % % video settings
% video = VideoWriter(strcat(fName,'_pitchAnalysis'),'Motion JPEG AVI');
% video.FrameRate = 1;
% set(gca,'nextplot','replacechildren');
% 
% open(video)
% for ii = 1:length(F)
%     writeVideo(video, F(ii));
% end
% close(video)

