close all
clear
clc

sim('signalcontainer_th')

tsc = signalcontainer(logsout);

tsc.mat
tsc = tsc.guicrop('vec1');
tsc.mat
