function [azimuth,elevation] = calcKiteAzimuthAndElevation(kitePos)
%CALCKITEAZIMUTHANDELEVATION(kitePos) Calculate kite azimuth and elevation
% 
%   Input:      kitePos - Kite position vector in inertial frame [m]
%
%   Outputs:    azimuth - Azimuth angle [rad]
%               elevation - Elevation angle [rad]

% normalize
kitePos = kitePos./norm(kitePos);
% calculate azimuth
azimuth = atan(kitePos(2)/kitePos(1));
% calculate elevation
elevation = asin(kitePos(3));

end

