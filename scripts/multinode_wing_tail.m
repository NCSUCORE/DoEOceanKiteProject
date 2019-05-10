%% clear
clc
format compact
% format shortEng
clear
% close all

%% load data files 
airfoil_data = readtable('naca0015data');
airfoil_data = table2array(airfoil_data);
load('adcp_data_file.mat');

adcp_flow.time = adcp_data.t_n;
adcp_flow.signals.values = adcp_data.u_depths_n;

% separate cd,cl and cm values
alp = airfoil_data(:,1);
cl = airfoil_data(:,2);
cd = airfoil_data(:,3);
cm = airfoil_data(:,5);

pcl_mw = polyfit(alp,0.9*cl,4);
pcd_mw = polyfit(alp,cd,4);
pcm_mw = polyfit(alp,cm,4);

alp_n = linspace(-29,29,500);
pcl_n = polyval(pcl_mw,alp_n);
pcd_n = polyval(pcd_mw,alp_n);
pcm_n = polyval(pcm_mw,alp_n);

% use same rudder
pcl_VS = pcl_mw;
pcd_VS = pcd_mw;
pcm_VS = pcm_mw;

[cl_max,i_clmax] = max(pcl_n);
cd_at_clmax = pcd_n(i_clmax);

%% master scaling parameters
k_scale = 1/1       % length scale
rho_scale = 1/1      % density scale


%% simulation parameters
nom_sim_time = 1800;
sim_time = nom_sim_time*sqrt(k_scale);

%% number of nodes on each tether
% number of nodes
N = 2;
sim_param.N = N;

%% turbulence input parameters
TI =  0.00;                                         % turbulence intensity (%)
f_min = 0.01;                                       % minimum frequency associated with TI
f_max = 1;                                          % max frequency associated with TI
P = 0.8;                                            % factor defining relation between standard devs of velocity components u and v
Q = 0.5;                                            % same as above but for u and w
C = 5;                                              % along flwo coherence deacy constant
N_mid_freq = 1500;                                  % number of frequency discretizations

% generate turbulence offline at average U_mean


%% env_paramal parameters
% fluid density
nom_density = 1000;  
density = rho_scale*nom_density;
% gravitaional acceleration
grav = 9.81;
% dynamic viscocity
mu = 1e-3;
% initial flow conditions
nom_flow = [1;0.0;0];
flow = sqrt(k_scale)*nom_flow;
% flow = (1/k_scale)*nom_flow;

% store in structure
env_param.density = density;
env_param.grav = grav;
env_param.mu = mu;
env_param.flow = flow;

sim_param.env_param = env_param;

%% lifting body geom_param parameters
% chord
nom_chord = 5;
chord = k_scale*nom_chord;

% nomial Reynolds number
Re_nom = nom_density*norm(nom_flow)*nom_chord/mu;

% quarter chord
c_4 = chord/4;
% center of gravity location
x_cm = 0.5*chord;
% aerodynamic center
x_ac = 0.8*chord;
% aspect ratio
AR = 8;
% span
span = AR*chord;
% volume
vol = (k_scale^3)*1.117e11*(1e-9);
% buoyant force
F_buoy = density*vol*grav;
% factor of buoyancy
buoy_factor = 1.25;
% F_gravity
F_grav = F_buoy/buoy_factor;
% balloon mass
mass = F_buoy/(buoy_factor*grav);
% center of buoyancy location wrt CM
center_of_buoy = [0;0;0.0];
% aero dynamic center location wrt CM
aero_center = [x_ac-x_cm;0;0];

% Moment of inertia about CG
Ixx = (k_scale^5)*1.433*1e13*(1e-6);
Iyy = (k_scale^5)*1.432*1e11*(1e-6);
Izz = (k_scale^5)*1.530*1e13*(1e-6);
MI(1,1) = Ixx; MI(2,2) = Iyy; MI(3,3) = Izz;

% store in structure
geom_param.chord = chord;
geom_param.x_cm = x_cm;
geom_param.AR = AR;
geom_param.span = span;
geom_param.vol = vol;
geom_param.F_buoy = F_buoy;
geom_param.buoy_factor = buoy_factor;
geom_param.mass = mass;
geom_param.center_of_buoy = center_of_buoy;
geom_param.aero_center = aero_center;
geom_param.MI = MI;


%% lifting body aero_param parameters
% symmetric airfoil thickness/chord
t_max = 0.15;

% reference area
Sref = chord*span;

% horizontal stabilizer
HS_LE = 4*chord;
HS_chord = 0.25*chord;
HS_AR = AR;
HS_span = HS_chord*HS_AR;

HS_Sref = HS_chord*HS_span;

% Vertical stbilizer
percent_VS = 1;
VS_chord = percent_VS*HS_chord;
VS_LE = HS_LE + (1 - percent_VS)*VS_chord;
VS_AR = HS_AR/4;
VS_span = VS_AR*VS_chord;
VS_TR = 0.8;
VS_sweep = 15;

aero_param.VS_LE = VS_LE;
aero_param.VS_length = VS_span;
aero_param.VS_TR = VS_TR;
aero_param.VS_sweep = VS_sweep;
aero_param.VS_chord = VS_chord;

aero_param = VS_and_HS_design(aero_param,geom_param);
Rvs_cm = aero_param.Rvs_cm;

VS_Sref = aero_param.VS_Sref;

% store in structure
aero_param.Sref = Sref;
aero_param.HS_Sref = HS_Sref;
aero_param.pcl_mw = pcl_mw;
aero_param.pcd_mw = pcd_mw;
aero_param.pcm_mw = pcm_mw;
aero_param.pcl_VS = pcl_VS;
aero_param.pcd_VS = pcd_VS;
aero_param.pcm_VS = pcm_VS;

sim_param.aero_param = aero_param;

%% added mass
m_added_x = pi*density*(span*(0.15*chord/2)^2 + HS_span*(0.15*HS_chord/2)^2 + VS_span*(0.15*VS_chord/2)^2);
m_added_y = pi*density*(1.98*span*(chord/2)^2 + 1.98*HS_span*(HS_chord/2)^2 + VS_span*(VS_chord/2)^2);
m_added_z = pi*density*(span*(chord/2)^2 + HS_span*(HS_chord/2)^2 + 1.98*VS_span*(VS_chord/2)^2);

m_added = [m_added_x;m_added_y;m_added_z];

Izz_added = 0;

geom_param.m_added = m_added;
geom_param.Izz_added = Izz_added;

sim_param.geom_param = geom_param;


%% power parameters
Cp_turb = 0.5;
nominal_rated_flow = 1.5;
rated_flow = nominal_rated_flow;

d_turbine_nom = 0;
d_turbine = k_scale*d_turbine_nom;

A_turbine = (pi/4)*d_turbine^2;

req_power = A_turbine*(0.5*density*Cp_turb*rated_flow^3);

turb_dis = (3/2)*d_turbine;

CD_turb = 1*0.8;

turb_offset = chord/20;

R1turb_cm = [(chord - x_cm);-(span/2 + turb_offset);0];
R2turb_cm = [(chord - x_cm); (span/2 + turb_offset);0];

turbine_param.d_turbine = d_turbine;
turbine_param.A_turbine = (pi/4)*d_turbine^2;
turbine_param.Cp_turb = Cp_turb;
turbine_param.CD_turb = CD_turb;
turbine_param.R1turb_cm = R1turb_cm;
turbine_param.R2turb_cm = R2turb_cm;
turbine_param.rated_power = 2*req_power;

sim_param.turbine_param = turbine_param;

%% nominal set points
% nominal altitude setpoint
set_alti_nom = 200;
% set alti
set_alti = k_scale*set_alti_nom;
% set pitch
set_pitch = 7;
set_pitch = set_pitch*(pi/180);

% set roll
set_roll = 0;
set_roll = set_roll*(pi/180);

%% tether parameters
% drag over cylinder for tether drag Re~1.2 e6
CD_cylinder = 0.5;
% youngs modulus
nom_tether_youngs = 1*3.8e9;
tether_youngs = k_scale*nom_tether_youngs;
% tether density in working fluid
tether_actual_density = 1300*rho_scale;       
tether_density = tether_actual_density - density;
% tether_density = 0.1*rho_scale;

% maximum percent elongation
max_elongation = 0.01;         

% tether diameter design
d_t = design_tether(sim_param,tether_youngs,max_elongation,set_alti,rated_flow);

nom_tether_diameter = 0.105;
tether_diameter = k_scale*(rho_scale^(1/1.985))*nom_tether_diameter;

% damping ratio
damping_ratio = 0.05;

% full length damping coeffient
% full_length_d_coeff = 200*(tether_diameter./0.01).^2;
% cross section area
tether_CS = (pi/4)*tether_diameter.^2;

% store in structure
tether_param.tether_density = tether_density;
tether_param.tether_diameter = tether_diameter;
tether_param.tether_youngs = tether_youngs;
tether_param.tether_CS = tether_CS;
tether_param.damping_ratio = damping_ratio;
tether_param.CD_cylinder = CD_cylinder;

sim_param.tether_param = tether_param;

%% important tether node locations
% last node locations wrt CM
R2n_cm = [(HS_LE + HS_chord)/2; 0; -t_max*chord/2];

% first node location wrt origin
R21_g = 1*[R2n_cm(1); R2n_cm(2); -R2n_cm(3)];

% store in structure
tether_imp_nodes.R2n_cm = R2n_cm;
tether_imp_nodes.R21_g = R21_g;


%% platform parameters
% ground station location
gnd_station = [0;0;0];
% platform Izz
platform_Izz = (k_scale^5)*100;
%platform mass
platform_mass = 1;
% platform damping
platform_damping = 10;

% store in structure
platform_param.platform_Izz = platform_Izz;
platform_param.platform_mass = platform_mass;
platform_param.platform_damping = platform_damping;
platform_param.gnd_station = gnd_station;


%% controller parameters
% winch saturation velocities
nom_vel_up_lim = 0.4;
vel_up_lim = sqrt(k_scale)*nom_vel_up_lim;
winc_vel_up_lims = vel_up_lim*ones(1,1);

% winch time constant
nom_t_winch = 1;
t_winch = sqrt(k_scale)*nom_t_winch;

% Gains and time constants altitude
Kp_z = 1*sqrt(k_scale)*0.05;
Ki_z = 0;
Kd_z = 5*Kp_z;

cut_off_f_z = 0.005/sqrt(k_scale);
wce_z = 2*pi*cut_off_f_z;

alti_control.Kp_z = Kp_z;
alti_control.Ki_z = Ki_z;
alti_control.Kd_z = Kd_z;
alti_control.wce_z = wce_z;

% store in structure
controller_param.winc_vel_up_lims = winc_vel_up_lims;
controller_param.alti_control = alti_control;

sim_param.controller_param = controller_param;

%% control surfaces parameters: (elevons)
max_deflection = 30;
elevon_max_deflection = max_deflection*ones(2,1);

elevon_gain = 0.4;

% nominal CM and other gains
CM_nom = -0.1;
k_CM = 0.6;

% elevator gaines
kp_elev = 1*10;
ki_elev = 0.0*kp_elev;
kd_elev = sqrt(k_scale)*3*kp_elev;

t_elev = sqrt(k_scale)*0.05;

elev_tf = tf([kd_elev kp_elev],[t_elev 1]);

elevator_control.kp_elev = kp_elev;
elevator_control.ki_elev = ki_elev;
elevator_control.kd_elev = kd_elev;
elevator_control.t_elev = t_elev;

% aileron gains
kp_aileron = 1*4;
ki_aileron = 0.0*kp_aileron;
kd_aileron = 2*sqrt(k_scale)*kp_aileron;

t_aileron = sqrt(k_scale)*0.2;

aileron_tf = tf([kd_aileron kp_aileron],[t_aileron 1]);

aileron_control.kp_aileron = kp_aileron;
aileron_control.ki_aileron = ki_aileron;
aileron_control.kd_aileron = kd_aileron;
aileron_control.t_aileron = t_aileron;

% co-ordinate transformation matrix
P_cs_mat = [-1 -1; -1 1];

% store in structure
elevons_param.elevon_max_deflection = elevon_max_deflection;
elevons_param.elevon_gain = elevon_gain;
elevons_param.elevator_control = elevator_control;
elevons_param.aileron_control = aileron_control;
elevons_param.P_cs_mat = P_cs_mat;
elevons_param.CM_nom = CM_nom;
elevons_param.k_CM = k_CM;

sim_param.elevons_param = elevons_param;

ini_delta_alpha = [0;0];

%% initial conditions
% initial conditions
ini_Rcm_o = gnd_station;
ini_Rcm_o(3) = set_alti;

ini_O_Vcm_o = [0;0;0.0];
ini_O_Vcm_o(1) = 0;
ini_pitch = 1*set_pitch;

ini_euler_ang = [0;ini_pitch;0];
ini_OwB = [0;0;0];
ini_platform_ang = 0;
ini_platform_vel = 0;

X0_partial = cat(1,ini_Rcm_o,ini_O_Vcm_o,ini_euler_ang,ini_OwB,ini_platform_ang,ini_platform_vel,gnd_station);

node_locations = intermediate_nodes(R21_g,R2n_cm,N,X0_partial);

ini_R2i_o = node_locations.tether_2_nodes;

% initial node velocities
ini_O_V2i_o = zeros(size(ini_R2i_o));

%% initial unstretched length and spring stiffness calculations
% initial unstrected length
ul2 = norm(ini_R2i_o(end-2:end,1) - ini_R2i_o(1:3,1));

unstretched_l = ul2;

% initial tether masses
tether_volumes = ((pi/4).*tether_diameter.^2).*unstretched_l;
tether_masses = tether_density*tether_volumes;

full_length_stiff = tether_youngs*(tether_CS.*[1/unstretched_l]);

% full length damping coeff
full_length_d_coeff = damping_ratio*(2*sqrt(full_length_stiff*mass));

% tether spring stiffness
spring_stiffness = full_length_stiff*(N-1);

% estimate intial slack/tension
% ini_elongation = calc_ini_tension(F_buoy,mass,pcl_mw,ini_pitch,env_param,flow,Sref,full_length_stiff,tether_masses,N);
ini_elongation = calc_ini_tension(F_buoy,mass,ini_euler_ang,ini_delta_alpha,sim_param,flow,ini_O_Vcm_o,ini_Rcm_o,full_length_stiff,tether_masses,N);
added_elongation = 0;

unstretched_l = unstretched_l - ini_elongation - added_elongation;

% tether damping coeff
damping_coeff = full_length_d_coeff*(N-1);

% store in structure
ini_tether_chars.unstretched_l = unstretched_l;
ini_tether_chars.tether_volumes = tether_volumes;
ini_tether_chars.tether_masses = tether_masses;
ini_tether_chars.full_length_stiff = full_length_stiff;
ini_tether_chars.spring_stiffness = spring_stiffness;
ini_tether_chars.full_length_d_coeff = full_length_d_coeff;
ini_tether_chars.damping_coeff = damping_coeff;


%% simulation parameters constants
sim_param.tether_imp_nodes = tether_imp_nodes;
sim_param.platform_param = platform_param;
sim_param.controller_param = controller_param;


%% ode
X0 = cat(1,ini_Rcm_o,ini_O_Vcm_o,ini_euler_ang,ini_OwB,ini_platform_ang,ini_platform_vel,...
    ini_R2i_o,ini_O_V2i_o);


%% simulate
keyboard

sim('OCT_array_ready')

multinode_postprocess

%% zenith angle
BF = sim_param.geom_param.buoy_factor;
turbine_dia = sim_param.turbine_param.d_turbine;
sim_time_hr = time(end)/3600;
min_z = min(s_Rcm_o(3,:));
z_ss = s_Rcm_o(3,end);
x_ss = s_Rcm_o(1,end);

check_steps = 5;

for i1 = check_steps:-1:0
    check_ss(check_steps+1-i1) = norm(s_O_Vcm_o(:,end-i1));
    check_flag(check_steps+1-i1) = norm(s_O_Vcm_o(:,end-i1)) < 0.02;
    check_ss_t(check_steps+1-i1) = time(end-i1) - time(end-check_steps);
end

if sum(check_flag) < (check_steps+1)
    reaches_ss = "no";
else
    reaches_ss = "yes";
end


phi_z = (180/pi)*atan(s_Rcm_o(1,end)/s_Rcm_o(3,end));

