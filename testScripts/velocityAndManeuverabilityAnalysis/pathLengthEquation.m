function val = pathLengthEquation()
% symbolic
syms pathParm a b r el
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
dx = diff(lemX,pathParm);
dy = diff(lemY,pathParm);
dz = diff(lemZ,pathParm);
% path length calculation
pathLengthEq = (dx^2 + dy^2 + dz^2)^0.5;
% radius of curvature = 1/curvate
val = matlabFunction(pathLengthEq);
end