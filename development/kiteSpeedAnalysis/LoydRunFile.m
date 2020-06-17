clear; clc; close all;
format compact;
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

%% load the file which contains all the functions
load('kiteSpeedFunctions.mat')

%% initialize some values
% gravitational acceleration
g = 9.81;
% flow speed
vf = 2;
% vehicle mass
m = 3000;
% tether length
tetLength = 100;
% fluid density
rho = 1000;
% reference area
refArea = 10;
% buoyancy factor (1 is neutrally buoyant)
BF = 1;
% lift by drag ratio
LbyD = 20;
% lift coefficient
cL = 1;
% roll angle (degrees)
rollAngle = 0;
% speed in azimuth direction (m/s)
vAzim = 0;
% speed in zenith direction
vZen = 0;
% rate of change of azimuth angle (rad/s)
d_Azimuth = vAzim/tetLength;
% rate of change of zenith angle (rad/s)
d_Zenith = vZen/tetLength;
% tether release speed (m/s)
tetReleaseSpeed = 0;


% lemniscate
aBooth = 0.4;
bBooth = 0.8;
meanElevation = 15*pi/180;


%% calculate values
% sweep of azimuth angle
numAzim = 100;
azimuthSweep = linspace(-pi/2,pi/2,numAzim);
% sweep of zenith angles
numZen = 100;
zenithSweep = linspace(0.2,pi/2,numZen);
% create grid
[A,Z] = meshgrid(azimuthSweep,zenithSweep);

% calculate cartesion positions, tether tension, and angular acceleration
xPos = NaN*A;
yPos = NaN*A;
zPos = NaN*A;
tetherForces = NaN*A;
azimuthAccelerations = NaN*A;
zentihAccelerations = NaN*A;

for ii = 1:numZen
    for jj = 1:numAzim
        posVec = OcT(A(ii,jj),Z(ii,jj))*[0;0;tetLength];
        xPos(ii,jj) = posVec(1);
        yPos(ii,jj) = posVec(2);
        zPos(ii,jj) = posVec(3);
        
        tetherForces(ii,jj) = tetForce(refArea,BF,LbyD,A(ii,jj),cL,...
            rollAngle*(pi/180),d_Azimuth,tetReleaseSpeed,d_Zenith,g,m,...
            tetLength,rho,vf,Z(ii,jj));
        azimuthAccelerations(ii,jj) = azimuthAccl(refArea,LbyD,...
            A(ii,jj),cL,rollAngle*(pi/180),d_Azimuth,tetReleaseSpeed,...
            d_Zenith,m,tetLength,rho,vf,Z(ii,jj));
        zentihAccelerations(ii,jj) = zenithAccl(refArea,BF,LbyD,A(ii,jj),...
            cL,rollAngle*(pi/180),d_Azimuth,tetReleaseSpeed,d_Zenith,g,...
            m,tetLength,rho,vf,Z(ii,jj));
        
    end
end

%% plot lemniscate of booth
pathParm = linspace(-pi,pi,500);
pathLong = (aBooth*sin(pathParm))./...
    (1 + ((aBooth/bBooth)^2).*(cos(pathParm).^2));
pathLat = (((aBooth/bBooth)^2)*sin(pathParm).*cos(pathParm))./...
    (1 + ((aBooth/bBooth)^2).*(cos(pathParm).^2));

lemX = tetLength*cos(pathLong).*cos(pathLat+meanElevation);
lemY = tetLength*sin(pathLong).*cos(pathLat+meanElevation);
lemZ = tetLength*sin(pathLat+meanElevation);


%% make surface plots
figure(1)
set(gcf,'position',[72 352 560 420])
surf(xPos,yPos,zPos,tetherForces,'EdgeColor','none');
c = colorbar;
c.Label.String = 'Tether Force (N)';
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
hold on
plot3(lemX,lemY,lemZ,'k-','linewidth',2)
axis equal
zlim([0 Inf])
view(70,30)

figure(2)
set(gcf,'position',[72 352 560 420])
surf(xPos,yPos,zPos,1*(tetLength*azimuthAccelerations),'EdgeColor','none');
c = colorbar;
c.Label.String = 'Absolute azimuth acceleration (m/s^2)';
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
hold on
plot3(lemX,lemY,lemZ,'k-','linewidth',2)
axis equal
zlim([0 Inf])
view(70,30)

figure(3)
set(gcf,'position',[72 352 560 420])
surf(xPos,yPos,zPos,-tetLength*zentihAccelerations,'EdgeColor','none');
c = colorbar;
c.Label.String = 'Elevation acceleration (m/s^2)';
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
hold on
plot3(lemX,lemY,lemZ,'k-','linewidth',2)
axis equal
zlim([0 Inf])
view(70,30)


