function val = pathCoordEqn(pathWidth,pathHeight,pathElev,thrLength)
%PATHCOORDEQN Summary of this function goes here
%   Detailed explanation goes here

switch nargin
    case 3
        thrLength = 1;
        pathParam = linspace(0,2*pi,201);
    case 4
        pathParam = linspace(0,2*pi,201);
end

w = pathWidth*pi/180;
h = pathHeight*pi/180;
% path parameters
aBooth = 0.5*w;
bBooth = (1/(2*sqrt(2)))*sqrt(-w^2+sqrt((h^2*(4+h^2)*w^4))/(h^2));
meanElevation = pathElev*pi/180;

% output
val = [thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*cos((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0));-thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*sin((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0));thrLength.*sin(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0))];

end

