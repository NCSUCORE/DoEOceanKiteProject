function val = calculatePathLength(aBooth,bBooth,meanElevation,...
    thrLength,pathParamRange)
if nargin == 4
    pathParamRange = [0 2*pi];
end

% symbolic
syms s
pathParm = 2*pi-s;
a = aBooth;
b = bBooth;
el = meanElevation;
r = thrLength;
% logitutude equation
pathLong = (a*sin(pathParm))./...
    (1 + ((a/b)^2).*(cos(pathParm).^2));
% latitude equation equation
pathLat = (((a/b)^2)*sin(pathParm).*cos(pathParm))./...
    (1 + ((a/b)^2).*(cos(pathParm).^2));
pathLat = pathLat + el;
% get lemniscate coordinates
lemX = r*cos(pathLong).*cos(pathLat);
lemY = r*sin(pathLong).*cos(pathLat);
lemZ = r*sin(pathLat);
% first derivative
dx = diff(lemX,s);
dy = diff(lemY,s);
dz = diff(lemZ,s);
% path length calculation
pathLengthEq = (dx^2 + dy^2 + dz^2)^0.5;
% radius of curvature = 1/curvate
pLengthEq = matlabFunction(pathLengthEq);
% calculate path length
val = integral(pLengthEq,pathParamRange(1),...
    pathParamRange(2));

end