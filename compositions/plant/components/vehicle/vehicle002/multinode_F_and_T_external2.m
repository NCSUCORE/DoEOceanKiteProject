function op = multinode_F_and_T_external2(sim_param,flow,elevon_def,Rcm_o,...
    O_Vcm_o,OwB,euler_ang,end_node_forces)

%% extracting values from sim parameters structure
env_param = sim_param.env_param;
geom_param = sim_param.geom_param;
tether_imp_nodes = sim_param.tether_imp_nodes;

m = geom_param.mass;
g = env_param.grav;

Rcb_cm = geom_param.center_of_buoy;

R1n_cm = tether_imp_nodes.R1n_cm;
R2n_cm = tether_imp_nodes.R2n_cm;
R3n_cm = tether_imp_nodes.R3n_cm;

%% rotations
[oCb,bCo] = rotation_sequence(euler_ang);

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

% 
sum_1_f = end_node_forces(1).tenVec(:,1);
sum_2_f = end_node_forces(2).tenVec(:,1);
sum_3_f = end_node_forces(3).tenVec(:,1);

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


%% store in structure
% important forces which are used for states calculations
op.sum_1_f = sum_1_f;
op.sum_2_f = sum_2_f;
op.sum_3_f = sum_3_f;
op.O_F_ext = O_F_ext;
op.B_T_ext = B_T_ext;

op.B_T_buoy = B_T_buoy;
op.B_T_aero_mw = B_T_aero_mw;
op.B_T_aero_VS = B_T_aero_VS;


end
