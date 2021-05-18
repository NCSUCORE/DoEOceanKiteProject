clc
clear all 
close all

%Specify system parameters
towArray = [.47 .62 .77]
thrDragCoef = 0.5:.01:2;

[towArray,thrDragCoef] = meshgrid(towArray,thrDragCoef);

lThr = 2.63-.52; %m tether arc length @ LAS
dThr = 0.0076; %m tether diameter


CdCyl = 1; %Cylinder drag coefficient
mCyl = 1.3285 ; %kg mass of cylinder
dCyl = 1.5*.0254; %m diameter of cylinder
rhoCyl = 7850; %kg/m^3 density of 304
rhoWat = 1000; %kg/m^3 density of water
lCyl = 4*mCyl/(pi*rhoCyl*dCyl^2); %cylinder length
fCyl = mCyl*9.81-1000*pi*dCyl^2/4*lCyl*9.81; %net buoyant force on cylinder
fDragCyl = 0.5*1000*towArray.^2*CdCyl*dCyl*lCyl; %cylinder drag force
T1 = sqrt(fCyl^2+fDragCyl.^2);
theta1 = atan2(fCyl,fDragCyl);
theta1deg = theta1*180/pi;

alpha = 1/2*rhoWat*towArray.^2.*thrDragCoef*dThr*lThr;
thrAngle = acot(alpha./T1+fDragCyl/fCyl);
thrAngDeg = thrAngle*180/pi;
thrTen = T1.*sin(theta1)./sin(thrAngle); 