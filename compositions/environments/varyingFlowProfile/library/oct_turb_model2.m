% code to recreate turbulence model as per the following paper
% 'Numerical modeling of turbulence and its effect on ocean current
% turbines' by parakram pyakurel

%% clear
clc
clear
format compact
% close all

make_video = 1;

%% input parameters
% U_mean = 1.6;                                       % mean velocity (m/s)
TI =  0.1;                                         % turbulence intensity (%)
f_min = 0.01;                                       % minimum frequency associated with TI
f_max = 1;                                          % max frequency associated with TI
P = 0.1;                                            % factor defining relation between standard devs of velocity components u and v
Q = 0.1;                                            % same as above but for u and w
C = 5;                                              % along flwo coherence deacy constant
N_mid_freq = 5;                                           % number of frequency discretizations

% stamp time
clk_stamp = clock;
date_time = datetime(clk_stamp);

fid = fopen( 'code_completion_flag.txt', 'w' );
fprintf( fid, 'Turbulent inlet plane generation started on %s \n \n',date_time);
fclose(fid);

% create grid in the Y-Z plane
y = 0:1:10;
z = 140:5:200;

[Y,Z] = meshgrid(y,z);
X = zeros(size(Y));

y_pos = NaN(numel(Y),1);
z_pos = NaN(numel(Z),1);

n_elem = numel(Y);

for i = 1:n_elem
    y_pos(i) = Y(i);
    z_pos(i) = Z(i);
end
    
pos_data = [y_pos z_pos];

U_mean = 1.4*ones(n_elem,1);

turb_param = turbulence_generator2(0,U_mean,TI,f_min,f_max,P,Q,C,N_mid_freq,pos_data);
 
u_star_kj = turb_param.u_star_kj;
u_th_kR = turb_param.u_th_kR;
v_star_kj = turb_param.v_star_kj;
v_th_kR = turb_param.v_th_kR;
w_star_kj = turb_param.w_star_kj;
w_th_kR = turb_param.w_th_kR;
ff = turb_param.ff;

clk_stamp = clock;
date_time = datetime(clk_stamp);

fid = fopen( 'code_completion_flag.txt', 'a' );
fprintf( fid, 'Turbulent inlet plane generation completed on %s \n \n',date_time);
fclose(fid);

save('turb_data');

fid = fopen( 'code_completion_flag.txt', 'a' );
fprintf( fid, 'Data saved successfully to file turb_data.mat \n');
fclose(fid);

%% post process
% Time
timeStep = 0.25;
tf = 60;

time = 0:timeStep:tf;
n_steps = length(time);

% pre-allocation
uf_int = NaN(1,N_mid_freq);
vf_int = NaN(1,N_mid_freq);
wf_int = NaN(1,N_mid_freq);

uf = NaN(n_elem,n_steps);
vf = NaN(n_elem,n_steps);
wf = NaN(n_elem,n_steps);

% calculation
for i = 1:n_steps
    
    for j = 1:n_elem
        for k = 1:N_mid_freq
            uf_int(1,k) = abs(u_star_kj(j,k))*sin(2*pi*ff(k)*time(i) + u_th_kR(j,k));
            vf_int(1,k) = abs(v_star_kj(j,k))*sin(2*pi*ff(k)*time(i) + v_th_kR(j,k));
            wf_int(1,k) = abs(w_star_kj(j,k))*sin(2*pi*ff(k)*time(i) + w_th_kR(j,k));
            
        end
        
        uf(j,i) = sum(uf_int(1,:));
        vf(j,i) = sum(vf_int(1,:));
        wf(j,i) = sum(wf_int(1,:));
        
    end
    
end

% superimpose on actual flow
U_f = NaN(length(U_mean),n_steps);
V_f = NaN(length(U_mean),n_steps);
W_f = NaN(length(U_mean),n_steps);

for i = 1:n_steps
    
U_f(:,i) = U_mean + uf(:,i);
V_f(:,i) = vf(:,i);
W_f(:,i) = wf(:,i);

end

%% stop code if generating turbulence along a line
if length(y) == 1 || length(z) == 1
    return
end

% arrange in grid
U_f_grid = NaN([size(Y) n_steps]);
V_f_grid = NaN([size(Y) n_steps]);
W_f_grid = NaN([size(Y) n_steps]);

U_f_grid_int = NaN(size(Y));
V_f_grid_int = NaN(size(Y));
W_f_grid_int = NaN(size(Y));

for j = 1:n_steps
    
    for i = 1:n_elem
        
        U_f_grid_int(i) = U_f(i,j);
        V_f_grid_int(i) = V_f(i,j);
        W_f_grid_int(i) = W_f(i,j);
        
    end
    
    U_f_grid(:,:,j) =  U_f_grid_int(:,:);
    V_f_grid(:,:,j) =  V_f_grid_int(:,:);
    W_f_grid(:,:,j) =  W_f_grid_int(:,:);
    
end

%% color map plot
colormap(jet);

frame_rate = 2*1/timeStep;
video = VideoWriter('vid_Test', 'Motion JPEG AVI');
video.FrameRate = frame_rate; 
num_frames = n_steps;

mov(1:n_steps)=struct('cdata',[],'colormap',[]);  
set(gca,'nextplot','replacechildren')

for i = 1:n_steps
    
    figure(1)
    colormap(jet);
    contourf(Y,Z,U_f_grid(:,:,i))
    
    caxis([1.2 1.7])
    colorbar
%     ('Ticks',1:0.2:1.8)
    
    xlabel('Y (m)')
    ylabel('Z (m)')
    title(['Turbulent flow at inlet plane. Time = ',sprintf('%0.2f', time(i)),' s'])
    
    F(i) = getframe(gcf);
    
end

if make_video == 1
    open(video)
    for i = 1:length(F)
        writeVideo(video, F(i));
    end
    close(video)
end


