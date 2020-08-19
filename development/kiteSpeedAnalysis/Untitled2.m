clc;
clear;

%% load file
load('pathAnalysisOutputs\pathAnalysisResults_19-Aug-2020_13-03-53.mat');

% adjust buoyancy center location
% cIn.centerOfBuoy = [0.5;0;0];
% adjust bridle location
cIn.bridleLocation = [1;0;0];

% path speed and roll from speed analysis
H_vKite = pathAnalysisRes(maxIdx).pathSpeed;
H_vKite(2:3,:) = 0;
pathRoll = pathAnalysisRes(maxIdx).rollAng;

% tangent pitch sweep
tgtPitchSweep = linspace(-15,15,31)*pi/180;

% elevator deflection to be held for analysis
dElev = 0;

% tagent angle sweep
[results,inputs,tgtRange] = cIn.pathPitchStability(G_vFlow,H_vKite,pathRoll,pathParam,...
    tgtPitchSweep,dElev);

%% save res
[status, msg, msgID] = mkdir(pwd,'pitchAnalysisOutputs');
fName = ['pitchAnalysisResults_',strrep(strrep(datestr(datetime),':','-'),' ','_')...
    ,'.mat'];
fName = [pwd,'\pitchAnalysisOutputs\',fName];
save(fName);

%% animation
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[1922 42 560*2.5 420*2]);
val = cIn.pitchStabAnalysisAnim(results,inputs,...
                pathParam,'animate',false);

%%
fIdx = fIdx+1;
figure(fIdx);
set(gcf,'Position',[1922 42 560*2.5 420*2]);
F = cIn.makeFancyAnimation(pathParam,'animate',false,...
    'addKiteTrajectory',true,...
    'rollInRad',pathAnalysisRes(maxIdx).rollAng,...
    'headingVel',pathAnalysisRes(maxIdx).pathSpeed,...
    'waitForButton',true,...
    'tangentPitchRange',tgtRange);
