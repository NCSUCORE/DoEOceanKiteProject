function plotDome(radius,stepSize)
%PLOTDOME(radius,stepSize)
% Plots dome with dotted longitude and latitude lines
% Inputs:   radius - Dome radius [m]
%           stepSize - Separation between latitude and longitude lines [deg]
% Notes:
% Longitude lines are plotted between -90 and 90
% Latitude lines are plotted at 0 and 90

% parse inputs
switch nargin
    case 0
        radius = 1;
        stepSize = 15;
    case 1
        stepSize = 15;
end
% dummy variables
r = radius;
linWidth = 0.25;
lnType = ':';
grayRGB = 191/255.*[1 1 1];
% make longitude and latitude fine grids
longFine = -90:1:90;
latFine = -0:1:90;
% make longitude and latitude coarse grids
longCoarse = longFine(1):stepSize:longFine(end);
latCoarse = latFine(1):stepSize:latFine(end);
% plot longitude lines
for ii = 1:numel(longCoarse)
    X = r*cosd(longCoarse(ii)).*cosd(latFine);
    Y = r*sind(longCoarse(ii)).*cosd(latFine);
    Z = r*sind(latFine);
    plot3(X,Y,Z,lnType,'linewidth',linWidth,'color',grayRGB);
    hold on;
end
% plot latitude lines
for ii = 1:numel(latCoarse)
    X = r*cosd(longFine).*cosd(latCoarse(ii));
    Y = r*sind(longFine).*cosd(latCoarse(ii));
    Z = r*sind(latCoarse(ii))*ones(size(longFine));
    plot3(X,Y,Z,lnType,'linewidth',linWidth,'color',grayRGB);
end
% set view angle
view(110,20);
% make axes equal
axis equal;

end