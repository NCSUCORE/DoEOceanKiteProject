clc;

%% load file
load('pathAnalysisOutputs\pathAnalysisResults 17-Aug-2020 18.02.09.mat');

% adjust buoyancy center location
cIn.centerOfBuoy = [0.5;0;0];
% adjust bridle location
cIn.bridleLocation = [1;0;0];

% path speed and roll from speed analysis
H_vKite = pathAnalysisRes(maxIdx).pathSpeed;
H_vKite(2:3,:) = 0;
pathRoll = pathAnalysisRes(maxIdx).rollAng;

% tangent pitch sweep
tgtPitchSweep = linspace(-20,20,41)*pi/180;

% elevator deflection to be held for analysis
dElev = 0;

% tagent angle sweep
[results,inputs,tgtRange] = cIn.pathPitchStability(G_vFlow,H_vKite,pathRoll,pathParam,...
    tgtPitchSweep,dElev);

% 
cIn.plotPitchStabilityAnalysisResults(results(1),inputs(1));

%% animation
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[1922 42 560*2.5 420*2]);
val = cIn.pitchStabAnalysisAnim(results,inputs,...
                pathParam);

%%

% fIdx = fIdx+1;
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[1922 42 560*2.5 420*2]);
F = cIn.makeFancyAnimation(pathParam,'animate',false,...
    'addKiteTrajectory',true,...
    'rollInRad',pathAnalysisRes(maxIdx).rollAng,...
    'headingVel',pathAnalysisRes(maxIdx).pathSpeed,...
    'waitForButton',true,...
    'tangentPitchRange',tgtRange);
