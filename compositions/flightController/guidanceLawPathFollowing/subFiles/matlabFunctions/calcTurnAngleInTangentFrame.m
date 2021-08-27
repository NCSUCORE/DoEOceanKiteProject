function turnAngle = calcTurnAngleInTangentFrame(kitePos,kiteVel,targetPoint)
%CALCTURNANGLEINTANGENTFRAME(kitePos,kiteVel,targetPoint)
% 
% Inputs:   kitePos - Kite position vector in inertial frame [m]
%           kiteVel - Kite velocity vector in inertial frame [m/s]
%           targetPoint - Target point position vector in inertial frame [m]
%
% Outputs:  turnAngle - Angle the kite needs to turn in the tangent frame
%           to reach the target point [rad]

%% normalize all vectors
kitePos = kitePos./norm(kitePos);
kiteVel = kiteVel./norm(kiteVel);
targetPoint = targetPoint./norm(targetPoint);

%% vector from kite position to target point
rTarg_kite = targetPoint - kitePos;
rTarg_kite = rTarg_kite./norm(rTarg_kite);

%% calc kite azimuth and elevation
[azimuth,elevation] = calcKiteAzimuthAndElevation(kitePos);
% make TcO rotation matrix
TcO = calcTcO(azimuth,elevation);

% calculate slip angle
a = TcO*kiteVel;
b = TcO*rTarg_kite;
turnAngle = atan2(a(1)*b(2) - a(2)*b(1),a(1)*b(1) + a(2)*b(2));

end

