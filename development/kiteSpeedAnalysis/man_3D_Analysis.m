clear
clc
close all

%% make instance of class to use its methods
cIn = maneuverabilityAnalysisLibrary;

cIn.aBooth = 0.8;
cIn.bBooth = 1.5;
cIn.tetherLength = 50;
cIn.meanElevationInRadians = 30*pi/180;

res = cIn.analyseFlatEarthRes([1 2]);

%% calculate max achievable radius
mass = 3e3;
CL = 0.8;
rho = 1e3;
Aref = 10;
maxTangentRollAngle = 30;

staticVal = mass/(0.5*CL*rho*Aref);
minR = staticVal/sind(maxTangentRollAngle);

subplot(3,1,3)
yline(minR,'m-','linewidth',1);