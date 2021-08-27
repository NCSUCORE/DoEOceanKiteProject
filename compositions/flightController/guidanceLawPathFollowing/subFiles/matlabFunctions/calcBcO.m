function val = calcBcO(Euler)
%CALCBCO Summary of this function goes here
%   Detailed explanation goes here

Rx = @(x) [1 0 0; 0 cos(x) sin(x); 0 -sin(x) cos(x)];
Ry = @(y) [cos(y) 0 -sin(y); 0 1 0; sin(y) 0 cos(y)];
Rz = @(z) [cos(z) sin(z) 0; -sin(z) cos(z) 0; 0 0 1];

val = Rx(Euler(1))*Ry(Euler(2))*Rz(Euler(3));

end

