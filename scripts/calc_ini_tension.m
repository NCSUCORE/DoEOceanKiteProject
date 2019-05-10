function ini_elongation = calc_ini_tension(F_buoy,mass,euler_ang,delta_alpha,sim_param,flow,O_Vcm_o,Rcm_o,full_length_stiff,tether_masses,N)

env_param = sim_param.env_param;

[oCb,bCo] = rotation_sequence(euler_ang);

% parameters
g = env_param.grav;

% buoy
O_F_buoy = [0;0;F_buoy];

% garvity
Fg_body = -mass*g;

Fg_tether = -sum(tether_masses./(N-1))*g;

O_Fg = [0;0;(Fg_body + Fg_tether)];


%% calculate aero forces
aero_F = B_F_and_T_aero(sim_param,flow,Rcm_o,O_Vcm_o,euler_ang,delta_alpha);

B_F_aero_mw = aero_F.B_F_aero_mw;
B_F_aero_VS = aero_F.B_F_aero_VS;
B_F_turb1 = aero_F.B_F_turb1;
B_F_turb2 = aero_F.B_F_turb2;


O_F_aero_mw = oCb*B_F_aero_mw;
O_F_aero_VS = oCb*B_F_aero_VS;
O_F_turb1 = oCb*B_F_turb1;
O_F_turb2 = oCb*B_F_turb2;

%% total external forces
O_F_ext = O_F_buoy + O_Fg + O_F_aero_mw + O_F_aero_VS + O_F_turb1 + O_F_turb2;

% force in tether
Ft = norm(O_F_ext);

% spring stiffness
spring_stiffness = full_length_stiff*(N-1);

% initial elongation
ini_elongation = Ft./(spring_stiffness);

% keyboard


end