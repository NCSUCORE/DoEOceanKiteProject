function [gndPos,tanVec] = lemOfGerono(pathVar,geomParams)
%LEMOFGERONO Mercator projection of the lemniscate of Gerono onto a sphere
%   INPUTS
%   pathVar = Normalized path variabl (0-1) describing position along the
%   path
%   geomParams(1) = A0, total azimuth sweep angle in degrees
%   geomParams(2) = Z0, total elevation sweep angle in degrees
%   geomParams(3) = A1, mean course azimuth angle in degrees
%   geomParams(4) = Z1, mean course elevation angle in degrees
%   geomParams(5) = R, radius of sphere
%   OUTPUTS
%   gndPos = Nx3 matrix, where N is the number of elements of pathVar
%   Variable names here were chosen to match the notebook
%   lemOfGeronoTanVec.nb

A0 = geomParams(1);
Z0 = geomParams(2);
A1 = geomParams(3);
Z1 = geomParams(4);
R  = geomParams(5);

% Calculate path position in rad, phi from the normalized path variable, s.
phi = (pathVar(:)*2*pi+3*pi/2);

% Calculate azimuth and zenith in degrees
a =     (A0/2)*cos(  phi(:)) + A1;
z = 90-((Z0/2)*sin(2*phi(:)) + Z1);

% Convert sphereical to cartesian
% http://mathworld.wolfram.com/SphericalCoordinates.html
gndPos = nan(numel(phi),3);
tanVec = gndPos;

gndPos(:,1) = R.*cosd(a).*sind(z);
gndPos(:,2) = R.*sind(a).*sind(z);
gndPos(:,3) = R.*cosd(z);

tanVec(:,1) = pi*R*(-cos(2*pi*s)*cos((Z0/2)*sin(4*pi*s)-Z1)*sin((A0/2)*sin(2*pi*s)-A1)+2*cos((3+4*s)*cos((Z0/2)*sin(4*pi*s)-Z1)*sin((A0/2)*sin(2*pi*s)-A1));
tanVec(:,2) = ;
tanVec(:,3) = ;
end

