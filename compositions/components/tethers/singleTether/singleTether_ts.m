
clear
format compact

ini_Rn_o = [0 0 100]';
ini_R1_o = [0 0 0]';

amp = 10;
omega = 1;
sim_time = 10;

Rn_o = [0 0 100]';
Vn_o = [0 0 0]';
R1_o = [0 0 0]';
V1_o = [0 0 0]';

sim_param.N = 2;
N = sim_param.N;

Ri_o =  zeros(3,N-2);

g = 9.81;
mass = 100;
dia_t = 0.05;
E = 3.8e9;
zeta = 0.05;
rho_fluid = 1000;
rho_tether = 1300;
Cd = 0.5;
flow = [1 0 0]';
L = 100;

m_i = 2;

for ii = 2:N-1
    Ri_o(:,ii-1) = (Rn_o - R1_o)*(ii-1)/(N-1);
    
end

Ri_o = [R1_o Ri_o Rn_o];
Vi_o = zeros(size(Ri_o));

ini_Ri_o = Ri_o;
ini_Vi_o = zeros(size(Vi_o));

dt = 1/1000;

if N == 2
    sim('sinlgeTetherNEqual2_th')
else
    sim('sinlgeTetherNGreater2_th')
end

%% post process
%% colors
red = 1/255*[228,26,28];
blue = 1/255*[55,126,184];
green = 1/255*[77,175,74];
purple = 1/255*[152,78,163];

line_wd = 0.75;


tsc = parseLogsout;
time =  tsc.Ri_o.Time;
sol_Ri_o = tsc.Ri_o.Data;

s_R = cell(N,1);


for jj = 1:N
    for ii = 1:length(time)
        s_R_int(ii,:) =  sol_Ri_o(:,jj,ii)';
    end
    s_R{jj} =  s_R_int;
end

s_Rn_o = s_R{end};
s_R1_o = s_R{1};

%% make movie
movie_frame_rate = 50;
skip_step = (1/dt)/movie_frame_rate;
t_steps = length(time);

t_f = time(end);

n_step_idx = 1:skip_step:t_steps;
n_steps = length(n_step_idx);
t_snap = time(n_step_idx);

% video setting
video = VideoWriter('vid_Test', 'Motion JPEG AVI');
video.FrameRate = movie_frame_rate;
num_frames = n_steps;

mov(1:n_steps)=struct('cdata',[],'colormap',[]);
set(gca,'nextplot','replacechildren')

% separate x,y and z cordinates
p3x = NaN(N,n_steps);
p3y = NaN(N,n_steps);
p3z = NaN(N,n_steps);


for jj = 1:N
    int_p1 = s_R{jj};
    p3x(jj,:) = int_p1(n_step_idx,1)';
    p3y(jj,:) = int_p1(n_step_idx,2)';
    p3z(jj,:) = int_p1(n_step_idx,3)';
end

[Sx,Lx] = bounds(p3x,'all');
Sx = Sx(1); Lx = Lx(1);
[Sy,Ly] = bounds(p3y,'all');
Sy = Sy(1)-1; Ly = Ly(1)+1;
[Sz,Lz] = bounds(p3z,'all');
Sz = Sz(1); Lz = Lz(1);

% axis square
% axis equal

for ii = 1:n_steps
    
    figure(1)
    
    if ii > 1
        delete(p3d_1)
    end
    
    p3d_1 = plot3(p3x(:,ii),p3y(:,ii),p3z(:,ii),'-+','color',red);
    hold on
    grid on
    
    if ii == 1
        xlabel('Y (m)')
        ylabel('Y (m)')
        zlabel('Z (m)')
        
        xlim([Sx Lx]);
        ylim([Sy Ly]);
        zlim([Sz Lz]);
        
    end
    
    title(['Time = ',sprintf('%0.2f', t_snap(ii)),' s'])
    
    F(ii) = getframe(gcf);
    
    
end

open(video)
for ii = 1:length(F)
    writeVideo(video, F(ii));
end
close(video)









