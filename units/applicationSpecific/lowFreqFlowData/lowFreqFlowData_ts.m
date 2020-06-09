close all;clear;clc

testPosVec = 3*[1 1 1];

flw.xGridPoints.Value = [0 1 2];
flw.yGridPoints.Value = [0 1 2];
flw.zGridPoints.Value = [0 1 2];

flw.flowVecTimeseries.Value = timeseries(ones(3,3,3,3,1),0);


sim('lowFreqFlowData_th')

simout.Data

