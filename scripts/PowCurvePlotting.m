%%  Load Power Surfaces  
flwSpd = 0.15:0.05:0.5;                %   m/s - candidate flow speeds
altArray = 50:50:450;                   %   m - candidate operating altitudes
thrArray = 200:50:800;                 %   m - candidate tether lengths
thrDiam = 18;   fairing = 100;
Tmax = 20;          %   kN - candidate tether tension limits
filename1 = '600m20211216Study.mat';

fpath1 = 'D:\Users\adabney\Documents\mantaconfig\';
% fpath1 = '\\cuifile1.sure.ad.ncsu.edu\cvermil00\Documents\CDR PowerSurfaces\IBR Surface Study\';
load([fpath1 filename1]);

%%  Plotting 
figure; 
set(gcf,'DefaultAxesLineStyleOrder',{'-','--',':'})
for alt = 1:numel(altArray)
    subplot(3,2,1); hold on; grid on
    plot(flwSpd,R1.Pavg(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Power [kW]');  xlim([.1 0.5]);
    subplot(3,2,3); hold on; grid on
    plot(flwSpd,R1.Vmax(:,alt)');  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('$V_\mathrm{kite,max}$ [m/s]');  xlim([.1 0.5]);
%     plot(flwSpd,R1.Vavg(:,alt)');  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('$V_\mathrm{kite}$ [m/s]');  xlim([.1 0.5]);
    subplot(3,2,6); hold on; grid on
    plot(flwSpd,R1.alpha(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('AoA [deg]');  xlim([.1 0.5]);
    subplot(3,2,5); hold on; grid on
    plot(flwSpd,R1.ten(:,alt),'DisplayName',sprintf('%d m',altArray(alt)));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Tension [kN]');  xlim([.1 0.5]);
    if alt == numel(altArray)
        plot(flwArray,Tmax*ones(1,numel(flwArray)),'--k','DisplayName','Max Tension')
        legend('NumColumns',3)
    end
    subplot(3,2,2); hold on; grid on
    plot(flwSpd,R1.thrL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Tether [m]');  xlim([.1 0.5]);
    subplot(3,2,4); hold on; grid on
    plot(flwSpd,R1.EL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Elevation [deg]');  xlim([.1 0.5]);
end
%%  Load Individual Surfaces 
% fName = 'CDR_20211206Curve.mat'
% fName1 = 'NewTurb20211203Curve.mat'
% fName2 = 'NewTurb20211206Curve.mat'
% fName3 = 'Turb20211208Curve.mat'
fName = '600m20211216Curve.mat';
fName1 = '700m20211216Curve.mat';
fName2 = '800m20211216Curve.mat'
pSurf{1} = load([fpath1 fName])
pSurf{2} = load([fpath1 fName1]);
pSurf{3} = load([fpath1 fName2]);
% pSurf{2} = load([fpath1 fName3]);
%%  Compare diameters without fairing 
figure; % No fairing 
t = tiledlayout(4,2)
c = colororder;
for j = 1:length(pSurf)
for i = 2:9
    nexttile(i-1); hold on; grid on;
%     if j == 2
%     plot(pSurf{j}.flwArray,pSurf{j}.Pnet(:,2*i-1),'Color',c(j,:)); 
%     else 
    plot(pSurf{j}.flwArray,pSurf{j}.Pnet(:,i),'Color',c(j,:)); 
        title(sprintf('Altitude = %d',pSurf{j}.altArray(i)));
%         ylim([0 2])
%     end
%     plot(D16F0.flwArray,D16F0.Pnet(:,i),'b-');   
%     plot(D14F0.flwArray,D14F0.Pnet(:,i),'color',[.75 0 0.75]);   
%     plot(D11F0.flwArray,D11F0.Pnet(:,i),'g-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 2]);
    xlim([0.15 0.5])
%     title(sprintf('Altitude = %d',pSurf{j}.altArray(i)));
    set(gca,'FontSize',10)
end
end
t.Padding = 'compact'
t.TileSpacing = 'compact'
legend('600 m','700 m','800 m','Location','northwest')
%%  Compare diameters with fairing 
figure;
for i = 1:6
    subplot(3,2,i); hold on; grid on;
    plot(D18F100.flwArray*1.94384,D18F100.Pnet(:,i),'r-');   
    plot(D16F100.flwArray*1.94384,D16F100.Pnet(:,i),'b-');   
    plot(D14F100.flwArray*1.94384,D14F100.Pnet(:,i),'color',[.75 0 0.75]);   
    plot(D11F100.flwArray*1.94384,D11F100.Pnet(:,i),'g-');   
    xlabel('Flow Speed [kts]');   ylabel('Net Power [kW]');  ylim([0 2.5]); xlim([.1*1.94384 0.5*1.94384])
    title(sprintf('Altitude = %.1f ft',D18F0.altArray(i)*3.2808));
end
L = legend('18 mm','16 mm','14 mm','11 mm');
%%  Compare Diameters Pavg
figure;
for i = 1:8
    subplot(4,2,i); hold on; grid on;
    plot(D18F0.flwArray,D18F0.Pavg(:,i),'r-');   
    plot(D16F0.flwArray,D16F0.Pavg(:,i),'b-');   
    plot(D14F0.flwArray,D14F0.Pavg(:,i),'color',[.75 0 0.75]);   
    plot(D11F0.flwArray,D11F0.Pavg(:,i),'g-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 2.5]);
    title(sprintf('Altitude = %d',D18F0.altArray(i)));
end
legend('18 mm','16 mm','14 mm','11 mm')
figure;
for i = 1:8
    subplot(4,2,i); hold on; grid on;
    plot(D18F100.flwArray,D18F100.Pavg(:,i),'r-');   
    plot(D16F100.flwArray,D16F100.Pavg(:,i),'b-');   
    plot(D14F100.flwArray,D14F100.Pavg(:,i),'color',[.75 0 0.75]);   
    plot(D11F100.flwArray,D11F100.Pavg(:,i),'g-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 2.5]);
    title(sprintf('Altitude = %d',D18F0.altArray(i)));
end
legend('18 mm','16 mm','14 mm','11 mm')
%%  Compare Fairing
altitude = 100; idx = find(D18F0.altArray == altitude);
figure; subplot(4,1,1); hold on; grid on;
plot(D18F0.flwArray,D18F0.Pnet(:,idx),'r-');
plot(D18F100.flwArray,D18F100.Pnet(:,idx),'b-');  %ylim([0 1.6]);
xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
legend('No Fairing','100 m Fairing','location','northwest');
title(sprintf('Alt = %d; Diam = %.1f',D18F0.altArray(idx),18.0));
subplot(4,1,2); hold on; grid on;
plot(D16F0.flwArray,D16F0.Pnet(:,idx),'r-');
plot(D16F100.flwArray,D16F100.Pnet(:,idx),'b-');  ylim([0 1.6]);
xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
title(sprintf('Alt = %d; Diam = %.1f',D18F0.altArray(idx),16.0));
subplot(4,1,3); hold on; grid on;
plot(D14F0.flwArray,D14F0.Pnet(:,idx),'r-');
plot(D14F100.flwArray,D14F100.Pnet(:,idx),'b-');  ylim([0 1.6]);
xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
title(sprintf('Alt = %d; Diam = %.1f',D18F0.altArray(idx),14.0));
subplot(4,1,4); hold on; grid on;
plot(D11F0.flwArray,D11F0.Pnet(:,idx),'r-');
plot(D11F100.flwArray,D11F100.Pnet(:,idx),'b-');  ylim([0 1.6]);
xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
title(sprintf('Alt = %d; Diam = %.1f',D18F0.altArray(idx),11.0));
%%  Compare Fairing 2 for 18 mm
figure;
for i = 1:6
    subplot(3,2,i); hold on; grid on;
    plot(D18F0.flwArray*1.94384,D18F0.Pnet(:,i),'r-');   
    plot(D18F100.flwArray*1.94384,D18F100.Pnet(:,i),'b-');   
    xlabel('Flow Speed [kts]');   ylabel('Net Power [kW]');  ylim([0 2.5]); xlim([.1*1.94384 0.5*1.94384]);
    title(sprintf('Altitude = %.1f ft',D18F0.altArray(i)*3.2808));
end
legend('No Fairing','100 m Fairing','location','northwest');
%%  Compare Fairing 2 for 11 mm
figure;
for i = 1:8
    subplot(4,2,i); hold on; grid on;
    plot(D11F0.flwArray,D11F0.Pnet(:,i),'r-');   
    plot(D11F100.flwArray,D11F100.Pnet(:,i),'b-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 1.6]);
    title(sprintf('Altitude = %d',D18F0.altArray(i)));
end
legend('No Fairing','100 m Fairing','location','northwest');




