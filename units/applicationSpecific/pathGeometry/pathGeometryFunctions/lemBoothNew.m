function [posGround,tanVec] = lemBoothNew(pathPos,geomParams,cntrPos)

%%%%
% Andrew Abney
% Method of parameterizing the lemniscate of booth based on the a specified
% path width and height in meters. Allows for a constant width and height
% as the tether spools out.
%%%%



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
% Initialize the path parameter. Allow for same path regardless of positive
% or negative. Convert s in [0 1] to s in [0 2pi]
%%%%




if theta0 < 0
    phi = 2*pi * pathPos;
else
    phi = 2*pi - (pathPos * 2*pi);
end
%%%%
% Convert path specification into the form that the lemniscate of booth can
% handle
%%%%

a = h;
b = w^2/h;

critAng = asin(sqrt(a/b));
inc = (critAng-.000001)/.25;
tanDir = 0.*phi;
pathPos = mod(pathPos,1);
for i = 1:length(pathPos)
    if pathPos(i) <= 0.5
        phi(i) = (critAng-0.000001)-inc*pathPos(i)+pi;
        tanDir(i) = -1;
    elseif pathPos(i) > 0.50
        phi(i) = inc*(pathPos(i)-.5)-critAng+0.000001;
        tanDir(i) = 1;
    end
end



%%%%
% Compute 2D Polar Radius
%%%%
r2 = b*(a-b*sin(phi).^2);
r = complex(r2).^(1/2);

%%%%
% Initilize sphere radius to size of incoming path parameters
c = radius*ones(size(phi));

%%%%
% Compute unrotated position/path
%%%%
x0 = c.*sqrt(complex((1-r2./c.^2)))
y0 = r.*cos(phi)
z0 = r.*sin(phi)

%%%%
% Define relevant rotation matrices
%%%%
ry = @(x)[cos(x) 0 sin(x);0 1 0; -sin(x) 0 cos(x)]
rz = @(x)[cos(x) -sin(x) 0; sin(x) cos(x) 0; 0 0 1]

%%%%
% Rotate into the correct position
%%%%
posGround = real(ry(theta0)*rz(phi0)*[x0;y0;z0]);

%%%%
% Compute Tangent Vector
%%%%
drdphi = -b^2.*cos(phi).*sin(phi)./sqrt(complex(b*(a-b.*sin(phi).^2)));
xPrime = b^2.*sin(phi).*cos(phi)./(c*sqrt(1-r.^2/c.^2));
yPrime = -r.*sin(phi)+cos(phi).*drdphi;
zPrime = r.*cos(phi)+sin(phi).*drdphi;
tanVec = [xPrime;yPrime;zPrime];
tanVec = ry(theta0)*rz(phi0)*(tanVec./vecnorm(tanVec,1)).*tanDir;
end

