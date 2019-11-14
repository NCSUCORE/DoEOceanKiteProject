close all
clear
clc
x = ENV.CNAPS('StartTime',8.6857e+05,'EndTime',8.6857e+05+3600*3+1);
% x.cropGUI
x.setXGridPoints(0:2,'m');
x.setYGridPoints(0:1:5,'m');

y = ENV.FAUTurb;
y.setIntensity(0.1,'');
y.setMinFreqHz(0.1,'Hz');
y.setMaxFreqHz(10,'Hz');
y.setNumMidFreqs(5,'');
y.setLateralStDevRatio(0.1,'');
y.setVerticalStDevRatio(0.01,'');
y.setSpatialCorrFactor(5,'');
y.process(x,'Verbose',true);

