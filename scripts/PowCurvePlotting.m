%%  Load Power Surfaces  
flwArray = 0.1:0.05:0.5;                %   m/s - candidate flow speeds
altArray = 50:50:400;                   %   m - candidate operating altitudes
thrArray = 100:100:600;                 %   m - candidate tether lengths
thrDiam = 18;   fairing = 00;
Tmax = getMaxTension(thrDiam);          %   kN - candidate tether tension limits
filename1 = sprintf('powStudy_CDR_ThrD-%.1f_Fair-%d.mat',thrDiam,fairing);
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'output\');
load([fpath1 filename1]);

%%  Plotting 
figure; 
for alt = 1:6
    subplot(3,2,1); hold on; grid on
    plot(flwArray,R1.Pavg(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Power [kW]');  xlim([.1 0.5]);
    subplot(3,2,3); hold on; grid on
    plot(flwArray,R1.Vavg(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('$V_\mathrm{kite}$ [m/s]');  xlim([.1 0.5]);
    subplot(3,2,6); hold on; grid on
    plot(flwArray,R1.alpha(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('AoA [deg]');  xlim([.1 0.5]);
    subplot(3,2,5); hold on; grid on
    plot(flwArray,R1.ten(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Tension [kN]');  xlim([.1 0.5]);
    if alt == 7
        plot(flwArray,Tmax*ones(1,numel(flwArray)),'k--')
        legend('Alt = 50 m','Alt = 100 m','Alt = 150 m','Alt = 200 m','Alt = 250 m','Alt = 300 m','Max Tension')
    elseif alt == 6
        legend('Alt = 50 m','Alt = 100 m','Alt = 150 m','Alt = 200 m','Alt = 250 m','Alt = 300 m')
    end
    subplot(3,2,2); hold on; grid on
    plot(flwArray,R1.thrL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Tether [m]');  xlim([.1 0.5]);
    subplot(3,2,4); hold on; grid on
    plot(flwArray,R1.EL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Elevation [deg]');  xlim([.1 0.5]);
end
%%  Load Individual Surfaces 
D18F0 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-18.0_F-0.mat');
D18F100 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-18.0_F-100.mat');
D16F0 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-16.0_F-0.mat');
D16F100 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-16.0_F-100.mat');
D14F0 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-14.0_F-0.mat');
D14F100 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-14.0_F-100.mat');
D11F0 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-11.0_F-0.mat');
D11F100 = load('C:\Users\JohnJr\Desktop\Manta Ray\DoEOceanKiteProject\output\PowCurve_CDR_D-11.0_F-100.mat');
%%  Compare Diameters
figure;
for i = 1:8
    subplot(4,2,i); hold on; grid on;
    plot(D18F0.flwArray,D18F0.Pnet(:,i),'r-');   
    plot(D16F0.flwArray,D16F0.Pnet(:,i),'b-');   
    plot(D14F0.flwArray,D14F0.Pnet(:,i),'color',[.75 0 0.75]);   
    plot(D11F0.flwArray,D11F0.Pnet(:,i),'g-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 1.6]);
    title(sprintf('Altitude = %d',D18F0.altArray(i)));
end
legend('18 mm','16 mm','11 mm')
figure;
for i = 1:8
    subplot(4,2,i); hold on; grid on;
    plot(D18F100.flwArray,D18F100.Pnet(:,i),'r-');   
    plot(D16F100.flwArray,D16F100.Pnet(:,i),'b-');   
    plot(D14F100.flwArray,D14F100.Pnet(:,i),'color',[.75 0 0.75]);   
    plot(D11F100.flwArray,D11F100.Pnet(:,i),'g-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 1.6]);
    title(sprintf('Altitude = %d',D18F0.altArray(i)));
end
legend('18 mm','16 mm','14 mm','11 mm')
%%  Compare Fairing
altitude = 100; idx = find(D18F0.altArray == altitude);
figure; subplot(3,1,1); hold on; grid on;
plot(D18F0.flwArray,D18F0.Pnet(:,idx),'r-');
plot(D18F100.flwArray,D18F100.Pnet(:,idx),'b-');  ylim([0 1.6]);
xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
legend('No Fairing','100 m Fairing','location','northwest');
title(sprintf('Alt = %d; Diam = %.1f',D18F0.altArray(idx),18.0));
subplot(3,1,2); hold on; grid on;
plot(D16F0.flwArray,D16F0.Pnet(:,idx),'r-');
plot(D16F100.flwArray,D16F100.Pnet(:,idx),'b-');  ylim([0 1.6]);
xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
title(sprintf('Alt = %d; Diam = %.1f',D18F0.altArray(idx),16.0));
subplot(3,1,3); hold on; grid on;
plot(D11F0.flwArray,D11F0.Pnet(:,idx),'r-');
plot(D11F100.flwArray,D11F100.Pnet(:,idx),'b-');  ylim([0 1.6]);
xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
title(sprintf('Alt = %d; Diam = %.1f',D18F0.altArray(idx),11.0));
%%  Compare Fairing 2
figure;
for i = 1:8
    subplot(4,2,i); hold on; grid on;
    plot(D18F0.flwArray,D18F0.Pnet(:,i),'r-');   
    plot(D18F100.flwArray,D18F100.Pnet(:,i),'b-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 1.6]);
    title(sprintf('Altitude = %d',D18F0.altArray(i)));
end
legend('No Fairing','100 m Fairing','location','northwest');
figure;
for i = 1:8
    subplot(4,2,i); hold on; grid on;
    plot(D11F0.flwArray,D11F0.Pnet(:,i),'r-');   
    plot(D11F100.flwArray,D11F100.Pnet(:,i),'b-');   
    xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  ylim([0 1.6]);
    title(sprintf('Altitude = %d',D18F0.altArray(i)));
end
legend('No Fairing','100 m Fairing','location','northwest');




