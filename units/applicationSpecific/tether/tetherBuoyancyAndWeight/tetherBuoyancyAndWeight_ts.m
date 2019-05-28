clear


N = 4;

rho_fluid = 1000;
rho_tether = 900;

dia_t = 0.1;
g = 9.81;
L = 100;

vol = L*(pi/4)*dia_t^2;

W = vol*rho_tether;

sim('tetherBuoyancyAndWeight_th')
