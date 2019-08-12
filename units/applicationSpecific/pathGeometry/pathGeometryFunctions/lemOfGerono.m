function [gndPos] = lemOfGerono(pathVar,geomParams)
%LEMOFGERONO Mercator projection of the lemniscate of Gerono onto a sphere
%   INPUTS
%   pathVar = Normalized path variabl (0-1) describing position along the
%   path
%   geomParams(1) = total azimuth sweep angle in degrees
%   geomParams(2) = total elevation sweep angle in degrees
%   geomParams(3) = mean course azimuth angle in degrees
%   geomParams(4) = mean course elevation angle in degrees
%   geomParams(5) = radius of sphere
%   OUTPUTS
%   gndPos = Nx3 matrix, where N is the number of elements of pathVar

% Calculat path position in radians
pathVar = (pathVar(:)*2*pi+3*pi/2);
% Calculate azimuth and zenith
az = (geomParams(1)/2)*cos(  pathVar(:))+geomParams(3);
zn = 90-((geomParams(2)/2)*sin(2*pathVar(:))+geomParams(4));
% Convert sphereical to cartesian
% http://mathworld.wolfram.com/SphericalCoordinates.html
gndPos = nan(numel(pathVar),3);
gndPos(:,1) = geomParams(5).*cosd(az).*sind(zn);
gndPos(:,2) = geomParams(5).*sind(az).*sind(zn);
gndPos(:,3) = geomParams(5).*cosd(zn);
end

