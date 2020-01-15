close all
clear
clc

sim('signalcontainer_th')

tsc = signalcontainer(logsout);


% Crop a single signal

tsc.vec1 = tsc.vec1.crop([0 7]);
tsc.vec1.plot

% Crop the entire timeseries
tsc = tsc.crop([0 5]);
figure
tsc.mat.plot