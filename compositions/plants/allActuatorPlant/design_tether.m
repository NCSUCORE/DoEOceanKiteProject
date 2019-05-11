function d_t = design_tether(sim_param,tether_youngs,max_elongation,set_alti,rated_flow)

env_param = sim_param.env_param;
geom_param = sim_param.geom_param;
aero_param = sim_param.aero_param;
turbine_param = sim_param.turbine_param;

Vf = rated_flow;

% environmental parameters
rho = env_param.density;
g = env_param.grav;

% geometric parameters
vol = geom_param.vol;
BF = geom_param.buoy_factor;

% aero_param
Sref = aero_param.Sref;
HS_Sref = aero_param.HS_Sref;
VS_Sref = aero_param.VS_Sref;
pcl_mw = aero_param.pcl_mw;
pcd_mw = aero_param.pcd_mw;

% find max Cl and corresponding Cd
alp_n = linspace(-29,29,500);
pcl_n = polyval(pcl_mw,alp_n);
pcd_n = polyval(pcd_mw,alp_n);

[cl_max,icl] = max(pcl_n);
cd_at_cl_max = pcd_n(icl);

% turbine parameters
A_turbine = turbine_param.A_turbine;
CD_turb = turbine_param.CD_turb;


%% forces acting on body
F_buoy = [0;0;rho*vol];
F_grav = -(1/BF)*F_buoy;

q = (1/2)*rho*Vf^2;

Fw = q*Sref*[cd_at_cl_max; 0; cl_max];
F_hs = q*HS_Sref*[cd_at_cl_max; 0; cl_max];
F_vs = q*VS_Sref*[cd_at_cl_max; 0; 0];

F_turb = 2*q*CD_turb*[A_turbine; 0; 0];

F_tot = F_buoy + F_grav + Fw + F_hs + F_vs + F_turb;

T_tol = norm(F_tot);

max_delta_l = max_elongation*set_alti;

k_forward = T_tol/(4*max_delta_l);
k_aft = 2*k_forward;

d_t = (((4/pi)*(set_alti/tether_youngs)).*[k_forward;k_aft;k_forward]).^(0.5);






end