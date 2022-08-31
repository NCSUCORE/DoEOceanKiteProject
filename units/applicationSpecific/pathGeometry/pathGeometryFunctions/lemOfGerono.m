function [gndPos,tanVec] = lemOfGerono(pathVar,geomParams,cntrPos)
%LEMOFGERONO Mercator projection of the lemniscate of Gerono onto a sphere
%   INPUTS
%   pathVar = Normalized path variabl (0-1) describing position along the
%   path
%   geomParams(1) = A0, total azimuth sweep angle in degrees
%   geomParams(2) = Z0, total elevation sweep angle in degrees
%   geomParams(3) = A1, mean course elevaiton angle in degrees
%   geomParams(4) = Z1, mean course azimuth angle in degrees
%   geomParams(5) = R, radius of sphere
%   OUTPUTS
%   gndPos = Nx3 matrix, where N is the number of elements of pathVar
%   Variable names here were chosen to match the notebook
%   lemOfGeronoTanVec.nb

cntrPos = reshape(cntrPos,[],1);
pathVar = reshape(pathVar,1,[]);

W  = geomParams(1);
H  = geomParams(2);
Z1 = -geomParams(3);
A1 = geomParams(4);
R  = geomParams(5);

A0 = 2*asin(W/(2*R));
Z0 = 2*asin(H/(2*R));
% Calculate path position in rad, phi from the normalized path variable, s.
phi = ((pathVar*2+3/2)*pi);

% Calculate azimuth and zenith in degrees
a =         (A0/2)*cos(  phi);% + A1;
z = (pi/2)- (Z0/2)*sin(2*phi);% + Z1);

% Convert sphereical to cartesian
% http://mathworld.wolfram.com/SphericalCoordinates.html
% gndPos = nan(3,numel(phi));
% tanVec = gndPos;

x0 = R.*cos(a).*sin(z);
y0 = R.*sin(a).*sin(z);
z0 = R.*cos(z);
% gndPos = gndPos';

%%%%
% Define relevant rotation matrices
%%%%
ry = @(x)[cos(x) 0 sin(x);0 1 0; -sin(x) 0 cos(x)];
rz = @(x)[cos(x) -sin(x) 0; sin(x) cos(x) 0; 0 0 1];

%%%%
% Rotate into the correct position
%%%%
rotMat = rz(A1)*ry(Z1);
gndPos = rotMat*[x0;y0;z0]+cntrPos;


%     tanVec(:,1) = pi.*R.*(...
%         -cos(2.*pi.*pathVar(:))...
%         .*cos((1/2).*sin(4.*pi.*pathVar(:)).*Z0-Z1)...
%         .*sin((1/2).*sin(2.*pi.*pathVar(:)).*A0+A1).*A0...
%         +...
%         2.*cos(pi.*(3+4.*pathVar(:)))...
%         .*cos((1/2).*sin(2.*pi.*pathVar(:)).*A0+A1)...
%         .*sin((1/2).*sin(4.*pi.*pathVar(:)).*Z0-Z1).*Z0);
%     
%     tanVec(:,2) = pi.*R.*(...
%         cos(2.*pi.*pathVar(:))...
%         .*cos((1/2).*sin(2.*pi.*pathVar(:)).*A0+A1)...
%         .*cos((1/2).*sin(4.*pi.*pathVar(:)).*Z0-Z1).*A0...
%         +...
%         2.*cos(pi.*(3+4.*pathVar(:)))...
%         .*sin((1/2).*sin(2.*pi.*pathVar(:)).*A0+A1)...
%         .*sin((1/2).*sin(4.*pi.*pathVar(:)).*Z0-Z1).*Z0);
%     
%     tanVec(:,3) = 2.*pi.*R.*cos(pi.*(3+4.*pathVar(:))).*cos((1/2).*sin(4.*pi.*pathVar(:)).*Z0-Z1).*Z0;
%     
%     tanVec = tanVec./repmat(sqrt(sum(tanVec.^2,2)),[1 3]);
    dadphi = -A0/2*sin(phi);
    dzdphi = -Z0*cos(2*phi);
    xPrime = R*(cos(a).*cos(z).*dzdphi-sin(a).*sin(z).*dadphi);
    yPrime = R*(cos(a).*sin(z).*dadphi+sin(a).*cos(z).*dzdphi);
    zPrime = -R*sin(z).*dzdphi;

    tanVec = [xPrime;yPrime;zPrime];
    tanVecMag = sqrt(sum(tanVec.^2,1));
    tanVec = rotMat*(tanVec./tanVecMag);

end

