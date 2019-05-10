function op = multinode_F_and_T_external(sim_param,flow,unstretched_l,elevon_def,Rcm_o,R2i_o,...
    O_Vcm_o,O_V2i_o,OwB,euler_ang,plat_ang)

%% extracting values from sim parameters structure
N = sim_param.N;

env_param = sim_param.env_param;
geom_param = sim_param.geom_param;
aero_param = sim_param.aero_param;
turbine_param = sim_param.turbine_param;
tether_param = sim_param.tether_param;
tether_imp_nodes = sim_param.tether_imp_nodes;


m = geom_param.mass;
g = env_param.grav;
rho = env_param.density;

CD_cylinder = tether_param.CD_cylinder;
tether_youngs = tether_param.tether_youngs;


Rcb_cm = geom_param.center_of_buoy;
Rac_cm = geom_param.aero_center;
R1turb_cm = turbine_param.R1turb_cm;
R2turb_cm = turbine_param.R2turb_cm;


Rvs_cm = aero_param.Rvs_cm;

R2n_cm = tether_imp_nodes.R2n_cm;

R21_g = tether_imp_nodes.R21_g;


% calculate tether masses and spring stiffness
tether_density = tether_param.tether_density;
tether_dia = tether_param.tether_diameter;
zeta = tether_param.damping_ratio;

tether_CS = (pi/4)*tether_dia^2;

tether_masses = tether_density*tether_CS*unstretched_l;

%% spring stiffness

full_length_stiff = tether_youngs*tether_CS/unstretched_l;

ks2 = full_length_stiff*(N-1);

%% damping coeff
% full length damping coeff
full_length_d_coeff = zeta*(2*sqrt(full_length_stiff*m));

% tether damping coeff
damping_coeff = full_length_d_coeff*(N-1);

c2 = damping_coeff;

%% rotations
[oCb,bCo] = rotation_sequence(euler_ang);
% platform
pCo = [cos(plat_ang) sin(plat_ang) 0; -sin(plat_ang) cos(plat_ang) 0; 0 0 1];
oCp = pCo';

L2 = unstretched_l;

L2i = L2/(N-1);


%% force calculations
% buoyancy force in the ko direction
fz_buoy = geom_param.F_buoy;

% buoyancy force in the O frame
O_F_buoy = [0;0;fz_buoy];

% gravity force in the ko direction
fz_grav = -m*g;

% gravity force in the O frame
O_F_grav = [0;0;fz_grav];

% calculate aerodynamic forces on the lifting body
aero_F = B_F_and_T_aero(sim_param,flow,Rcm_o,O_Vcm_o,euler_ang,elevon_def);

B_F_aero_mw = aero_F.B_F_aero_mw;
B_F_aero_VS = aero_F.B_F_aero_VS;
B_F_turb1 = aero_F.B_F_turb1;
B_F_turb2 = aero_F.B_F_turb2;

B_T_aero_mw = aero_F.B_T_aero_mw;
B_T_aero_VS = aero_F.B_T_aero_VS;
B_T_aero_turb = aero_F.B_T_aero_turb;


O_F_aero_mw = oCb*B_F_aero_mw;
O_F_aero_VS = oCb*B_F_aero_VS;
O_F_turb1 = oCb*B_F_turb1;
O_F_turb2 = oCb*B_F_turb2;



%% tether nodes force calculations
% internal tether force in each element calculations
d2i = NaN(N-1,1);
d2i_dot = NaN(N-1,1);

Ts2i = NaN(N-1,1);
Td2i = NaN(N-1,1);

Ft2i = NaN(3,N-1);


for i = 1:N-1
    
    d2i(i) = norm(R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1));
    
    d2i_dot(i) = (1/d2i(i))*dot((R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1)),...
        (O_V2i_o((3*i + 1):(3*i + 3),1) - O_V2i_o((3*i - 2):(3*i),1)));
    
    if d2i(i) > L2i
        Ts2i(i) = ks2*(d2i(i) - L2i);
        Td2i(i) = c2*(d2i_dot(i));
    else
        Ts2i(i) = 0;
        Td2i(i) = 0;
    end
    
    
    Ft2i(:,i) = (Ts2i(i) + Td2i(i))* ((R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1))/...
        norm(R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1)) );
    
end

%% tether tension force at each node

tet_2_f = NaN(3,N);

for i = 1:N
    
    if i == 1
        tet_2_f(:,i) = Ft2i(:,i);
        
    elseif i>1 && i<N
        tet_2_f(:,i) = Ft2i(:,i) - Ft2i(:,i-1);
        
    elseif i == N
        tet_2_f(:,i) = - Ft2i(:,i-1);
        
    end
    
end

%% aero forces acting on each tether node
O_aero_2 = NaN(3,N-1);

O_V_flow_2i = zeros(size(O_V2i_o));

% relative velocity at each node
for i = 1:N
    O_V_flow_2i((3*i - 2):(3*i),1) = flow - O_V2i_o((3*i - 2):(3*i),1);
    
    % ignoring the z component
    O_V_flow_2i(3*i,1) = 0;
    
end

% drag at each element
th2i = zeros(size(d2i));

O_V_flow_elem2i = zeros(length(R2i_o)-3,1);

for i = 1:N-1
    O_V_flow_elem2i((3*i - 2):(3*i),1) = (1/2)*( O_V_flow_2i((3*i - 2):(3*i),1) + O_V_flow_2i((3*i + 1):(3*i + 3),1));
    
    th2i(i,1) = atan((R2i_o((3*i + 3),1) - R2i_o((3*i),1))/norm((R2i_o((3*i+1):(3*i+2),1) - R2i_o((3*i-2):(3*i-1),1))));
    
    O_aero_2(:,i) = CD_cylinder*(1/2)*rho*O_V_flow_elem2i((3*i - 2):(3*i),1)*norm(O_V_flow_elem2i((3*i - 2):(3*i),1))*...
        d2i(i)*sin(th2i(i,1))*tether_dia;
    
end


%% aero forces at each node
aero_2_f = NaN(3,N);

for i = 1:N
    
    if i == 1
        aero_2_f(:,i) = (1/2)*O_aero_2(:,i);
        
    elseif i>1 && i<N
        aero_2_f(:,i) = (1/2)*(O_aero_2(:,i-1) + O_aero_2(:,i));
        
    elseif i == N
        aero_2_f(:,i) = (1/2)*(O_aero_2(:,i-1));
        
    end
    
end

% store magnitude of forces
aero_2i = NaN(N-1,1);

for i = 1:N-1
    aero_2i(i,1) = norm(O_aero_2(:,i));
end


%% weight force acting on each node
grav_2_f = NaN(3,N);

m2i = tether_masses/(N-2);


for i = 1:N
    
    if i == 1
        grav_2_f(:,i) = [0;0;0];
        
    elseif i>1 && i<N
        grav_2_f(:,i) = m2i*[0;0;-g];
        
    elseif i == N
        grav_2_f(:,i) = [0;0;0];
    end
    
end

%% sum of forces acting on each tether node
sum_2_f = NaN(3,N);

for i = 1:N
    
    if i == 1
        
        sum_2_f(:,i) = tet_2_f(:,i) + aero_2_f(:,i) + grav_2_f(:,i);
        
        % force in the z direction for the first node is 0
        sum_2_f(3,i) = 0;
        
        
    elseif i>1 && i<=N
        
        sum_2_f(:,i) = tet_2_f(:,i) + aero_2_f(:,i) + grav_2_f(:,i);
        
    end
    
    
end

%% forces acting on the center of mass
O_F_ext = O_F_buoy + O_F_grav + O_F_aero_mw + O_F_aero_VS + O_F_turb1 + O_F_turb2 +...
      sum_2_f(:,end);


%% External torque
% torque due to buoyancy about CM in the B frame
B_T_buoy = cross(Rcb_cm,(bCo*O_F_buoy));

% torque due to gravity about CM
B_T_grav = [0;0;0];

% torque due to the three tethers in the B frame
B_Tt2 = cross(R2n_cm,(bCo*sum_2_f(:,end)));

%% Total external torque about CM in the B frame
B_T_ext = B_T_buoy + B_T_grav + B_T_aero_mw + B_T_aero_VS + B_T_aero_turb + ...
     B_Tt2;

%% Torque about platform origin
T_o_ext = cross(R21_g,(pCo*sum_2_f(1:3,1)));
    
T_o_ext = T_o_ext(3);

%% store in structure
% important forces which are used for states calculations
op.sum_2_f = sum_2_f;
op.O_F_ext = O_F_ext;
op.B_T_ext = B_T_ext;
op.T_o_ext = T_o_ext;

op.B_T_buoy = B_T_buoy;
op.B_T_aero_mw = B_T_aero_mw;
op.B_T_aero_VS = B_T_aero_VS;

% output aero forces
op.aero_F = aero_F;

% secondary forces used for postprocessing
op.Ts2i = Ts2i;
op.Td2i = Td2i;

op.aero_2i = aero_2i;

% tether masses
op.tether_masses = tether_masses;

end
