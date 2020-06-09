close all
clear
clc

% Load the high level controller
loadComponent('basicILC')
% Create the bus for the plant
plant_bc
% Create the bus for the environmane
constantUniformFlow_bc
% Create the bus for the flight controller
pathFollowingController_bc
% Create the ground station controller bus
oneDoF_bc

% Simulation duration
duration_s = 100;
% Duration of each iteration
iterationDuration = 1;

iterationIndices = 1:duration_s/iterationDuration;


coeffs = [1 0 -1 0 -1];

hiLvlCtrl.filtTimeConst.setValue(0.001,'s');
hiLvlCtrl.initBasisParams.setValue([-10 -10],'[deg deg]');
hiLvlCtrl.numInitLaps.setValue(1,'');
hiLvlCtrl.pathVarLowerLim.setValue(0.01,'');
hiLvlCtrl.pathVarUpperLim.setValue(0.05,'');
hiLvlCtrl.excitationAmp.setValue([0 0],'[deg deg]');
hiLvlCtrl.learningGain.setValue(1,'');
hiLvlCtrl.forgettingFactor.setValue(0.99,'');
hiLvlCtrl.distPenaltyWght.setValue(0,'W/deg');
hiLvlCtrl.trustRegion.setValue(0.5*[1 1],'[deg deg]');


sim('ilcPathOpt_th')

parseLogsout
%%
subplot(4,1,1)
tsc.pathVar.plot('DisplayName','Path Var.')
grid on
hold on
tsc.ilcTrigger.plot('DisplayName','ILC Updt. Trigger');
legend

subplot(4,1,2)
tsc.perfIndx.plot('DisplayName','Perf. Idx')
grid on
legend

subplot(4,1,3)
tsc.basisParams.plot('DisplayName','Basis Params')
grid on
legend

subplot(4,1,4)
tsc.estGradient.plot('DisplayName','Est. Gradient')
grid on
legend

set(gcf,'Position',[-0.5625   -0.1824    0.5625    1.6694])
linkaxes(findall(gcf,'Type','axes'),'x');
set(findall(gcf,'Type','axes'),'FontSize',16);
