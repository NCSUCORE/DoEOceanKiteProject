clear

ini_Rn_o = [0 0 100];
ini_R1_o = [0 0 0];


Rn_o = [0 0 100];
Vn_o = [0 0 0];
R1_o = [0 0 0];
V1_o = [0 0 0];

N = 2;
Ri_o =  zeros(N-2,3);

mass = 100;
dia_t = 0.01;
E = 3.8e9;
rho_fluid = 1000;
rho_tether = 1300;
Cd = 0.5;
flow = [1 0 0];

m_i = 2;

for i = 2:N-1
    Ri_o(i-1,:) = (Rn_o - R1_o)*(i-1)/(N-1);
    
end

Ri_o = [R1_o;Ri_o;Rn_o];
Vi_o = zeros(size(Ri_o));

ini_Ri_o = Ri_o;
ini_Vi_o = zeros(size(Vi_o));




