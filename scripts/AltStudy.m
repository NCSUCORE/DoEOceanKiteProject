%%  Consolidate Results 
Sim = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Alt Study\AltStudy_1-5_20kN.mat');
Simb = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Alt Study\AltStudy_1-5d_post.mat');
%%
R.Pmax(6:20,:) = Sim.R.Pmax(:,:);
R.alpha(6:20,:) = Sim.R.alpha(:,:);
R.CD(6:20,:) = Sim.R.CD(:,:);
R.CL(6:20,:) = Sim.R.CL(:,:);
R.EL(6:20,:) = Sim.R.EL(:,:);
R.ten(6:20,:) = Sim.R.ten(:,:);
R.thrL(6:20,:) = Sim.R.thrL(:,:);
R.Fdrag(6:20,:) = Sim.R.Fdrag(:,:);
R.Ffuse(6:20,:) = Sim.R.Ffuse(:,:);
R.Flift(6:20,:) = Sim.R.Flift(:,:);
R.Fthr(6:20,:) = Sim.R.Fthr(:,:);
R.Fturb(6:20,:) = Sim.R.Fturb(:,:);
flwSpd = [Simb.flwSpd Sim.flwSpd];
A = Sim.A;
altitude = Sim.altitude;
thrLength = Sim.thrLength;
%%  Alt Study 
load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\vehicleDesign\Tether\tetherData.mat')
depth = [300 250 200];
Tmax = 38; 
% eff = eval(sprintf('AR8b8.length600.tensionValues%d.efficencyPercent',Tmax))/100;
eff = 0.92;

% load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Alt Study\Alt_Study_1-5_Tmax-20.mat')
%%  Apply Tension Limit 
for kk = 1:numel(flwSpd)
    for ii = 1:numel(thrLength)
        for jj = 1:numel(altitude)
            for ll = 1:numel(A)
                if ten(ii,jj,kk,ll) > Tmax
                    Pavg(ii,jj,kk,ll) = NaN;
                end
            end
            if ~isnan(max(Pavg(ii,jj,kk,:)))
                idx = find(Pavg(ii,jj,kk,:)==max(Pavg(ii,jj,kk,:)));
                Pmax(ii,jj,kk) = Pavg(ii,jj,kk,idx);
                alpha(ii,jj,kk) = AoA(ii,jj,kk,idx);
                CD1(ii,jj,kk) = CD(ii,jj,kk,idx);
                CL1(ii,jj,kk) = CL(ii,jj,kk,idx);
                EL(ii,jj,kk) = elevation(ii,jj,kk,idx);
                Ten(ii,jj,kk) = ten(ii,jj,kk,idx);
                F_drag(ii,jj,kk) = Fdrag(ii,jj,kk,idx);
                F_fuse(ii,jj,kk) = Ffuse(ii,jj,kk,idx);
                F_lift(ii,jj,kk) = Flift(ii,jj,kk,idx);
                F_thr(ii,jj,kk) = Fthr(ii,jj,kk,idx);
                F_turb(ii,jj,kk) = Fturb(ii,jj,kk,idx);
            else
                Pmax(ii,jj,kk) = NaN;
                CD1(ii,jj,kk) = NaN;
                CL1(ii,jj,kk) = NaN;
                EL(ii,jj,kk) = NaN;
                Ten(ii,jj,kk) = NaN;
                F_drag(ii,jj,kk) = NaN;
                F_fuse(ii,jj,kk) = NaN;
                F_lift(ii,jj,kk) = NaN;
                F_thr(ii,jj,kk) = NaN;
                F_turb(ii,jj,kk) = NaN;
            end
        end
    end
end
%%  Reassign variables 
for i = 1:numel(flwSpd)
    for j = 1:numel(altitude)
        if ~isnan(max(Pmax(:,j,i)))
            idx1 = find(Pmax(:,j,i)==max(Pmax(:,j,i)));
            R.Pmax(i,j) = Pmax(idx1,j,i);
            R.alpha(i,j) = alpha(idx1,j,i);
            R.CD(i,j) = CD1(idx1,j,i);
            R.CL(i,j) = CL1(idx1,j,i);
            R.EL(i,j) = EL(idx1,j,i);
            R.ten(i,j) = Ten(idx1,j,i);
            R.thrL(i,j) = thrLength(idx1);
            R.Fdrag(i,j) = F_drag(idx1,j,i);
            R.Ffuse(i,j) = F_fuse(idx1,j,i);
            R.Flift(i,j) = F_lift(idx1,j,i);
            R.Fthr(i,j) = F_thr(idx1,j,i);
            R.Fturb(i,j) = F_turb(idx1,j,i);
        else
            R.Pmax(i,j) = NaN;
            R.CD(i,j) = NaN;
            R.CL(i,j) = NaN;
            R.EL(i,j) = NaN;
            R.ten(i,j) = NaN;
            R.thrL(i,j) = NaN;
            R.Fdrag(i,j) = NaN;
            R.Ffuse(i,j) = NaN;
            R.Flift(i,j) = NaN;
            R.Fthr(i,j) = NaN;
            R.Fturb(i,j) = NaN;
        end
    end
end
R.Pmax1 = R.Pmax*eff;
%%  Fit Cubic Curve
% effR = [0.8 0.7];                                   %   AR = 9; b = 10
% for k = 1:numel(depth)
%     eff = interp1(tLength,effR,thrL(1,k));
%     Index = find(Pmax(:,k)~=0);
%     p(:,k) = polyfit(flwSpd(Index),Pmax(Index,k)*eff,3)';
% end
%%  Plotting 
figure; 
for alt = 1:6
    subplot(3,2,1); hold on; grid on
    plot(flwSpd,R.Pmax(:,alt)*eff);  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Power [kW]');  xlim([.1 0.5]);
    subplot(3,2,6); hold on; grid on
    plot(flwSpd,R.alpha(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('AoA [deg]');  xlim([.1 0.5]);
    subplot(3,2,3); hold on; grid on
    plot(flwSpd,R.ten(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Tension [kN]');  xlim([.1 0.5]);
    if alt == 6
        plot(flwSpd,Tmax*ones(1,numel(flwSpd)),'k--')
    end
    legend('Alt = 50 m','Alt = 100 m','Alt = 150 m','Alt = 200 m','Alt = 250 m','Alt = 300 m','Max Tension')
    subplot(3,2,2); hold on; grid on
    plot(flwSpd,R.thrL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Tether [m]');  xlim([.1 0.5]);
    subplot(3,2,4); hold on; grid on
    plot(flwSpd,R.EL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Elevation [deg]');  xlim([.1 0.5]);
end
%%
figure; subplot(2,2,1); hold on; grid on
a = contourf(altitude,flwSpd,R.Pmax,20,'edgecolor','none');  
xlabel('Altitude [m]');  ylabel('$V_\mathrm{flow}$ [m/s]');  title('Power at Kite [kW]');  colorbar
subplot(2,2,3); hold on; grid on
a = contourf(altitude,flwSpd,R.Pmax*eff,20,'edgecolor','none');  
xlabel('Altitude [m]');  ylabel('$V_\mathrm{flow}$ [m/s]');  title('Power at Glider [kW]');  colorbar
subplot(2,2,2); hold on; grid on
a = contourf(altitude,flwSpd,R.thrL,20,'edgecolor','none');  
xlabel('Altitude [m]');  ylabel('$V_\mathrm{flow}$ [m/s]');  title('Optimal Tether Length [m]');  colorbar
subplot(2,2,4); hold on; grid on
a = contourf(altitude,flwSpd,R.EL,20,'edgecolor','none');  
xlabel('Altitude [m]');  ylabel('$V_\mathrm{flow}$ [m/s]');  title('Optimal Elevation Angle [deg]');  colorbar
%%
fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Alt Study\');
save([fpath,'AltStudy_1-5_38kN.mat'],'flwSpd','altitude','A','thrLength','R','Tmax','depth','eff');
% save([fpath,'AltStudy_1-5d_post.mat'],'flwSpd','altitude','A','thrLength','R','Tmax','depth');
%%
T20 = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Alt Study\AltStudy_1-5_20kN.mat');
T38 = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Alt Study\AltStudy_1-5_38kN.mat');
T80 = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Alt Study\AltStudy_1-5_80kN.mat');
figure; 
for alt = 1:6
%     a1 = subplot(3,1,1); hold on; grid on
%     plot(T20.flwSpd,T20.R.Pmax(:,alt)*T20.eff);  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Power [kW]');  xlim([.1 0.5]);
%     a2 = subplot(3,1,2); hold on; grid on
%     plot(T38.flwSpd,T38.R.Pmax(:,alt)*T38.eff);  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Power [kW]');  xlim([.1 0.5]);
    a3 = subplot(1,1,1); hold on; grid on
    plot(T80.flwSpd,T80.R.Pmax(:,alt)*T80.eff);  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Power [kW]');  xlim([.1 0.5]);
    if alt == 6
        legend('Alt = 50 m','Alt = 100 m','Alt = 150 m','Alt = 200 m','Alt = 250 m','Alt = 300 m','location','northwest')
    end
end






