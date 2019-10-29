function obj =  process(obj)
% function to generate turbGrid.mat
% Called as a method of ENV.constX_YZvarT_CNAPSTurb
val = obj.flowVecTSeries.Value;
valData = permute(val.data, [3,1,2]);
sZ = size(valData);
magDepth = [];
for ii = 1:sZ(3)
    magDepthT = sqrt( sum(valData(:,:,ii).^2,2));
    
    %magnitude of xyz at each depth per time
    magDepth = [magDepth,magDepthT];
end
hourInterval = ceil(val.Time(end)/3600);
% create grid in the Y-Z plane
y = obj.yBreakPoints.Value;
% z = 140:5:200;% only for testing
z = obj.depthArray.Value;
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
U_mean = [];
% calculate turbulence parameters at each time
% 10 minute interval
for iii = 1:hourInterval
    for j  = 1:length(y)
        U_meanTemp = magDepth(iii,:)';
        U_mean =  [U_mean;U_meanTemp];
    end
    turb_param = obj.turbulence_generator2(U_mean,...
        obj.TI.Value,obj.f_min.Value,obj.f_max.Value,...
        obj.P.Value,obj.Q.Value,obj.C.Value,...
        obj.N_mid_freq.Value,pos_data);
    u_star_kj(:,:,iii) = turb_param.u_star_kj;
    u_th_kR(:,:,iii)   = turb_param.u_th_kR;
    v_star_kj(:,:,iii) = turb_param.v_star_kj;
    v_th_kR(:,:,iii)   = turb_param.v_th_kR;
    w_star_kj(:,:,iii) = turb_param.w_star_kj;
    w_th_kR(:,:,iii)   = turb_param.w_th_kR;
    ff(:,:,iii)        = turb_param.ff;
    U_mean = [];
end
clk_stamp = clock;
date_time = datetime(clk_stamp);
fid = fopen( 'code_completion_flag.txt', 'a' );
fprintf( fid, 'Turbulent inlet plane generation completed on %s \n \n',date_time);
fclose(fid);
save('turb_data');
fid = fopen( 'code_completion_flag.txt', 'a' );
fprintf( fid, 'Data saved successfully to file turb_data.mat \n');
fclose(fid)

%% Post Process
% Time
timeStep = 1;
tf = 3600;
time = 1:timeStep:tf;
n_steps = length(time);
% pre-allocation
U_f_grid = NaN([size(Y) n_steps]);
V_f_grid = NaN([size(Y) n_steps]);
W_f_grid = NaN([size(Y) n_steps]);
for ip = 1:hourInterval
    % pre-allocation
    uf_int = NaN(1,obj.N_mid_freq.Value);
    vf_int = NaN(1,obj.N_mid_freq.Value);
    wf_int = NaN(1,obj.N_mid_freq.Value);
    uf = NaN(n_elem,n_steps);
    vf = NaN(n_elem,n_steps);
    wf = NaN(n_elem,n_steps);
    % calculation
    for i = 1:n_steps
        for j = 1:n_elem
            for k = 1:obj.N_mid_freq.Value
                uf_int(1,k) = abs(u_star_kj(j,k,ip))*sin(2*pi*ff(k,:,ip)*time(i) + u_th_kR(j,k,ip));
                vf_int(1,k) = abs(v_star_kj(j,k,ip))*sin(2*pi*ff(k,:,ip)*time(i) + v_th_kR(j,k,ip));
                wf_int(1,k) = abs(w_star_kj(j,k,ip))*sin(2*pi*ff(k,:,ip)*time(i) + w_th_kR(j,k,ip));
            end
            uf(j,i) = sum(uf_int(1,:));
            vf(j,i) = sum(vf_int(1,:));
            wf(j,i) = sum(wf_int(1,:));
        end
    end
    % superimpose on actual flow
    U_f = NaN(n_elem,n_steps);
    V_f = NaN(n_elem,n_steps);
    W_f = NaN(n_elem,n_steps);
    %rewrite this portion ???????????????????????-MC???
    for i = 1:n_steps
        U_f(:,i) = uf(:,i);
        V_f(:,i) = vf(:,i);
        W_f(:,i) = wf(:,i);
    end
    %%%%%%%%%%%%%%%%%%%%% stop code if generating turbulence along a line
    if length(y) == 1 || length(z) == 1
        return
    end
    U_f_grid_int = NaN(size(Y));
    V_f_grid_int = NaN(size(Y));
    W_f_grid_int = NaN(size(Y));
    for j = 1:n_steps
        for i = 1:n_elem
            U_f_grid_int(i) = U_f(i,j);
            V_f_grid_int(i) = V_f(i,j);
            W_f_grid_int(i) = W_f(i,j);
        end
        U_f_grid(:,:,j,ip) =  U_f_grid_int(:,:);
        V_f_grid(:,:,j,ip) =  V_f_grid_int(:,:);
        W_f_grid(:,:,j,ip) =  W_f_grid_int(:,:);
    end
end
U_f_gridInt1 = NaN(size(U_f_grid(:,:,:,1)));
V_f_gridInt1 = NaN(size(V_f_grid(:,:,:,1)));
W_f_gridInt1 = NaN(size(W_f_grid(:,:,:,1)));
for ip = 1:hourInterval
    %concatination on the thrid dimension per ten minute interval
    U_f_gridInt1 = cat(3,U_f_gridInt1,U_f_grid(:,:,:,ip));
    V_f_gridInt1 = cat(3,V_f_gridInt1,V_f_grid(:,:,:,ip));
    W_f_gridInt1 = cat(3,W_f_gridInt1,W_f_grid(:,:,:,ip));
end
% grabbing all of the third dimension except ,10 minutes*60 = seconds
% + 1 for time zero
%did this a weird way to concatenate variable sizes in three
%dimensions
U_f_gridFinished = U_f_gridInt1(:,:,3601:end);
V_f_gridFinished = V_f_gridInt1(:,:,3601:end);
W_f_gridFinished = W_f_gridInt1(:,:,3601:end);
filePath = fullfile(fileparts(which('OCTProject.prj')),...
    'classes','+ENV','@constX_YZvarT_ADCPMUGLIATurb','turbGrid3.mat');
save(filePath,'U_f_gridFinished','V_f_gridFinished','W_f_gridFinished','y')

save('TurbMugData.mat', 'U_f_gridFinished','V_f_gridFinished','W_f_gridFinished','y', '-v7.3')
end