clear
clc
format compact

%% sweep angle calculation
rootChord = 0.6;
aspectRatio = 7.5;
taperRatio = 0.8;

sweepAngle = atan(2*(1-taperRatio)/aspectRatio)*180/pi;
