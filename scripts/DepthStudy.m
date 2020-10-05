%%  Depth Study 
thrLength = 400:25:600;                                 %   m - Initial tether length
flwSpd = 0.25:0.025:0.5;                                %   m/s - Flow speed
el = (30:5:60)*pi/180;                                  %   rad - Mean elevation angle
depth = [300 250 200 150 125 100];
%%  Get Important Results 
% fpath = 'D:\Results\';
% for kk = 1:numel(flwSpd)
%     for ii = 1:numel(thrLength)
%         for jj = 1:numel(el)
%             fprintf('kk = %d;\t ii = %d;\t jj = %d\n',kk,ii,jj)
%             filename = sprintf(strcat('Turb%.1f_V-%.3f_thrL-%d_el-%d.mat'),1.8,flwSpd(kk),thrLength(ii),el(jj)*180/pi);
%             load(strcat(fpath,filename))
%             [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
%             [CLtot,CDtot] = tsc.getCLCD(vhcl);
%             [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
%             Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
%             Pow = tsc.rotPowerSummary(vhcl,env);
%             Pavg(ii,jj,kk) = Pow.avg;
%             AoA(ii,jj,kk) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
%             CL(ii,jj,kk) = mean(CLtot(ran));   CD(ii,jj,kk) = mean(CDtot(ran));
%             Fdrag(ii,jj,kk) = mean(Drag(ran)); Flift(ii,jj,kk) = mean(Lift(ran));
%             Ffuse(ii,jj,kk) = mean(Fuse(ran)); Fthr(ii,jj,kk) = mean(Thr(ran));   Fturb(ii,jj,kk) = mean(Turb(ran));
%             Depth(ii,jj,kk) = 500-mean(tsc.positionVec.Data(3,1,ran));
%         end
%     end
% end
% filename1 = 'Elevation_TetherLength_Study_1-8.mat';
% fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
% elevation = el*180/pi;
% save([fpath1,filename1],'Pavg','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr','Fturb','thrLength','elevation','Depth','flwSpd')
%%
load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Depth Study\Elevation_TetherLength_Study_1-8.mat')
%%  Obtain Pmax Matrix 
Pmax = zeros(numel(flwSpd),numel(depth));  elev = Pmax;  thrL = Pmax;
for i = 1:numel(flwSpd)
    for j = 1:numel(depth)
        [Pmax(i,j),elev(i,j),thrL(i,j)] = getPmaxAtDepth(depth(j),i,Depth,Pavg,elevation,thrLength);
    end
end
%%  Fit Cubic Curve
for k = 1:numel(depth)
    p(:,k) = polyfit(flwSpd,Pmax(:,k),3)';
end
%%  Plotting 
speed = 0.1:0.01:0.5;
figure;  
subplot(12,3,[1 7]); hold on; grid on;
plot(speed,p(1,1)*speed.^3+p(2,1)*speed.^2+p(3,1)*speed+p(4,1),'b-'); xlim([0.1 0.5]); ylim([0 4]);
ylabel('$P_\mathrm{avg}$ [kW]'); 
title(sprintf('Depth = %d m',depth(1)));
subplot(12,3,[2 8]); hold on; grid on;
plot(speed,p(1,2)*speed.^3+p(2,2)*speed.^2+p(3,2)*speed+p(4,2),'b-'); xlim([0.1 0.5]); ylim([0 4]);
title(sprintf('Depth = %d m',depth(2)));
subplot(12,3,[13 19]); hold on; grid on;
plot(speed,p(1,3)*speed.^3+p(2,3)*speed.^2+p(3,3)*speed+p(4,3),'b-'); xlim([0.1 0.5]); ylim([0 4]);
ylabel('$P_\mathrm{avg}$ [kW]'); 
title(sprintf('Depth = %d m',depth(3)));
subplot(12,3,[14 20]); hold on; grid on;
plot(speed,p(1,4)*speed.^3+p(2,4)*speed.^2+p(3,4)*speed+p(4,4),'b-'); xlim([0.1 0.5]); ylim([0 4]);
title(sprintf('Depth = %d m',depth(4)));
subplot(12,3,[25 31]); hold on; grid on;
plot(speed,p(1,5)*speed.^3+p(2,5)*speed.^2+p(3,5)*speed+p(4,5),'b-'); xlim([0.1 0.5]); ylim([0 4]);
xlabel('$V_\mathrm{flow}$ [m/s]'); 
ylabel('$P_\mathrm{avg}$ [kW]'); 
title(sprintf('Depth = %d m',depth(5)));
subplot(12,3,[26 32]); hold on; grid on;
plot(speed,p(1,6)*speed.^3+p(2,6)*speed.^2+p(3,6)*speed+p(4,6),'b-'); xlim([0.1 0.5]); ylim([0 4]);
xlabel('$V_\mathrm{flow}$ [m/s]'); 
title(sprintf('Depth = %d m',depth(6)));

subplot(12,3,[3 15]); hold on; grid on;
plot(depth,thrL(1,:),'b-'); xlabel('Depth [m]'); ylabel('Tether Length [m]'); 
subplot(12,3,[21 33]); hold on; grid on;
plot(depth,elev(1,:),'b-'); xlabel('Depth [m]'); ylabel('Elevation [deg]'); 
%%
fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Depth Study\');
save([fpath,'DepthStudy_1-8.mat'],'p','flwSpd','Pmax','elev','thrL','depth');







