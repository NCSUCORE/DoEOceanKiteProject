function aero_F = B_F_and_T_aero(sim_param,flow,Rcm_o,O_Vcm_o,euler_ang,delta_alpha)

%% extract from structure
aero_param = sim_param.aero_param;
env_param = sim_param.env_param;
turbine_param = sim_param.turbine_param;
elevons_param = sim_param.elevons_param;

CM_nom = elevons_param.CM_nom;
k_CM = elevons_param.k_CM;

rho = env_param.density;

span = sim_param.geom_param.span;
chord = sim_param.geom_param.chord;
AR = sim_param.geom_param.AR;
Rmidspan_cm = [0;span/4;0];

Sref = aero_param.Sref;

pcl_mw = aero_param.pcl_mw;
pcd_mw = aero_param.pcd_mw;
pcm_mw = aero_param.pcm_mw;

HS_Sref = aero_param.HS_Sref;
VS_Sref = aero_param.VS_Sref;
pcl_VS = aero_param.pcl_VS;
pcd_VS = aero_param.pcd_VS;
pcm_VS = aero_param.pcm_VS;

A_turbine = turbine_param.A_turbine;
CD_turb = turbine_param.CD_turb;
Cp_turb = turbine_param.Cp_turb;

% position vectors
Rac_cm = sim_param.geom_param.aero_center;
Rvs_cm = aero_param.Rvs_cm;
R1turb_cm = turbine_param.R1turb_cm;
R2turb_cm = turbine_param.R2turb_cm;

% change in effective angle of attack due to control surfaces
delta_alp1 = delta_alpha(1);
delta_alp2 = delta_alpha(2);

% delta elevator control
delta_pitch = (1/2)*(delta_alp1 + delta_alp2);
delta_roll = delta_alp1 - delta_alp2;

% rotation matrix
[oCb,bCo] = rotation_sequence(euler_ang);

% relative velocity in O frame
O_Vrel = flow - O_Vcm_o;

% relative/apparent velocity in the B frame
B_Vrel = bCo*O_Vrel;

% breaking down the relative velocity in the B frame
vxb = B_Vrel(1); vyb = B_Vrel(2); vzb = B_Vrel(3);

% apparent flow velocity in the XZ plane
V_app_xz = sqrt(vxb^2 + vzb^2);

% apparent flow velocity in the Xy plane
V_app_xy = sqrt(vxb^2 + vyb^2);

% angle of attack and side slip angle
alpha = atan2(vzb,vxb);
beta = asin(vyb/norm(B_Vrel));

% converting to degree
alpha_deg = alpha*(180/pi);
beta_deg = beta*(180/pi);

%% IMPORTANT
% limiting alpha values
if norm(alpha_deg) > 29
    CL_mw = polyval(pcl_mw,29);
    CD_mw = polyval(pcd_mw,29) + CL_mw^2/(pi*AR);
    CM_mw = polyval(pcm_mw,alpha_deg);
    
else
    CL_mw = polyval(pcl_mw,alpha_deg);
    CD_mw = polyval(pcd_mw,alpha_deg) + CL_mw^2/(pi*AR);
    CM_mw = polyval(pcm_mw,alpha_deg);
    
end

% limiting beta values
if norm(beta_deg) > 29
    
    CL_VS = polyval(pcl_VS,29);
    CD_VS = polyval(pcd_VS,29);
    CM_VS = polyval(pcm_VS,beta_deg);

else
    CL_VS = polyval(pcl_VS,beta_deg);
    CD_VS = polyval(pcd_VS,beta_deg);
    CM_VS = polyval(pcm_VS,beta_deg);
    
end

%% MAIN WING FORCES
% dynamic viscosity
dyn_visco = (1/2)*rho*norm(B_Vrel)^2;

% wing force
Fd_mw_app = CD_mw*dyn_visco*Sref;
Fl_mw_app = CL_mw*dyn_visco*Sref;

% HS force
Fd_hs_app = CD_mw*dyn_visco*HS_Sref;
Fl_hs_app = CL_mw*dyn_visco*HS_Sref;

% drag direction
mw_drag_dir = B_Vrel/norm(B_Vrel);

% lift direction
mw_lz = sqrt(1/(1 + (vzb/vxb)^2));
mw_lx = -mw_lz*(vzb/vxb);
mw_lift_dir = [mw_lx;0;mw_lz];

% aerodynamic forces on main wing in the body frame
B_F_drag_mw = (Fd_mw_app + Fd_hs_app)*mw_drag_dir;
B_F_lift_mw = (Fl_mw_app + Fl_hs_app)*mw_lift_dir;

B_F_aero_mw = B_F_drag_mw + B_F_lift_mw;

%% VERTICAL STABILIZER FORCES
% aerodynamic forces in the apparent flow frame
Fd_VS_app = CD_VS*dyn_visco*VS_Sref;
Fl_VS_app = CL_VS*dyn_visco*VS_Sref;

% lift direction
vs_ly = sqrt(1/(1 + (vyb/vxb)^2));
vs_lx = -vs_ly*(vyb/vxb);
vs_lift_dir = [vs_lx;vs_ly;0];

% aerodynamic forces on rudder in the body frame
B_F_drag_VS = Fd_VS_app*mw_drag_dir;
B_F_lift_VS = Fl_VS_app*vs_lift_dir;

B_F_aero_VS = B_F_drag_VS + B_F_lift_VS;

%% TURBINE FORCES

Fd_turb1 = CD_turb*dyn_visco*A_turbine;
Fd_turb2 = CD_turb*dyn_visco*A_turbine;

B_F_turb1 = Fd_turb1*mw_drag_dir;
B_F_turb2 = Fd_turb2*mw_drag_dir;

gen_power = 2*0.5*rho*(vxb^3)*Cp_turb*A_turbine;

if gen_power < 0
    gen_power = 0;  
elseif norm(gen_power) > turbine_param.rated_power
    gen_power = turbine_param.rated_power;
end

%% TORQUES
% torque about roll axis due to aileron
T_roll = [(CM_nom*k_CM*delta_roll)*dyn_visco*Sref*chord;0;0];

% torque about pitch axis due to aileron
T_pitch = [0;(CM_nom*k_CM*delta_pitch)*dyn_visco*Sref*chord;0];

% torque due to aero forces on main wing about CM in the B frame
B_T_aero_mw = cross(Rac_cm,B_F_aero_mw) + T_roll + T_pitch;

% torque due to aero forces on main wing about CM in the B frame
B_T_aero_VS = cross(Rvs_cm,B_F_aero_VS);

% torque due to turbine drag
B_T_aero_turb = cross(R1turb_cm,B_F_turb1) + cross(R2turb_cm,B_F_turb2);


%% store in structure
% primary elements
aero_F.B_F_aero_mw = B_F_aero_mw;
aero_F.B_F_aero_VS = B_F_aero_VS;
aero_F.B_F_turb1 = B_F_turb1;
aero_F.B_F_turb2 = B_F_turb2;
aero_F.B_T_aero_mw = B_T_aero_mw;
aero_F.B_T_aero_VS = B_T_aero_VS;
aero_F.B_T_aero_turb = B_T_aero_turb;

% secondary elements
aero_F.gen_power = gen_power;
aero_F.alpha_deg = alpha_deg;
aero_F.beta_deg = beta_deg;
aero_F.B_Vrel = B_Vrel;


end









