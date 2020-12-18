%%  Load Results 
Tmaxx = 38;
% fpath2 = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign','Tether\');  load([fpath2 'tetherDataFS3.mat']);
load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\Redundant\Tmax_Study_AR8b8_Tmax-38 - Copy.mat')
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
load(['C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\',sprintf('Tmax_Study_AR8b8_Tmax-%d.mat',Tmaxx)]);
depth = [300 250 200];
eff = eval(sprintf('AR8b8.length600.tensionValues%d.efficencyPercent',38))/100;
%%  Squeeze Results 
Pavg = squeeze(Pavg(1,:,:,:));
Pnet = squeeze(Pavg)*eff;
AoA = squeeze(AoA(1,:,:,:));
CD = squeeze(CD(1,:,:,:));
CL = squeeze(CL(1,:,:,:));
elevation = squeeze(elevation(1,:,:,:));
ten = squeeze(ten(1,:,:,:));
Fdrag = squeeze(Fdrag(1,:,:,:));
Ffuse = squeeze(Ffuse(1,:,:,:));
Flift = squeeze(Flift(1,:,:,:));
Fthr = squeeze(Fthr(1,:,:,:));
Fturb = squeeze(Fturb(1,:,:,:));
%%  Reassign variables 
for i = 1:numel(flwSpd)
    for j = 1:numel(altitude)
        if ~isnan(max(Pavg(i,:,j)))
            idx1 = find(Pavg(i,:,j)==max(Pavg(i,:,j)));
            R.Pmax(i,j) = Pavg(i,idx1,j);
            R.Pnet(i,j) = Pnet(i,idx1,j);
            R.alpha(i,j) = AoA(i,idx1,j);
            R.CD(i,j) = CD(i,idx1,j);
            R.CL(i,j) = CL(i,idx1,j);
            R.EL(i,j) = elevation(i,idx1,j);
            R.ten(i,j) = ten(i,idx1,j);
            R.thrL(i,j) = thrLength(idx1);
            R.Fdrag(i,j) = Fdrag(i,idx1,j);
            R.Ffuse(i,j) = Ffuse(i,idx1,j);
            R.Flift(i,j) = Flift(i,idx1,j);
            R.Fthr(i,j) = Fthr(i,idx1,j);
            R.Fturb(i,j) = Fturb(i,idx1,j);
        else
            R.Pmax(i,j) = NaN;
            R.Pnet(i,j) = NaN;
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
%%  Save
fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
save([fpath,sprintf('TmaxStudy_%dkN_old.mat',Tmaxx)],'flwSpd','altitude','thrLength','R','Tmaxx','depth','eff');
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
        plot(flwSpd,Tmaxx*ones(1,numel(flwSpd)),'k--')
    end
    legend('Alt = 50 m','Alt = 100 m','Alt = 150 m','Alt = 200 m','Alt = 250 m','Alt = 300 m','Max Tension')
    subplot(3,2,2); hold on; grid on
    plot(flwSpd,R.thrL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Tether [m]');  xlim([.1 0.5]);
    subplot(3,2,4); hold on; grid on
    plot(flwSpd,R.EL(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Elevation [deg]');  xlim([.1 0.5]);
end

%%  Determine opt tether tension limit based on flow resource 
% M1 = ENV.Manta(1);   M2 = ENV.Manta(2);   M3 = ENV.Manta(3);   M4 = ENV.Manta(4);
% M5 = ENV.Manta(5);   M6 = ENV.Manta(6);   M7 = ENV.Manta(7);   M8 = ENV.Manta(8);
% M9 = ENV.Manta(9);   M10 = ENV.Manta(10); M11 = ENV.Manta(11); M12 = ENV.Manta(12);

Title = {'January','February','March','April','May','June','July','August','September','October','November','December'};
figure;
for i = 1:12
    subplot(3,4,i); hold on; grid on;
    plot(D500.maxT,D500.Pavg(:,i),'r-');  
    plot(D450.maxT,D450.Pavg(:,i),'g-');  
    plot(D400.maxT,D400.Pavg(:,i),'b-');  
    plot(D350.maxT,D350.Pavg(:,i),'k-');  
    xlabel('$T_\mathrm{max}$ [kN]');  ylabel('Power [kW]');  title(Title{i});
    if i == 1
        legend('D = 500 m','D = 450 m','D = 400 m','D = 350 m','Orientation','horizontal')
    end
end
figure;
for i = 1:12
    subplot(3,4,i); hold on; grid on;
    plot(D500.maxT,D500.vAvg(:,i),'r-');  
    plot(D450.maxT,D450.vAvg(:,i),'g-');  
    plot(D400.maxT,D400.vAvg(:,i),'b-');  
    plot(D350.maxT,D350.vAvg(:,i),'k-');  
    xlabel('$T_\mathrm{max}$ [kN]');  ylabel('Power [kW]');  title(Title{i});
    if i == 1
        legend('D = 500 m','D = 450 m','D = 400 m','D = 350 m','location','northwest')
    end
end
%%  Save Power Curve 
Pnet = R.Pnet;
fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
save([fpath 'PowCurve_11-6.mat'],'Pnet','flwSpd','altitude')

