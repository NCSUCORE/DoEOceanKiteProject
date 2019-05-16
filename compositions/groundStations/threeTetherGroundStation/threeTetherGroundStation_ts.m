close all;clear;clc
format compact

J = 1;
b = 1;
theta0 = 0;
omega0 = 0;

ten1 = [0 1 1];
ten2 = [0 0 1];
ten3 = [0 0 1];

thr1Attach = [2 0 0];
thr2Attach = [0 1 0];
thr3Attach = [0 -1 0];

drivingTorque = 0;

sim('threeTetherGroundStation_th')

simout.plot
