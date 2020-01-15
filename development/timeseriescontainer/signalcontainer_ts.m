close all
clear
clc

sim('signalcontainer_th')

tsc = signalcontainer(logsout);

tsc.mat

tsc.vec1.resample(linspace(0,10));

tsc.mat
