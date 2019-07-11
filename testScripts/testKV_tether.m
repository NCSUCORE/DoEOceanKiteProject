clear
format compact

mass = 100;
tdamp = 0.05;
tet_dia = 0.01;
tet_youngs = 3.8e9;

tf = 10;
tVec = 0:1:tf;

y_cm = 10*sin(tVec);

Rn_o = [0;10;100];
R1_o = [0;0;0];
N = 5;

Ri_o = [linspace(R1_o(1),Rn_o(1),N);...
    linspace(R1_o(2),Rn_o(2),N);...
    linspace(R1_o(3),Rn_o(3),N)];

Vi_o = zeros(size(Ri_o));

ul = 90;

% sim('KV_testModel')