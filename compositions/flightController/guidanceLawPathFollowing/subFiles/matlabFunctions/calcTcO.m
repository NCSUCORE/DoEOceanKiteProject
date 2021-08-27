function TcO = calcTcO(azimuth,elevation)
%CALCTCO(azimuth,elevation) 
% Calculate rotation matrix to go from inertial to tangent frame
%
% Inputs:   azimuth - Azimuth angle [rad]
%           elevation - Elevation angle [rad]
%
% Output:   TcO - Matrix that'll rotate a vector in the inertial frame to
%           the tangent frame

%% local functions
Ry = @(y) [cos(y) 0 -sin(y); 0 1 0; sin(y) 0 cos(y)];
Rz = @(z) [cos(z) sin(z) 0; -sin(z) cos(z) 0; 0 0 1];

TcO = Ry(-(elevation + pi/2))*Rz(azimuth);

end

