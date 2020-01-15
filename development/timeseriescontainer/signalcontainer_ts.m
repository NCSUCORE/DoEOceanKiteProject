close all
clear
clc

sim('signalcontainer_th')

tsc = signalcontainer(logsout);

tsc.mat.plot