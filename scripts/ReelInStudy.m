%%  Load Results 
Turb = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\Results\Reel-In_Study1.mat');
LaR = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\Results\Reel-In_Study2.mat');
%%  Obtain optimal AoA
for ii = 1:numel(Turb.flwSpd)
    for jj = 1:numel(Turb.Vs)
        pm = max(Turb.Pnet(ii,jj,:));
        idx = find(Turb.Pnet(ii,jj,:)==pm);
        R.Pturb(ii,jj) = Turb.Pavg(ii,jj,idx);
        R.Pwnch(ii,jj) = Turb.Pwnch(ii,jj,idx);
        R.Pnet(ii,jj) = Turb.Pnet(ii,jj,idx);
        R.AoA(ii,jj) = Turb.A(idx);
    end
end
%%  Plot Surface for Net Power 
figure;
for i = 1:8
    subplot(2,4,i)
    surf(Turb.A,Turb.Vs,squeeze(Turb.Pnet(i,:,:)));  set(gca,'View',[126.0396 9.8289]);    hold on;
    plot3(R.AoA(i,:),Turb.Vs,R.Pnet(i,:),'r-*','MarkerSize',5,'LineWidth',2)
    xlabel('$\mathrm{\alpha_{des}}$ [deg]');  ylabel('$\mathrm{V_{reel}}$ [m/s]');  
    zlabel(['$\mathrm{P_{net}}$ [kW] at $\mathrm{V_{flow}}$ = ' sprintf('%.2f m/s',Turb.flwSpd(i))])
end
%%  Plot cross-current vs non cross-current 
figure;
for i = 1:8
    subplot(2,4,i); hold on; grid on;
    plot(Turb.Vs,squeeze(R.Pnet(i,:)),'r-');  
    plot(LaR.Vs,LaR.Pwnch(i,:),'b-');
    xlabel('$\mathrm{V_{reel}}$ [m/s]');    ylabel('$\mathrm{P_{net}}$ [kW]');
    title(['$\mathrm{V_{flow}}$ = ' sprintf('%.2f m/s',Turb.flwSpd(i))])
end
legend('X-current','Non X-current')
%%  Format Cross-current Results 
load([fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign\Tether\') 'tetherDataNew.mat']);
Tmax = 38;
eff = eval(sprintf('AR8b8.length600.tensionValues%d.efficencyPercent',Tmax))/100;
fpath = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
flwSpd = 0.15:0.05:0.5;                                     %   m/s - Flow speed
Vs = 0.01:0.02:0.25;
A = 14:-2:2;
for ii = 1:1
    for jj = 1:numel(Vs)
        for kk = 7:numel(A)
            el = interp2(maxT.altitude,maxT.flwSpd,maxT.R.EL,200,flwSpd(ii))*pi/180;
            filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_Vs-%.2f_AoA-%d.mat'),1.3,flwSpd(ii),el*180/pi,Vs(jj),A(kk));
            load(strcat('D:\Results2\',filename))
            [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
            [CLtot,CDtot] = tsc.getCLCD(vhcl);
            [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
            Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
            Pow = tsc.rotPowerSummary(vhcl,env);
            Pavg(ii,jj,kk) = Pow.avg;    Pwnch(ii,jj,kk) = Pow.wnch;
            Pnet(ii,jj,kk) = Pow.avg*eff+Pow.wnch;
            AoA(ii,jj,kk) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
            airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
            gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
            ten(ii,jj,kk) = max([max(airNode(ran)) max(gndNode(ran))]);
            fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN;\t Elevation = %.1f\n',AoA(ii,jj,kk),ten(ii,jj,kk),el*180/pi);
            CL(ii,jj,kk) = mean(CLtot(ran));   CD(ii,jj,kk) = mean(CDtot(ran));
            Fdrag(ii,jj,kk) = mean(Drag(ran)); Flift(ii,jj,kk) = mean(Lift(ran));
            Ffuse(ii,jj,kk) = mean(Fuse(ran)); Fthr(ii,jj,kk) = mean(Thr(ran));   Fturb(ii,jj,kk) = mean(Turb(ran));
            elevation(ii,jj,kk) = el*180/pi;
        end
    end
end
%%  Format Reel-in Results 
flwSpd = 0.15:0.05:0.5;                                     %   m/s - Flow speed
Vs = 0.01:0.02:0.25;
for ii = 1:numel(flwSpd)
    for jj = 1:numel(Vs)
        filename = sprintf(strcat('LaR%.1f_V-%.3f_EL-%.1f_SP-%.1f_Wnch-%.2f.mat'),4.3,flwSpd(ii),30,26,Vs(jj));
        load(strcat('D:\Results3\',filename))
        Pow.wnch = mean(tsc.winchPower.Data(round(numel(tsc.winchPower.Time)/2):end))*1e-3;
        Pwnch(ii,jj) = Pow.wnch;
    end
end
%%  Save Results
filename1 = sprintf('Reel-In_Study1.mat');
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'Results\');
% save([fpath1,filename1],'Pwnch','flwSpd','Vs')
save([fpath1,filename1],'Pavg','Pwnch','Pnet','AoA','CL','CD','Fdrag','Flift','Ffuse','Fthr',...
    'Fturb','thrLength','elevation','flwSpd','ten','Tmax','altitude','Vs','A')
