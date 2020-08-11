clear
clc
close all
set(groot,'defaulttextinterpreter','latex');
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');

%% test variables
radius = 100;
meanElevation = 30*pi/180;
aBooth = 0.6;
bBooth = 1.4;

% function to get lemniscate co-ordinates
[lemniscate,polarCoord] = getLemniScateCoordinates(radius,...
    meanElevation,aBooth,bBooth);

% plot
plot3(lemniscate.lemX,lemniscate.lemY,lemniscate.lemZ,'k-');
grid on; hold on;axis equal;
xlabel('X (m)');ylabel('Y (m)');zlabel('Z (m)');
view(100,35);
plotDome(radius);

function [lemniscate,polarCoord] = getLemniScateCoordinates(radius,...
    meanElevation,aBooth,bBooth)

pathParam = linspace(0,2*pi,200);

% local variables
a = aBooth;
b = bBooth;
% equations for path longitude and latitude
pathLong = (a*sin(pathParam))./...
    (1 + ((a/b)^2).*(cos(pathParam).^2));
pathLat = (((a/b)^2)*sin(pathParam).*cos(pathParam))./...
    (1 + ((a/b)^2).*(cos(pathParam).^2));
pathLat = pathLat + meanElevation;
% x,y,and z coordinates
lemniscate.lemX = radius*cos(pathLong).*cos(pathLat);
lemniscate.lemY = radius*sin(pathLong).*cos(pathLat);
lemniscate.lemZ = radius*sin(pathLat);
% polar cooridnates
polarCoord.azimuth = pathLong;
polarCoord.elevation = pathLat;

end

function plotDome(radius)
% get constants
r = radius;
lwd = 0.5;
lnType = ':';
grayRGB = 128/255.*[1 1 1];
% make longitude and latitude fine grids
longFine = -90:1:90;
latFine = -0:1:90;
stepSize = 30;
% make longitude and latitude coarse grids
longCoarse = longFine(1):stepSize:longFine(end);
latCoarse = latFine(1):stepSize:latFine(end);
% plot longitude lines
for ii = 1:numel(longCoarse)
    X = r*cosd(longCoarse(ii)).*cosd(latFine);
    Y = r*sind(longCoarse(ii)).*cosd(latFine);
    Z = r*sind(latFine);
    plot3(X,Y,Z,lnType,'linewidth',lwd,'color',grayRGB);
end
% plot latitude lines
for ii = 1:numel(latCoarse)
    X = r*cosd(longFine).*cosd(latCoarse(ii));
    Y = r*sind(longFine).*cosd(latCoarse(ii));
    Z = r*sind(latCoarse(ii))*ones(size(longFine));
    plot3(X,Y,Z,lnType,'linewidth',lwd,'color',grayRGB);
end

end