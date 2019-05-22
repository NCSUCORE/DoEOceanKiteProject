close all
clear
clc

ten1 = 1000*[-1 0 0];
ten2 = 1000*[0 -1 0];
ten3 = 1000*[0 0 1];

J = 1000;
b = 2000;

thr1Attach = [0 1 0];
thr2Attach = [1 0 0];
thr3Attach = [0 -1 0];

initPos = 0;
initVel = 0;


sim('threeTetherGroundStation_th')

tsc = parseLogsout;
tsc.platformAngle.plot