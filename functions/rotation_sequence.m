function [oCb,bCo] = rotation_sequence(euler_angles)

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