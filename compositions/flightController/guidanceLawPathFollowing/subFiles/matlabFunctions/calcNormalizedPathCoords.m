function val = calcNormalizedPathCoords(pathParameter,...
    pathWidth,pathHeight,pathElevation)
%CALCNORMALIZEDPATHCOORDS(pathWidth,pathHeight,pathElevation,pathParameter)
% Calculate inerital path co-ordinates
% Inputs:   pathWidth - Path width [deg]
%           pathHeight - Path height [deg]
%           pathElevation - Path elevation [deg]
%           pathParameter - Path parameter,s where 0 < s < 2*pi for 1 lap
% Output:   Path co-ordinates in inertial frame - x, y, and z such that
% sqrt(x^2 + y^2 + z^2) = 1

%% dummy variables with shorter names
w = pathWidth*pi/180;
h = pathHeight*pi/180;
e = pathElevation*pi/180;
s = pathParameter;

%% path shape parameters a and b
a = 0.5*w;
b = (1/(2*sqrt(2)))*sqrt(-w^2+sqrt((h^2*(4+h^2)*w^4))/(h^2));

% equation for path azimuth
AZ = -(a*sin(s))./(1 + (((a/b)^2)*cos(s).^2));
% equation for path elevation
EL = e - (((a/b)^2)*sin(s).*cos(s))./(1 + (((a/b)^2)*cos(s).^2));

% equation for normalized path position
val = [cos(AZ).*cos(EL); sin(AZ).*cos(EL); sin(EL)];


end

