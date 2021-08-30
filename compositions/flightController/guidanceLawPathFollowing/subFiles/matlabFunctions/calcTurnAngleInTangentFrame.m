function turnAngle = calcTurnAngleInTangentFrame(kitePos,kiteVel,targetPoint)
%CALCTURNANGLEINTANGENTFRAME(kitePos,kiteVel,targetPoint)
% 
% Inputs:   kitePos - Kite position vector in inertial frame [m]
%           kiteVel - Kite velocity vector in inertial frame [m/s]
%           targetPoint - Target point position vector in inertial frame [m]
%
% Outputs:  turnAngle - Angle the kite needs to turn in the tangent frame
%           to reach the target point [rad]

%% local functions
Rz = @(z) [cos(z) sin(z) 0; -sin(z) cos(z) 0; 0 0 1];

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
a(3) = 0; a = a./norm(a);
b(3) = 0; b = b./norm(b);
% anlge the velocity vector makes wrt to the iT axis
velAng = atan2(a(2),a(1));
% rotate velocity such that the iB axis lies along the velocity
velRotMat = Rz(velAng);
rotatedVel = velRotMat*a;

% rotate target point vector in the velocity frame as well
rotateTarg = velRotMat*b;

turnAng = calcTurnAng(rotatedVel,rotateTarg);
% turnAng = calcTurnAng(a,b);

maxTurn = 0.99*pi/2;
turnAngle = min(max(-maxTurn,turnAng),maxTurn);

function val = calcTurnAng(a,b)
val = atan2(a(1)*b(2) - a(2)*b(1),a(1)*b(1) + a(2)*b(2));
end

end

