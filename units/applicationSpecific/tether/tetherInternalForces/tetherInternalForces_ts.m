clear

Rn_o = [0 0 100];
Vn_o = [0 0 0];
R1_o = [0 0 0];
V1_o = [0 0 0];

N = 2;
Ri_o =  zeros(N-2,3);

mass = 100;
E = 3.8e9;
L = 90;
zeta = 0.05;
dia_t = 0.01;


for i = 2:N-1
    Ri_o(i-1,:) = (Rn_o - R1_o)*(i-1)/(N-1);
    
end

Ri_o = [R1_o;Ri_o;Rn_o];
Vi_o = zeros(size(Ri_o));
