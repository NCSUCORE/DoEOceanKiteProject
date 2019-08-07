close all
clear
clc

% Flight Controller
loadComponent('ayazThreeTetCtrl');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High Level Con
loadComponent('basicILC')
% Ground station
loadComponent('ayazThreeTetGndStn');
% Winches 
loadComponent('threeWnch');
% Tether
loadComponent('ayazThreeTetTethers');
% Vehicle
loadComponent('ayazThreeTetVhcl');
% Environment
loadComponent('ayazThreeTetEnv');