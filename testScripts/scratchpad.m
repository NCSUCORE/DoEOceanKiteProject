clear;clc;close all
data = rand(3,3,2)+i.*rand(3,3,2);
time = [0 1];
ts = timeseries(data,time);

sim('untitled')

ts.Data == simout.Data