clear; clc;
format compact;
set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%% initialize some values
% lift by drag ratio
LbyD = 10;
% flow speed
vf = 2;
% azimuth
phi = 30*pi/180;
% zenith
theta = 90*pi/180;
% tether length
tetLength = 100;
% lemniscate of booth path height
aBooth = 0.4;
% lemniscate of booth path width
bBooth = 0.8;
% lemniscate of booth mean elevation angle
meanElevation = 15*pi/180;

%% run function
[vkx,vky] = calcMaxSpeed3D(vf,phi,theta,LbyD);

%% calculate values
% sweep of azimuth angle
numAzim = 100;
azimuthSweep = linspace(0,pi/2,numAzim);
% sweep of zenith angles
numZen = 100;
zenithSweep = linspace(0.2,pi/2,numZen);
% create grid
[A,Z] = meshgrid(azimuthSweep,zenithSweep);

% calculate cartesion positions, tether tension, and angular acceleration
xPos = NaN*A;
yPos = NaN*A;
zPos = NaN*A;
azimuthSpeed = NaN*A;
ElevationSpeed = NaN*A;
maxTotalSpeed = NaN*A;;

for ii = 1:numZen
    for jj = 1:numAzim
        posVec = transpose(TcO(A(ii,jj),Z(ii,jj)))*[0;0;tetLength];
        xPos(ii,jj) = posVec(1);
        yPos(ii,jj) = posVec(2);
        zPos(ii,jj) = posVec(3);
        
        [azimuthSpeed(ii,jj),ElevationSpeed(ii,jj)] = ...
            calcMaxSpeed3D(vf,A(ii,jj),Z(ii,jj),LbyD);
        
        maxTotalSpeed(ii,jj) = sqrt(azimuthSpeed(ii,jj)^2 + ...
            ElevationSpeed(ii,jj)^2);
        
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
surf(xPos,yPos,zPos,azimuthSpeed./vf,'EdgeColor','none');
c = colorbar;
c.Label.String = 'azimuth speed (v_{kx}/v_{f})';
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
hold on
plot3(lemX,lemY,lemZ,'k-','linewidth',2)
axis equal
zlim([0 Inf])
view(115,30)

figure(2)
set(gcf,'position',[72 352 560 420])
surf(xPos,yPos,zPos,ElevationSpeed./vf,'EdgeColor','none');
c = colorbar;
c.Label.String = 'Elevation speed (v_{ky}/v_{f})';
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
hold on
plot3(lemX,lemY,lemZ,'k-','linewidth',2)
axis equal
zlim([0 Inf])
view(115,30)

figure(3)
set(gcf,'position',[72 352 560 420])
surf(xPos,yPos,zPos,maxTotalSpeed./vf,'EdgeColor','none');
c = colorbar;
c.Label.String = 'Total speed (||v_{k}||/v_{f})';
xlabel('X (m)')
ylabel('Y (m)')
zlabel('Z (m)')
hold on
plot3(lemX,lemY,lemZ,'k-','linewidth',2)
axis equal
zlim([0 Inf])
view(115,30)

% rotate vector from inertial to spherical frame
function val = TcO(azimuth,zenith)

Ry = [cos(zenith) 0 -sin(zenith); 0 1 0; sin(zenith) 0 cos(zenith)];
Rz = [cos(azimuth) sin(azimuth) 0; -sin(azimuth) cos(azimuth) 0; 0 0 1];

val = Ry*Rz;

end


function [vkx,vky] = calcMaxSpeed3D(flowSpeed,azimuth,zenith,liftByDrag)

% function for rotation about y axis
Ry = @(x) [cos(x) 0 -sin(x); 0 1 0; sin(x) 0 cos(x)];

% rotation for rotation about z axis
Rz = @(x) [cos(x) sin(x) 0; -sin(x) cos(x) 0; 0 0 1];

% angle between L and tension vector
gamma = atan(1/liftByDrag);

% assume kite is flying in the azimuth and elevation direction
% at a time in the T frame
vkAzim_T = [0;1;0];
vkElev_T = [-1;0;0];

% rotation from tangent frame to inertial frame
TcO = Ry(zenith)*Rz(azimuth);
OcT = transpose(TcO);

% rotation vkAzim_T and vkElev_T to the inertia frame
vkAzim_O = OcT*vkAzim_T;
vkElev_O = OcT*vkElev_T;

% calculate angle between flow vector, and vkAzim_O and vkElev_O
angVfVkx = acos(dot([1;0;0],vkAzim_O));
angVfVky = acos(dot([1;0;0],vkElev_O));

% calculate value of vkx
vkx = flowSpeed*((sin(pi-gamma-angVfVkx))/(sin(gamma)));
vky = flowSpeed*((sin(pi-gamma-angVfVky))/(sin(gamma)));

end


