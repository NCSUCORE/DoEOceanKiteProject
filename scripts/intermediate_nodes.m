function node_locations = intermediate_nodes(R21_g,tether2n_pos,N,X0_partial)

ini_Rcm_o = X0_partial(1:3,1);
ini_euler = X0_partial(7:9,1);
gnd_station = X0_partial(15:17,1);
ini_platform_ang = X0_partial(13,1);

psi_p = ini_platform_ang;

pCo = [cos(psi_p) sin(psi_p) 0; -sin(psi_p) cos(psi_p) 0; 0 0 1];
oCp = pCo';

[oCb,bCo] = rotation_sequence(ini_euler);

R2n_o = ini_Rcm_o + (oCb*tether2n_pos);

R21_o = gnd_station + oCp*R21_g;


R2io = zeros(3*N,1);


for i = 1:N
    
    if i == 1
        R2io((3*i-2):(3*i),1) = R21_o;
        
    elseif i>1 && i<N
        R2io((3*i-2):(3*i),1) = R21_o + ((R2n_o - R21_o)*(i-1)/(N-1));
        
    elseif i == N
        R2io((3*i-2):(3*i),1) = R2n_o;
   
    end
end
        
node_locations.tether_2_nodes = R2io;

end

