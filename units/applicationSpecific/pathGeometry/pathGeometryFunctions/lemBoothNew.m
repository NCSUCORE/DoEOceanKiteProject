function [posGround,tanVec] = lemBoothNew(pathPos,geomParams,cntrPos)

%%%%
% Andrew Abney
% Method of parameterizing the lemniscate of booth based on the a specified
% path width and height in meters. Allows for a constant width and height
% as the tether spools out.
%%%%
cntrPos = reshape(cntrPos,[],1);


%%%%
% Initialize path geometry specifiations
% w = width of path in meters
% h = height of path in meters
% theta0 = center elevation angle
% phi0 = center azimuth angle
% radius = current instant sphere radius
%%%%

w =      geomParams(1);
h =      geomParams(2);
theta0 = -geomParams(3);
phi0 =   geomParams(4);
radius = geomParams(5);

%%%%
% Convert path specification into the form that the lemniscate of booth can
% handle
%%%%

a = h;
b = w^2/(4*h);

critAng = asin(sqrt(a/b))-1e-6;
tanDir = 0.*pathPos;
phi = tanDir;
if theta0>0
    for i = 1:length(pathPos)
        if pathPos(i) <= 0.5
            phi(i) = critAng*cos(2*pi*(1-pathPos(i)));
            tanDir(i) = -1;
        elseif pathPos(i) > 0.50
            phi(i) = critAng*cos(2*pi*(1-pathPos(i)))+pi;
            tanDir(i) = 1;
        end
    end
else
    for i = 1:length(pathPos)
        if pathPos(i) <= 0.5
            phi(i) = critAng*cos(2*pi*pathPos(i))+pi;
            tanDir(i) = -1;
        elseif pathPos(i) > 0.50
            phi(i) = critAng*cos(2*pi*pathPos(i));
            tanDir(i) = 1;
        end
    end
end

% if theta0 > 0
%     tanDir = tanDir*-1;
%     phi = phi(end:-1:1);
% end

%%%%
% Compute 2D Polar Radius
%%%%
r2 = b*(a-b*sin(phi).^2);
r = r2.^(1/2);

%%%%
% Initilize sphere radius to size of incoming path parameters
c = radius*ones(size(phi));

%%%%
% Compute unrotated position/path
%%%%
num = (c.^2-r.^2).^2;
x0 = (num).^(1/4);
y0 = r.*cos(phi);
z0 = r.*sin(phi);

%%%%
% Define relevant rotation matrices
%%%%
ry = @(x)[cos(x) 0 sin(x);0 1 0; -sin(x) 0 cos(x)];
rz = @(x)[cos(x) -sin(x) 0; sin(x) cos(x) 0; 0 0 1];

%%%%
% Rotate into the correct position
%%%%
posGround = ry(theta0)*rz(phi0)*[x0;y0;z0]+cntrPos;
% alt = -radius*sin(theta0)
% xShift = -radius*(1-cos(theta0))-h
% cntrPos = [xShift;0;alt];
% cntrPos = reshape(cntrPos,[],1);
% posGround = rz(phi0)*[x0;y0;z0]+cntrPos;

%%%%
% Compute Tangent Vector
%%%%
drdphi = -b^2.*cos(phi).*sin(phi)./sqrt(complex(b*(a-b.*sin(phi).^2)));
xPrime = b^2.*sin(phi).*cos(phi)./x0;
yPrime = -r.*sin(phi)+cos(phi).*drdphi;
zPrime = r.*cos(phi)+sin(phi).*drdphi;
tanVec = [xPrime;yPrime;zPrime];
tanVecMag = sqrt(sum(tanVec.^2,1));
tanVec = ry(theta0)*rz(phi0)*(tanVec./tanVecMag).*tanDir;
% tanVec = rz(phi0)*(tanVec./tanVecMag).*tanDir;
end

