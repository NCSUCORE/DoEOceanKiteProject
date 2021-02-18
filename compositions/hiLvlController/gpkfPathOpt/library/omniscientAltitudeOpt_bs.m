clear
clc
close all

HILVLCONTROLLER = 'omniscientAltitudeOpt';
PATHGEOMETRY = 'lemOfBooth';

loadComponent('ayazAirborneSynFlow');
loadComponent('gpkfAltitudeOptimization');

[synFlow,synAlt] = env.water.generateData();

simTime = 1*60*60;

initVal = 0.5*(hiLvlCtrl.minVal + hiLvlCtrl.maxVal);
initVal = [500;30;1000];

[altSPTraj,elevSPTraj,thrSPTraj] = calculateOmniAltitudeSPTraj(synAlt,synFlow,hiLvlCtrl,...
    initVal,simTime);

% hiLvlCtrl.altSPTraj = altSPTraj;
% 
% saveFile = saveBuildFile('hiLvlCtrl',mfilename,'variant','HILVLCONTROLLER');
% save(saveFile,'PATHGEOMETRY','-append')

