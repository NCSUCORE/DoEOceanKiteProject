function op = multinode_F_and_T_external(sim_param,flow,unstretched_l,elevon_def,Rcm_o,R1i_o,R2i_o,R3i_o,...
    O_Vcm_o,O_V1i_o,O_V2i_o,O_V3i_o,OwB,euler_ang,plat_ang)

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

R1n_cm = tether_imp_nodes.R1n_cm;
R2n_cm = tether_imp_nodes.R2n_cm;
R3n_cm = tether_imp_nodes.R3n_cm;

R11_g = tether_imp_nodes.R11_g;
R21_g = tether_imp_nodes.R21_g;
R31_g = tether_imp_nodes.R31_g;


% calculate tether masses and spring stiffness
tether_density = tether_param.tether_density;
tether_dia = tether_param.tether_diameter;
zeta = tether_param.damping_ratio;

tether_masses = ((tether_density*(pi/4)).*tether_dia.^2).*unstretched_l;

%% spring stiffness
tether_CS = (pi/4)*tether_dia.^2;

full_length_stiff = tether_youngs*(tether_CS.*[1/unstretched_l(1);1/unstretched_l(2);1/unstretched_l(3)]);

ks1 = full_length_stiff(1)*(N-1);
ks2 = full_length_stiff(2)*(N-1);
ks3 = full_length_stiff(3)*(N-1);

%% damping coeff
% full length damping coeff
full_length_d_coeff = zeta*(2*sqrt(full_length_stiff*m));

% tether damping coeff
damping_coeff = full_length_d_coeff*(N-1);

c1 = damping_coeff(1);
c2 = damping_coeff(2);
c3 = damping_coeff(3);


%% rotations
[oCb,bCo] = rotation_sequence(euler_ang);
% platform
pCo = [cos(plat_ang) sin(plat_ang) 0; -sin(plat_ang) cos(plat_ang) 0; 0 0 1];
oCp = pCo';


L1 = unstretched_l(1);
L2 = unstretched_l(2);
L3 = unstretched_l(3);

L1i = L1/(N-1);
L2i = L2/(N-1);
L3i = L3/(N-1);


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

d1i = NaN(N-1,1);
d2i = NaN(N-1,1);
d3i = NaN(N-1,1);

d1i_dot = NaN(N-1,1);
d2i_dot = NaN(N-1,1);
d3i_dot = NaN(N-1,1);

Ts1i = NaN(N-1,1);
Ts2i = NaN(N-1,1);
Ts3i = NaN(N-1,1);

Td1i = NaN(N-1,1);
Td2i = NaN(N-1,1);
Td3i = NaN(N-1,1);

Ft1i = NaN(3,N-1);
Ft2i = NaN(3,N-1);
Ft3i = NaN(3,N-1);


for i = 1:N-1
    
    d1i(i) = norm(R1i_o((3*i + 1):(3*i + 3),1) - R1i_o((3*i - 2):(3*i),1));
    d2i(i) = norm(R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1));
    d3i(i) = norm(R3i_o((3*i + 1):(3*i + 3),1) - R3i_o((3*i - 2):(3*i),1));
    
    d1i_dot(i) = (1/d1i(i))*dot((R1i_o((3*i + 1):(3*i + 3),1) - R1i_o((3*i - 2):(3*i),1)),...
        (O_V1i_o((3*i + 1):(3*i + 3),1) - O_V1i_o((3*i - 2):(3*i),1)));
    
    d2i_dot(i) = (1/d2i(i))*dot((R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1)),...
        (O_V2i_o((3*i + 1):(3*i + 3),1) - O_V2i_o((3*i - 2):(3*i),1)));
    
    d3i_dot(i) = (1/d3i(i))*dot((R3i_o((3*i + 1):(3*i + 3),1) - R3i_o((3*i - 2):(3*i),1)),...
        (O_V3i_o((3*i + 1):(3*i + 3),1) - O_V3i_o((3*i - 2):(3*i),1)));
    
    
    if d1i(i) > L1i
        Ts1i(i) = ks1*(d1i(i) - L1i);
        Td1i(i) = c1*(d1i_dot(i));
    else
        Ts1i(i) = 0;
        Td1i(i) = 0;
    end
    
    if d2i(i) > L2i
        Ts2i(i) = ks2*(d2i(i) - L2i);
        Td2i(i) = c2*(d2i_dot(i));
    else
        Ts2i(i) = 0;
        Td2i(i) = 0;
    end
    
    if d3i(i) > L3i
        Ts3i(i) = ks3*(d3i(i) - L3i);
        Td3i(i) = c3*(d3i_dot(i));
    else
        Ts3i(i) = 0;
        Td3i(i) = 0;
    end
    
    Ft1i(:,i) = (Ts1i(i) + Td1i(i))* ((R1i_o((3*i + 1):(3*i + 3),1) - R1i_o((3*i - 2):(3*i),1))/...
        norm(R1i_o((3*i + 1):(3*i + 3),1) - R1i_o((3*i - 2):(3*i),1)) );
%      if (Ts1i(i) + Td1i(i))<0
%          x = 1;
%      end
    
    Ft2i(:,i) = (Ts2i(i) + Td2i(i))* ((R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1))/...
        norm(R2i_o((3*i + 1):(3*i + 3),1) - R2i_o((3*i - 2):(3*i),1)) );
    
    Ft3i(:,i) = (Ts3i(i) + Td3i(i))* ((R3i_o((3*i + 1):(3*i + 3),1) - R3i_o((3*i - 2):(3*i),1))/...
        norm(R3i_o((3*i + 1):(3*i + 3),1) - R3i_o((3*i - 2):(3*i),1)) );
    
end

%% tether tension force at each node

tet_1_f = NaN(3,N);
tet_2_f = NaN(3,N);
tet_3_f = NaN(3,N);

for i = 1:N
    
    if i == 1
        tet_1_f(:,i) = Ft1i(:,i);
        tet_2_f(:,i) = Ft2i(:,i);
        tet_3_f(:,i) = Ft3i(:,i);
        
    elseif i>1 && i<N
        tet_1_f(:,i) = Ft1i(:,i) - Ft1i(:,i-1);
        tet_2_f(:,i) = Ft2i(:,i) - Ft2i(:,i-1);
        tet_3_f(:,i) = Ft3i(:,i) - Ft3i(:,i-1);
        
    elseif i == N
        tet_1_f(:,i) = - Ft1i(:,i-1);
        tet_2_f(:,i) = - Ft2i(:,i-1);
        tet_3_f(:,i) = - Ft3i(:,i-1);
        
    end
    
end

%% aero forces acting on each tether node
O_aero_1 = NaN(3,N-1);
O_aero_2 = NaN(3,N-1);
O_aero_3 = NaN(3,N-1);

O_V_flow_1i = zeros(size(O_V1i_o));
O_V_flow_2i = zeros(size(O_V2i_o));
O_V_flow_3i = zeros(size(O_V3i_o));

% relative velocity at each node
for i = 1:N
    O_V_flow_1i((3*i - 2):(3*i),1) = flow - O_V1i_o((3*i - 2):(3*i),1);
    O_V_flow_2i((3*i - 2):(3*i),1) = flow - O_V2i_o((3*i - 2):(3*i),1);
    O_V_flow_3i((3*i - 2):(3*i),1) = flow - O_V3i_o((3*i - 2):(3*i),1);
    
    % ignoring the z component
    O_V_flow_1i(3*i,1) = 0;
    O_V_flow_2i(3*i,1) = 0;
    O_V_flow_3i(3*i,1) = 0;
    
end

% drag at each element
th1i = zeros(size(d1i));
th2i = zeros(size(d2i));
th3i = zeros(size(d3i));

O_V_flow_elem1i = zeros(length(R1i_o)-3,1);
O_V_flow_elem2i = zeros(length(R2i_o)-3,1);
O_V_flow_elem3i = zeros(length(R3i_o)-3,1);

for i = 1:N-1
    O_V_flow_elem1i((3*i - 2):(3*i),1) = (1/2)*( O_V_flow_1i((3*i - 2):(3*i),1) + O_V_flow_1i((3*i + 1):(3*i + 3),1));
    O_V_flow_elem2i((3*i - 2):(3*i),1) = (1/2)*( O_V_flow_2i((3*i - 2):(3*i),1) + O_V_flow_2i((3*i + 1):(3*i + 3),1));
    O_V_flow_elem3i((3*i - 2):(3*i),1) = (1/2)*( O_V_flow_3i((3*i - 2):(3*i),1) + O_V_flow_3i((3*i + 1):(3*i + 3),1));
    
    th1i(i,1) = atan((R1i_o((3*i + 3),1) - R1i_o((3*i),1))/norm((R1i_o((3*i+1):(3*i+2),1) - R1i_o((3*i-2):(3*i-1),1))));
    th2i(i,1) = atan((R2i_o((3*i + 3),1) - R2i_o((3*i),1))/norm((R2i_o((3*i+1):(3*i+2),1) - R2i_o((3*i-2):(3*i-1),1))));
    th3i(i,1) = atan((R3i_o((3*i + 3),1) - R3i_o((3*i),1))/norm((R3i_o((3*i+1):(3*i+2),1) - R3i_o((3*i-2):(3*i-1),1))));
    
    O_aero_1(:,i) = CD_cylinder*(1/2)*rho*O_V_flow_elem1i((3*i - 2):(3*i),1)*norm(O_V_flow_elem1i((3*i - 2):(3*i),1))*...
        d1i(i)*sin(th1i(i,1))*tether_dia(1);
    
    O_aero_2(:,i) = CD_cylinder*(1/2)*rho*O_V_flow_elem2i((3*i - 2):(3*i),1)*norm(O_V_flow_elem2i((3*i - 2):(3*i),1))*...
        d2i(i)*sin(th2i(i,1))*tether_dia(2);
    
    O_aero_3(:,i) = CD_cylinder*(1/2)*rho*O_V_flow_elem3i((3*i - 2):(3*i),1)*norm(O_V_flow_elem3i((3*i - 2):(3*i),1))*...
        d3i(i)*sin(th3i(i,1))*tether_dia(3);

end


%% aero forces at each node
aero_1_f = NaN(3,N);
aero_2_f = NaN(3,N);
aero_3_f = NaN(3,N);

for i = 1:N
    
    if i == 1
        aero_1_f(:,i) = (1/2)*O_aero_1(:,i);
        aero_2_f(:,i) = (1/2)*O_aero_2(:,i);
        aero_3_f(:,i) = (1/2)*O_aero_3(:,i);
        
    elseif i>1 && i<N
        aero_1_f(:,i) = (1/2)*(O_aero_1(:,i-1) + O_aero_1(:,i));
        aero_2_f(:,i) = (1/2)*(O_aero_2(:,i-1) + O_aero_2(:,i));
        aero_3_f(:,i) = (1/2)*(O_aero_3(:,i-1) + O_aero_3(:,i));
        
    elseif i == N
        aero_1_f(:,i) = (1/2)*(O_aero_1(:,i-1));
        aero_2_f(:,i) = (1/2)*(O_aero_2(:,i-1));
        aero_3_f(:,i) = (1/2)*(O_aero_3(:,i-1));
        
    end
    
end

% store magnitude of forces
aero_1i = NaN(N-1,1);
aero_2i = NaN(N-1,1);
aero_3i = NaN(N-1,1);

for i = 1:N-1
    aero_1i(i,1) = norm(O_aero_1(:,i));
    aero_2i(i,1) = norm(O_aero_2(:,i));
    aero_3i(i,1) = norm(O_aero_3(:,i));
end


%% weight force acting on each node
grav_1_f = NaN(3,N);
grav_2_f = NaN(3,N);
grav_3_f = NaN(3,N);

m1i = tether_masses(1)/(N-2);
m2i = tether_masses(2)/(N-2);
m3i = tether_masses(3)/(N-2);


for i = 1:N
    
    if i == 1
        grav_1_f(:,i) = [0;0;0];
        grav_2_f(:,i) = [0;0;0];
        grav_3_f(:,i) = [0;0;0];
        
    elseif i>1 && i<N
        grav_1_f(:,i) = m1i*[0;0;-g];
        grav_2_f(:,i) = m2i*[0;0;-g];
        grav_3_f(:,i) = m3i*[0;0;-g];
        
    elseif i == N
        grav_1_f(:,i) = [0;0;0];
        grav_2_f(:,i) = [0;0;0];
        grav_3_f(:,i) = [0;0;0];
    end
    
end

%% sum of forces acting on each tether node
sum_1_f = NaN(3,N);
sum_2_f = NaN(3,N);
sum_3_f = NaN(3,N);

for i = 1:N
    
    if i == 1
        
        sum_1_f(:,i) = tet_1_f(:,i) + aero_1_f(:,i) + grav_1_f(:,i);
        sum_2_f(:,i) = tet_2_f(:,i) + aero_2_f(:,i) + grav_2_f(:,i);
        sum_3_f(:,i) = tet_3_f(:,i) + aero_3_f(:,i) + grav_3_f(:,i);
        
        % force in the z direction for the first node is 0
        sum_1_f(3,i) = 0;
        sum_2_f(3,i) = 0;
        sum_3_f(3,i) = 0;
        
        
    elseif i>1 && i<=N
        
        sum_1_f(:,i) = tet_1_f(:,i) + aero_1_f(:,i) + grav_1_f(:,i);
        sum_2_f(:,i) = tet_2_f(:,i) + aero_2_f(:,i) + grav_2_f(:,i);
        sum_3_f(:,i) = tet_3_f(:,i) + aero_3_f(:,i) + grav_3_f(:,i);
        
    end
    
    if abs(sum_1_f(1,1)) > 10e5 || abs(sum_1_f(2,1)) > 10e5 || abs(sum_1_f(3,1)) > 10e5
        z1 = 0;
    end
    if abs(sum_2_f(1,1)) > 10e5 || abs(sum_2_f(2,1)) > 10e5 || abs(sum_2_f(3,1)) > 10e5
        z2 = 0;
    end
    if abs(sum_3_f(1,1)) > 10e5 || abs(sum_3_f(2,1)) > 10e5 || abs(sum_3_f(3,1)) > 10e5
        z3 = 0;
    end
end
%% forces acting on the center of mass
O_F_ext = O_F_buoy + O_F_grav + O_F_aero_mw + O_F_aero_VS + O_F_turb1 + O_F_turb2 +...
    sum_1_f(:,end) + sum_2_f(:,end) + sum_3_f(:,end);


%% External torque
% torque due to buoyancy about CM in the B frame
B_T_buoy = cross(Rcb_cm,(bCo*O_F_buoy));

% torque due to gravity about CM
B_T_grav = [0;0;0];

% torque due to the three tethers in the B frame
B_Tt1 = cross(R1n_cm,(bCo*sum_1_f(:,end)));
B_Tt2 = cross(R2n_cm,(bCo*sum_2_f(:,end)));
B_Tt3 = cross(R3n_cm,(bCo*sum_3_f(:,end)));

%% Total external torque about CM in the B frame
B_T_ext = B_T_buoy + B_T_grav + B_T_aero_mw + B_T_aero_VS + B_T_aero_turb + ...
    B_Tt1 + B_Tt2 + B_Tt3;

%% Torque about platform origin
T_o_ext = cross(R11_g,(pCo*sum_1_f(1:3,1))) + ...
    cross(R21_g,(pCo*sum_2_f(1:3,1))) + ...
    cross(R31_g,(pCo*sum_3_f(1:3,1)));
    
T_o_ext = T_o_ext(3);

%% store in structure
% important forces which are used for states calculations
op.sum_1_f = sum_1_f;
op.sum_2_f = sum_2_f;
op.sum_3_f = sum_3_f;
op.O_F_ext = O_F_ext;
op.B_T_ext = B_T_ext;
op.T_o_ext = T_o_ext;

op.B_T_buoy = B_T_buoy;
op.B_T_grav = B_T_grav;
op.B_T_aero_mw = B_T_aero_mw;
op.B_T_aero_VS = B_T_aero_VS;
op.B_T_aero_turb = B_T_aero_turb;
op.B_Tt1 = B_Tt1;
op.B_Tt2 = B_Tt2;
op.B_Tt3 = B_Tt3;





% output aero forces
op.aero_F = aero_F;

% secondary forces used for postprocessing
op.Ts1i = Ts1i;
op.Ts2i = Ts2i;
op.Ts3i = Ts3i;
op.Td1i = Td1i;
op.Td2i = Td2i;
op.Td3i = Td3i;

op.aero_1i = aero_1i;
op.aero_2i = aero_2i;
op.aero_3i = aero_3i;

% tether masses
op.tether_masses = tether_masses;

end
