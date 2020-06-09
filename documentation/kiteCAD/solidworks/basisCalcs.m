clear
clc
format compact

%% sweep angle calculation
rootChord = 0.6;
aspectRatio = 7.5;
taperRatio = 0.8;

sweepAngle = atan(2*(1-taperRatio)/aspectRatio)*180/pi;

%% turbine diameter calculation
% kite reference area
sKite = 10;
% approximate kite drag coefficient
CDkite = 0.2;
% nominal turbine power coefficient
CpNom = 0.5;
% nominal turbine drag coefficient
K = 1.5;
CdNom = K*CpNom;
% turbine area if, CdNom = 0.5*CDkite
Aturb = (CDkite*sKite)/(2*CdNom);
% turbine diameter
dTurb = sqrt(4*Aturb/pi);


