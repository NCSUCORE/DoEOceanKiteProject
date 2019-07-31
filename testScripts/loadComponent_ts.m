
%% This should throw an error (non-unique file name)
clear
loadComponent('oneThr.mat')

%% This should load properly, creating thr in workspace
clear;clc
loadComponent('threeThr.mat')

%% This should load properly, creating thr2 in workspace
clear;clc
thr2 = loadComponent('threeThr.mat');

%% This should load properly, with a warning that it's ignoring output x
clear;clc
[thr2,x] = loadComponent('threeThr.mat');

%% This should load properly, with a warning that it's ignoring output x
clear;clc
[thr2,x] = loadComponent('oneThr.mat','plants','components','tethers','tether000');

%% This should load properly, creating thr2 in workspace
clear;clc
thr2 = loadComponent('oneThr.mat','plants','components','tethers','tether000');

%% This should load properly, creating thr in workspace
clear;clc
loadComponent('oneThr.mat','plants','components','tethers','tether000');
