function node_locations = intermediate_nodes(R11_g,R21_g,R31_g,tether1n_pos,tether2n_pos,tether3n_pos,N,X0_partial)

ini_Rcm_o = X0_partial(1:3,1);
ini_euler = X0_partial(7:9,1);
gnd_station = X0_partial(15:17,1);
ini_platform_ang = X0_partial(13,1);

psi_p = ini_platform_ang;

pCo = [cos(psi_p) sin(psi_p) 0; -sin(psi_p) cos(psi_p) 0; 0 0 1];
oCp = pCo';

[oCb,bCo] = rotation_sequence(ini_euler);

R1n_o = ini_Rcm_o + (oCb*tether1n_pos);
R2n_o = ini_Rcm_o + (oCb*tether2n_pos);
R3n_o = ini_Rcm_o + (oCb*tether3n_pos);

R11_o = gnd_station + oCp*R11_g;
R21_o = gnd_station + oCp*R21_g;
R31_o = gnd_station + oCp*R31_g;


R1io = zeros(3*N,1);
R2io = zeros(3*N,1);
R3io = zeros(3*N,1);


for i = 1:N
    
    if i == 1
        R1io((3*i-2):(3*i),1) = R11_o;
        R2io((3*i-2):(3*i),1) = R21_o;
        R3io((3*i-2):(3*i),1) = R31_o;
        
    elseif i>1 && i<N
        R1io((3*i-2):(3*i),1) = R11_o + ((R1n_o - R11_o)*(i-1)/(N-1));
        R2io((3*i-2):(3*i),1) = R21_o + ((R2n_o - R21_o)*(i-1)/(N-1));
        R3io((3*i-2):(3*i),1) = R31_o + ((R3n_o - R31_o)*(i-1)/(N-1));
        
    elseif i == N
        R1io((3*i-2):(3*i),1) = R1n_o;
        R2io((3*i-2):(3*i),1) = R2n_o;
        R3io((3*i-2):(3*i),1) = R3n_o;
   
    end
end
        
        
node_locations.tether_1_nodes = R1io;
node_locations.tether_2_nodes = R2io;
node_locations.tether_3_nodes = R3io;

end

