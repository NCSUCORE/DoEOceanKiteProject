close all;clear;clc

d = 1;
Cp = 0.5;
Cd = 0.7;
rho = 1000;
turbPosVec = [0 1 0];


sim('turbine_th')

simout.data(end)

simout1.data(end)

simout2.data(end)

