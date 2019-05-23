close all
clear
clc

time = 0:0.1:10;
simin = -100*ones(size(time));
simin(time<5) = 0;
simin = timeseries(simin,time);

maxSpeed = 0.5;
maxAccl  = 1;
initLength = 5;

ayazPlant_init;

sim('winch_th')

simout.plot