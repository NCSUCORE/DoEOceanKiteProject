%%  Power Analysis
tic
flwSpd = [0.25 0.315 0.5 1 2];  D = 0.3:.01:0.65;  E = -.5:.05:.75;  
% fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','D\');
fpath = 'D:\Results\';
for ii = 1:numel(D)
    for jj = 1:length(E)
        fprintf('ii = %d;\t jj = %d\n',ii,jj)
        filename = sprintf(strcat('Turb%.1f_V-%.3f_D-%.2f_E-%.3f.mat'),1.3,flwSpd(2),D(ii),E(jj));
        load(strcat(fpath,filename))
        [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
        [CLtot,CDtot] = tsc.getCLCD(vhcl);
        [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
        Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
        Pow = tsc.rotPowerSummary(vhcl,env);
        Pavg(ii,jj) = Pow.avg;          Ployd(ii,jj) = Pow.loyd;
        AoA(ii,jj) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
        CL(ii,jj) = mean(CLtot(ran));   CD(ii,jj) = mean(CDtot(ran));
        Fdrag(ii,jj) = mean(Drag(ran)); Flift(ii,jj) = mean(Lift(ran));
        Ffuse(ii,jj) = mean(Fuse(ran)); Fthr(ii,jj) = mean(Thr(ran));   Fturb(ii,jj) = mean(Turb(ran));
    end
end
toc
save('DiamAndAoAStudyThr.mat','Pavg','Ployd','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr','Fturb','D','E')
%%
for i = 1:numel(D)
    [Pmax(i),Dmax(i)] = max(Pavg(i,:));
end
figure; subplot(2,2,1);
a = contourf(E,D,Pavg,20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. Power [kW]');  colorbar;  hold on; plot(E(Dmax),D,'r-')
subplot(2,2,2);
contourf(E,D,CL.^3./CD.^2,20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. $\mathrm{CL^3/CD^2}$');  colorbar;  hold on; plot(E(Dmax),D,'r-')
subplot(2,2,3);
contourf(E,D,AoA,20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. AoA [deg]');  colorbar;  hold on; plot(E(Dmax),D,'r-')
subplot(2,2,4);
contourf(E,D,Fturb./(Fdrag+Ffuse),20,'edgecolor','none');  xlabel('Elevator [deg]');  ylabel('Diameter [m]');  
title('Avg. $\mathrm{D_t/D_k}$');  colorbar;  hold on; plot(E(Dmax),D,'r-')
%%
% figure; subplot(2,1,1); hold on; grid on;
% plot(AoA,Pavg,'b-'); xlabel('Avg. AoA [deg]'); ylabel('Avg. Power [kW]')
% subplot(2,1,2); hold on; grid on;
% plot(AoA,CL.^3./CD.^2,'b-'); xlabel('Avg. AoA [deg]'); ylabel('Avg. $\mathrm{CL^3/CD^2}$')
%%
% figure; subplot(2,1,1); hold on; grid on;
% plot(D(1:4),Pavg,'b-'); xlabel('Diameter [m]'); ylabel('Avg. Power [kW]')
% subplot(2,1,2); hold on; grid on;
% plot(D(1:4),AoA,'b-'); xlabel('Diameter [m]'); ylabel('Avg. AoA [deg]')
%%
% p = polyfit(flwSpd1,avgPow,3);
% P = @(x) p(1)*x.^3+p(2).*x.^2+p(3).*x+p(4);
% pa = polyfit(flwSpd1,avgPowa,3);
% Pa = @(x) pa(1)*x.^3+pa(2).*x.^2+pa(3).*x+pa(4);
% vFlow = .1:.01:.5;
% powCurve = P(vFlow);
% powCurvea = Pa(vFlow);
% figure; hold on; grid on ;
% plot(vFlow,powCurvea,'b--'); xlabel('$V_\mathrm{flow}$ [m/s]'); ylabel('Avg. Power [W]')
% plot(vFlow,powCurve,'b-'); xlabel('Flow Velocity [m/s]'); ylabel('Avg. Power/Lap [W]')
% plot(.315,P(.315),'r*','markersize',12,'linewidth',2)
% plot(.315,Pa(.315),'r*','markersize',12,'linewidth',2)
% legend('AVL','XFlr5','location','northwest','autoupdate','off')