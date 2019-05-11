
% multinode tether solution postprocessing
% <v1.1> <Ayaz Siddiqui> <1/27/2019>

%% clear
% clc
format compact
% close all

% switch to overwrite/clear figures: 1=clear figs,0=dont clear
clf_switch = 1;

% number of snapshots for catinary gemetry plot
n_snap = 20;

%% extract data from simulink files
X_sol = sol_states.Data';
time = sol_states.Time;

s_unstretched_l = sol_unstretched_l.Data';
s_elevon_def = sol_elevon_def.Data';
s_flow = sol_flow.Data';

% number of steps
n_steps = length(time);

%% separate state vectors
s_Rcm_o = X_sol(1:3,:);
s_O_Vcm_o = X_sol(4:6,:);
s_euler_ang = X_sol(7:9,:);
s_OwB = X_sol(10:12,:);
s_platform_ang = X_sol(13,:);
s_platform_vel = X_sol(14,:);

s_R1i_o = X_sol(15:(14 + 3*N),:);
s_R2i_o = X_sol((15 + 3*N):(14 + 6*N),:);
s_R3i_o = X_sol((15 + 6*N):(14 + 9*N),:);

s_O_V1i_o = X_sol((15 + 9*N):(14 + 12*N),:);
s_O_V2i_o = X_sol((15 + 12*N):(14 + 15*N),:);
s_O_V3i_o = X_sol((15 + 15*N):(14 + 18*N),:);

%% evaluate tension forces
% intialize matrices
s_O_F_ext = NaN(3,n_steps);
s_B_T_ext = NaN(3,n_steps);
s_T_o_ext = NaN(1,n_steps);

s_B_T_buoy = NaN(3,n_steps);
s_B_T_aero_mw = NaN(3,n_steps);
s_B_T_aero_VS = NaN(3,n_steps);
s_B_F_turb1 = NaN(3,n_steps);
s_gen_power = NaN(1,n_steps);

s_B_F_aero_mw = NaN(3,n_steps);
s_B_F_aero_VS = NaN(3,n_steps);
s_alpha_deg = NaN(1,n_steps);
s_beta_deg = NaN(1,n_steps);
s_B_Vrel = NaN(3,n_steps);

% secondary forces used for postprocessing
s_Ts1i = NaN(N-1,n_steps);
s_Ts2i = NaN(N-1,n_steps);
s_Ts3i = NaN(N-1,n_steps);
s_Td1i = NaN(N-1,n_steps);
s_Td2i = NaN(N-1,n_steps);
s_Td3i = NaN(N-1,n_steps);

s_aero_1i = NaN(1,n_steps);
s_aero_2i = NaN(1,n_steps);
s_aero_3i = NaN(1,n_steps);


for i = 1:n_steps
    op = multinode_F_and_T_external(sim_param,s_flow(:,i),s_unstretched_l(:,i),s_elevon_def(:,i),...
        s_Rcm_o(:,i),s_R1i_o(:,i),s_R2i_o(:,i),s_R3i_o(:,i),...
        s_O_Vcm_o(:,i),s_O_V1i_o(:,i),s_O_V2i_o(:,i),s_O_V3i_o(:,i),s_OwB(:,i),s_euler_ang(:,i),s_platform_ang(1,i));
    
    % store values
    s_O_F_ext(:,i) = op.O_F_ext;
    s_B_T_ext(:,i) = op.B_T_ext;
    s_T_o_ext(1,i) = op.T_o_ext;
    
    
    s_B_T_buoy(:,i) = op.B_T_buoy;
    s_B_T_aero_mw(:,i) = op.B_T_aero_mw;
    s_B_T_aero_VS(:,i) = op.B_T_aero_VS;

    
    s_Ts1i(:,i) = op.Ts1i;
    s_Ts2i(:,i) = op.Ts2i;
    s_Ts3i(:,i) = op.Ts3i;
    s_Td1i(:,i) = op.Td1i;
    s_Td2i(:,i) = op.Td2i;
    s_Td3i(:,i) = op.Td3i;
    
    s_aero_1i(:,i) = sum(op.aero_1i);
    s_aero_2i(:,i) = sum(op.aero_2i);
    s_aero_3i(:,i) = sum(op.aero_3i);

    % aerodynamic forces
    aero_F = op.aero_F;
    
    B_F_aero_mw = aero_F.B_F_aero_mw;
    B_F_aero_VS = aero_F.B_F_aero_VS;
    B_F_turb1 = aero_F.B_F_turb1;
    gen_power = aero_F.gen_power;

    alpha_deg = aero_F.alpha_deg;
    beta_deg = aero_F.beta_deg;
    B_Vrel = aero_F.B_Vrel;
    
    s_B_F_aero_mw(:,i) = B_F_aero_mw;
    s_B_F_aero_VS(:,i) = B_F_aero_VS;
    s_B_F_turb1(:,i) = B_F_turb1;
    s_gen_power(:,i) = gen_power;

    s_alpha_deg(:,i) = alpha_deg;
    s_beta_deg(:,i) = beta_deg;
    s_B_Vrel(:,i) = B_Vrel;
end

%% colors
red = 1/255*[228,26,28];
blue = 1/255*[55,126,184];
green = 1/255*[77,175,74];
purple = 1/255*[152,78,163];

line_wd = 0.75;

%% plotting results
% center of mass location and set point %%%%%%
fn = 1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_rcmx = plot(time./sqrt(k_scale),s_Rcm_o(1,:)./k_scale,'LineWidth',line_wd,'color',red);
hold on
p_rcmy = plot(time./sqrt(k_scale),s_Rcm_o(2,:)./k_scale,'LineWidth',line_wd,'color',blue);
p_rcmz = plot(time./sqrt(k_scale),s_Rcm_o(3,:)./k_scale,'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Position (m)')
legend('\it{x_{CM}}','\it{y_{CM}}','\it{z_{CM}}')
title('Center of mass position')
% set(gcf,'visible','off')

% CENTER OF MASS VELOCITY %%%%%%
fn = fn + 1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_vcmx = plot(time./sqrt(k_scale),s_O_Vcm_o(1,:)./sqrt(k_scale),'LineWidth',line_wd,'color',red);
hold on
p_vcmy = plot(time./sqrt(k_scale),s_O_Vcm_o(2,:)./sqrt(k_scale),'LineWidth',line_wd,'color',blue);
p_vcmz = plot(time./sqrt(k_scale),s_O_Vcm_o(3,:)./sqrt(k_scale),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Velocity (m/s)')
legend('\it{Vx_{CM}}','\it{Vy_{CM}}','\it{Vz_{CM}}')
title('Center of mass velocity')
% set(gcf,'visible','off')

% EULER ANGLES %%%%%%%%%%%%%%%%%%%%
fn = fn + 1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_yaw = plot(time./sqrt(k_scale),(180/pi)*s_euler_ang(1,:),'LineWidth',line_wd,'color',red);
hold on
p_pitch = plot(time./sqrt(k_scale),(180/pi)*s_euler_ang(2,:),'LineWidth',line_wd,'color',blue);
p_roll = plot(time./sqrt(k_scale),(180/pi)*s_euler_ang(3,:),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Angle (deg)')
legend('\it{roll}','\it{pitch}','\it{yaw}')
title('Euler angles')
% set(gcf,'visible','off')


%% FLOW SOLUTION
fn = fn + 1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_flowx = plot(time./sqrt(k_scale),s_flow(1,:),'LineWidth',line_wd,'color',red);
hold on
p_flowy = plot(time./sqrt(k_scale),s_flow(2,:),'LineWidth',line_wd,'color',blue);

grid on
xlabel('Time (sec)')
ylabel('\it{V_{\infty}} (m/s)')
legend('\it{V_{\infty x}}','\it{V_{\infty y}}')
title('Flow speed')
ylim([0 2.5])
% set(gcf,'visible','off')


%% INTERTIAL FORCES
% BODY FORCES %%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_f_ext_x = plot(time./sqrt(k_scale),s_O_F_ext(1,:),'LineWidth',line_wd,'color',red);
hold on
p_f_ext_y = plot(time./sqrt(k_scale),s_O_F_ext(2,:),'LineWidth',line_wd,'color',blue);
p_f_ext_z = plot(time./sqrt(k_scale),s_O_F_ext(3,:),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Force (N)')
legend('F_{x}','F_{y}','F_{z}')
title('External forces')
set(gcf,'visible','off')


% BODY FORCES ratio %%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_f_ratio = plot(time./sqrt(k_scale),s_O_F_ext(1,:)./s_O_F_ext(3,:),'LineWidth',line_wd,'color',red);
hold on

grid on
xlabel('Time (sec)')
ylabel('Force (N)')
legend('F_{x}/F_{z}')
title('ratio of Fx to Fz')
set(gcf,'visible','off')


%% AERODYNAMIC FORCES
% APPARRENT VELOCITY %%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_vrel_x = plot(time./sqrt(k_scale),s_B_Vrel(1,:),'LineWidth',line_wd,'color',red);
hold on
p_vrel_y = plot(time./sqrt(k_scale),s_B_Vrel(2,:),'LineWidth',line_wd,'color',blue);
p_vrel_z = plot(time./sqrt(k_scale),s_B_Vrel(3,:),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Velocity (N)')
legend('Vx','Vy','Vz')
title('Body frame relative velocity')
set(gcf,'visible','off')

% MAIN WING %%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_f_aero_mwx = plot(time./sqrt(k_scale),s_B_F_aero_mw(1,:),'LineWidth',line_wd,'color',red);
hold on
p_f_aero_mwy = plot(time./sqrt(k_scale),s_B_F_aero_mw(2,:),'LineWidth',line_wd,'color',blue);
p_f_aero_mwz = plot(time./sqrt(k_scale),s_B_F_aero_mw(3,:),'LineWidth',line_wd,'color',green);
p_f_turb = plot(time./sqrt(k_scale),2*s_B_F_turb1(1,:),'LineWidth',line_wd,'color',purple);

grid on
xlabel('Time (sec)')
ylabel('Force (N)')
legend('MW Drag','MW Side slip','MW Lift','Tot Turb drag')
title('Body frame Aerodynamic forces on Main Wing')
% set(gcf,'visible','off')

% VERTICAL STABILIZER %%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);


if clf_switch == 1
clf(figure(fn));
end
p_f_aero_VSx = plot(time./sqrt(k_scale),s_B_F_aero_VS(1,:),'LineWidth',line_wd,'color',red);
hold on
p_f_aero_VSy = plot(time./sqrt(k_scale),s_B_F_aero_VS(2,:),'LineWidth',line_wd,'color',blue);
p_f_aero_VSz = plot(time./sqrt(k_scale),s_B_F_aero_VS(3,:),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Force (N)')
legend('VS Drag','VS Lift','VS side slip')
title('Body frame Aerodynamic forces on VS')
set(gcf,'visible','off')

%% GENERATED POWER
% POWER %%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_gen_pow = plot(time./sqrt(k_scale),(1/1000)*s_gen_power(1,:),'LineWidth',line_wd,'color',red);
hold on

grid on
xlabel('Time (sec)')
ylabel('Power (kW)')
legend('Generated power')
title('Power')

ylim([0 120])
set(gcf,'visible','off')

%% external torques
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_t_x = plot(time./sqrt(k_scale),s_B_T_ext(1,:),'LineWidth',line_wd,'color',red);
hold on
p_t_y = plot(time./sqrt(k_scale),s_B_T_ext(2,:),'LineWidth',line_wd,'color',blue);
p_t_z = plot(time./sqrt(k_scale),s_B_T_ext(3,:),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Torque (N-m)')
legend('Tx','Ty','Tz')
title('Body frame External torques')
set(gcf,'visible','off')


% bouyancy and aerdynamic torques %%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_t_buoy_y = plot(time./sqrt(k_scale),s_B_T_buoy(2,:),'LineWidth',line_wd,'color',red);
hold on
p_t_aero_y = plot(time./sqrt(k_scale),s_B_T_aero_mw(2,:),'LineWidth',line_wd,'color',blue);
p_t_diff = plot(time./sqrt(k_scale),s_B_T_buoy(2,:)+s_B_T_aero_mw(2,:),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Torque (N-m)')
legend('T_{buoy}','T_{aero}')
title('Body frame buoyancy and aero torques')
set(gcf,'visible','off')


%% angle of attack and side slip angle
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_alp = plot(time./sqrt(k_scale),s_alpha_deg(1,:),'LineWidth',line_wd,'color',red);
hold on
p_beta= plot(time./sqrt(k_scale),s_beta_deg(1,:),'LineWidth',line_wd,'color',blue);

grid on
xlabel('Time (sec)')
ylabel('Angle (deg)')
legend('\alpha','\beta')
title('Aerodynamic angles')

set(gcf,'visible','off')


%% total tether hydrodynamic forces
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
p_aero1i = plot(time./sqrt(k_scale),s_aero_1i(1,:),'LineWidth',line_wd,'color',red);
hold on
p_aero2i= plot(time./sqrt(k_scale),s_aero_2i(1,:),'LineWidth',line_wd,'color',blue);
p_aero3i= plot(time./sqrt(k_scale),s_aero_3i(1,:),'LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Force (N)')
legend('T1','T2','T3')
title('Hydrodynamic forces in tethers')

set(gcf,'visible','off')



%% tether tension
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end
title('Tether tensions')
hold on

if mod(N-1,2) == 0
    sub_sz = (N-1)/2;
else
    sub_sz = N/2;
end

for i = 1:N-1
       
subplot(sub_sz,sub_sz,i)
p_t11 = plot(time./sqrt(k_scale),s_Ts1i(i,:),'LineWidth',line_wd,'color',red);
hold on
p_t21 = plot(time./sqrt(k_scale),s_Ts2i(i,:),'LineWidth',line_wd,'color',blue);
p_t31 = plot(time./sqrt(k_scale),s_Ts3i(i,:),'--','LineWidth',line_wd,'color',green);

grid on
xlabel('Time (sec)')
ylabel('Tension (N)')
title(['Tension in element number: ',num2str(i)])
legend('Tether 1','Tether 2','Tether 3')


end

% set(gcf,'visible','off')

%% tether catineary geometry
fn = fn+1;
figure(fn);

if clf_switch == 1
clf(figure(fn));
end

% time at which snaps are to be taken
nc = round((n_steps-1)/(n_snap-1));
nt = 1 + (1:n_snap-2)*nc;

nt = [1;nt';n_steps];

% time and position at snapshot times
snap_t = time(nt);

snap_R1i_o = s_R1i_o(:,nt);
snap_R2i_o = s_R2i_o(:,nt);
snap_R3i_o = s_R3i_o(:,nt);

% rearrange points in the format [X;Y;Z] for all points
p3x1 = NaN(N,n_snap); p3x2 = NaN(N,n_snap); p3x3 = NaN(N,n_snap);
p3y1 = NaN(N,n_snap); p3y2 = NaN(N,n_snap); p3y3 = NaN(N,n_snap);
p3z1 = NaN(N,n_snap); p3z2 = NaN(N,n_snap); p3z3 = NaN(N,n_snap);

for j = 1:n_snap
    for i = 1:N
        p3x1(i,j) = snap_R1i_o(3*i-2,j);
        p3x2(i,j) = snap_R2i_o(3*i-2,j);
        p3x3(i,j) = snap_R3i_o(3*i-2,j);
        
        p3y1(i,j) = snap_R1i_o(3*i-1,j);
        p3y2(i,j) = snap_R2i_o(3*i-1,j);
        p3y3(i,j) = snap_R3i_o(3*i-1,j);
        
        p3z1(i,j) = snap_R1i_o(3*i,j);
        p3z2(i,j) = snap_R2i_o(3*i,j);
        p3z3(i,j) = snap_R3i_o(3*i,j);
    end
end

% plot limits
limx = max(abs(s_Rcm_o(1,:)));
limy = max(abs(s_Rcm_o(2,:)));
limz = max(abs(s_Rcm_o(3,:)));

limx = limx - mod(limx,50) + 100;
limy = limy - mod(limy,50) + 100;
limz = limz - mod(limz,100) + 100;

for i = 1:n_snap
    
    if i > 1
        delete(p3d_1)
        delete(p3d_2)
        delete(p3d_3)
    end
        
    p3d_1 = plot3(p3x1(:,i),p3y1(:,i),p3z1(:,i),'-+','color',red);
    hold on
    p3d_2 = plot3(p3x2(:,i),p3y2(:,i),p3z2(:,i),'-+','color','black');
    p3d_3 = plot3(p3x3(:,i),p3y3(:,i),p3z3(:,i),'-+','color',blue);
    title(['Time = ',num2str(snap_t(i)),' sec'])
%     legend([p3d_1,p3d_2,p3d_3],{'Tether 1','Tether 2','Tether 3'})

    
    if i == 1
        % annotations
        
        grid on
        xlim([-limx limx])
        ylim([-limy limy])
        zlim([0 limz])
        
        xlabel('X (m)')
        ylabel('Y (m)')
        zlabel('Z (m)')
    end
    
    pause(0.2)
    
    
end



% fid = fopen( 'store_data.txt', 'w' );
% fprintf(fid, 'Turbulent inlet plane generation started on %s \n \n',date_time);
% fclose(fid);







