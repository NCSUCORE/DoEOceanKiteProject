close all
clear
clc

position = [1 0 0];

spinEnable = 1;

ten1 = 1000*[-1 0 0];
ten2 = 1000*[0 0 1];
ten3 = 1000*[0 0 1];

J = 1000;
b = 2000;

thr1Attach = [0 1 0];
thr2Attach = [1 0 0];
thr3Attach = [0 -1 0];

initPos = 0*pi/180;
initVel = 0;


sim('threeTetherGroundStation_th')

tsc = parseLogsout;

tsc.platformAngle.plot
thr1Pos.plot