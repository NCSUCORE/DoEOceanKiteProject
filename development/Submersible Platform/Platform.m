clear; clc; format compact; close all

% Set parameters
% Masses
V = 9; %volume of platform
Vs = 4.5; %volume of sprung mass
rhom = 200; %density of floating platform
rhos = 1100; %density of sprung mass
ms = Vs*rhos; %mass of sprung mass
m = V*rhom; %mass of floating platform
D = 2; %geometry of platform
% Environmental Properties
rho = 1000; %water density
g = 9.81; %gravity
h = 100; %water depth
gamma = rho*g; %specific weight
H = 1.5; %wave aplitude
lambda = 11; %wavelength
kk = 2*pi/lambda; %wavenumber
% Tether Properties (2 tethers)
lz = h-15; %height of unstretched tether
xy = 50; %hypotenuse of unstretched tether in xy-plane
tetherE = 1*3.8e9; %tether Young's Modulus
tetherDiam = .055; %tether diameter
tetherUnstretched = sqrt(lz^2+xy^2);
tetherk = tetherE*(pi/4*tetherDiam^2)/tetherUnstretched; %tether spring constant
zeta = 0.05;
tetherb = 200*(tetherDiam./0.01).^2; %tether damping constant
% Spring - Damper System
E = 200e9; %Young's Modulus of Steel
lus = 18; %unstretched spring length
A = D^2*pi/4;
k = E*A/lus;
b = zeta*(2*sqrt(k*ms));

% Create Class
system_param.k = k;
system_param.b = b;
system_param.lus = lus;
system_param.lz = lz;
system_param.ms = ms;
system_param.g = g;
system_param.m = m;
system_param.rho = rho;
system_param.V = V;
system_param.h = h;
system_param.D = D;
system_param.H = H;
system_param.gamma = gamma;
system_param.Vs = Vs;

% Initial Positions
initialR_s = [0;0;lz+lus+1e-5];
initialR_m = [0;0;lz];
initialV_s = [0;0;0];
initialV_m = [0;0;1e-18];

initial_x0 = cat(1,initialR_s,initialR_m,initialV_s,initialV_m);

% Set Forces
Tperiod = 10;
Cm = 1.5;
Cd = 0.7;


T = [0;0;0];

%%
clc
tsim = 10;
sim('HighLevelPlatform')

%%
close all;clc

Sx = Sr.Data(:,1);
Sy = Sr.Data(:,2);
Sz = Sr.Data(:,3);
Mx = Mr.Data(:,1);
My = Mr.Data(:,2);
Mz = Mr.Data(:,3);

fn = 1;
figure(fn)
plot(Sr.Time,Sx,Mr.Time,Mx)
title('Position of Landing Platform vs. Position of Buoyant Platform')
xlabel('Time (s)')
ylabel('x Position (m)')
legend('Landing Platform','Buoyant Platform')
fn = fn+1;
figure(fn)
plot(Sr.Time,Sy,Mr.Time,My)
title('Position of Landing Platform vs. Position of Buoyant Platform')
xlabel('Time (s)')
ylabel('y Position (m)')
legend('Landing Platform','Buoyant Platform')
fn = fn+1;
figure(fn)
plot(Sr.Time,Sz,Mr.Time,Mz)
title('Position of Landing Platform vs. Position of Buoyant Platform')
xlabel('Time (s)')
ylabel('z Position (m)')
legend('Landing Platform','Buoyant Platform')
%%
% for i = 1:60*10
%     plot3(Sx(i),Sy(i),Sz(i),'b*')
%     ylim([-1e-8,1e-8])
%     hold on
%     plot3(Mx(i),My(i),Mz(i),'r*')
%     hold off
%     pause(.001)
% end
% 
% %%
% clc;close all
% for i = 1:631
%     plot(Sy(i),Sz(i),'b*')
%     if i == 1
%         pause(4)
%     end
%     title(['t=',num2str(Sr.time(i))])
%     ylim([80,95])
%     xlim([-.2e-6,.2e-6])
%     hold on
%     plot(My(i),Mz(i),'r*')
%     plot([My(i),Sy(i)],[Mz(i),Sz(i)],'k')
%     hold off
%     t = Sr.time(i+1)-Sr.time(i);
%     pause(t)
% end
% %%
% tsim = [0 20];
% sol = ode45(@(t,x) sprungODE(t,x,system_param,T,Fol,Foh,T1,T2),tsim,initial_x0);
% 
% %% plots
% time = sol.x';
% x_sol = sol.y;
% 
% s_Rso = x_sol(1:3,:);
% s_Rmo = x_sol(4:6,:);
% s_Vso = x_sol(7:9,:);
% s_Vmo = x_sol(10:12,:);
% 
% % figures
% fn = 1;
% ld = 0.75;
% colors = (1/255)*[228,26,28; 55,126,184; 77,175,74; 152,78,163; 255,127,0];
% 
% figure(fn);
% prs1 = plot(time,s_Rso(1,:),'Linewidth',ld,'color',colors(1,:));
% hold on
% prs2 = plot(time,s_Rso(2,:),'Linewidth',ld,'color',colors(2,:));
% prs3 = plot(time,s_Rso(3,:),'Linewidth',ld,'color',colors(3,:));
% 
% grid on
% xlabel('time')
% ylabel('position')
% legend('z','x','y')
% 
% fn = fn+1;
% figure(fn);
% prm1 = plot(time,s_Rmo(1,:),'Linewidth',ld,'color',colors(1,:));
% hold on
% prm2 = plot(time,s_Rmo(2,:),'Linewidth',ld,'color',colors(2,:));
% prm3 = plot(time,s_Rmo(3,:),'Linewidth',ld,'color',colors(3,:));
% 
% grid on
% xlabel('time')
% ylabel('position')
% legend('x','y','z')



