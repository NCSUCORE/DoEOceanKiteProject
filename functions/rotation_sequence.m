function [oCb,bCo] = rotation_sequence(euler_angles)
% ROTATION_SEQUENCE creates the rotation matrices associated with the set
% of Euler angles in the input.  The input is assumed to be a three element
% vector where the first element represents the roll angle, in radians, the
% second element represents the pitch angle, in radians, and the third
% element represents the yaw angle, in radians.
%
%   [oCb,bCo] = ROTATION_SEQUENCE(euler_angles) returns two 3x3 rotation
%   matrices, oCb and bCo.
%
%   Output rotation matrices can be used to rotate a vector represented in
%   the o frame into the b frame, or vice versa.  For a vector, v,
%   represented in the b frame, oCb*v returns the vector represented in the o
%   frame.  For a vector v represented in the o frame, bCo*v returns the
%   vector represented in the b frame.  It is assumed that the b frame is
%   created from the o frame by the following sequence of rotations:
%   1) rotation by euler_angles(3) about z
%   2) rotation by euler_angles(2) about the new y
%   3) rotation by euler_angler(1) about the new z.

% Assign variable names
ph = euler_angles(1);
th = euler_angles(2);
ps = euler_angles(3);

% rotation about X
Rx = [1 0 0; 0 cos(ph) sin(ph); 0 -sin(ph) cos(ph)];

% rotation about Y
Ry = [cos(th) 0 -sin(th); 0 1 0; sin(th) 0 cos(th)];

% rotation about Z
Rz = [cos(ps) sin(ps) 0; -sin(ps) cos(ps) 0; 0 0 1];

bCo = Rx*Ry*Rz;
oCb = transpose(bCo);

end