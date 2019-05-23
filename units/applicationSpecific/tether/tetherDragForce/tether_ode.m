function D = tether_ode(Ri_o,Vi_o,sum_forces,node_mass)


sz = size(sum_forces);

N = sz(1);

if N>2
D = NaN(6*(N-2),1);



    

