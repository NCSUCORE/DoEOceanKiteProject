%%  Load Results 
Tmaxx = 38;
fpath2 = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign\Tether\');  load([fpath2 'tetherDataFS3.mat']);
% load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
load(['C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\',...
    sprintf('Tmax_Study_AR8b8_Tmax-%d_ThrD-%.1f.mat',Tmaxx,AR8b8.length600.tensionValues190.outerDiam*1e3)]);
depth = [300 250 200];
eff = eval(sprintf('AR8b8.length600.tensionValues%d.efficencyPercent',190))/100;
%%  Squeeze Results 
Pavg = squeeze(Pavg(:,:,:));
Pnet = squeeze(Pavg)*eff;
Vavg = squeeze(Vavg);
AoA = squeeze(AoA(:,:,:));
CD = squeeze(CD(:,:,:));
CL = squeeze(CL(:,:,:));
elevation = squeeze(elevation(:,:,:));
ten = squeeze(ten(:,:,:));
Fdrag = squeeze(Fdrag(:,:,:));
Ffuse = squeeze(Ffuse(:,:,:));
Flift = squeeze(Flift(:,:,:));
Fthr = squeeze(Fthr(:,:,:));
Fturb = squeeze(Fturb(:,:,:));
%%  Reassign variables 
for i = 1:numel(flwSpd)
    for j = 1:numel(altitude)
        if ~isnan(max(Pavg(i,:,j)))
            idx1 = find(Pavg(i,:,j)==max(Pavg(i,:,j)));
            R.Pmax(i,j) = Pavg(i,idx1,j);
            R.Pnet(i,j) = Pnet(i,idx1,j);
            R.Vavg(i,j) = Vavg(i,idx1,j);
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
            R.Vavg = NaN;
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
% save([fpath,sprintf('TmaxStudy_%dkN_FS5.mat',Tmaxx)],'flwSpd','altitude','thrLength','R','Tmaxx','depth','eff');
save([fpath,sprintf('TmaxStudy_PDR_1.mat')],'flwSpd','altitude','thrLength','R','Tmax','eff');
%%  Plotting 
figure; 
for alt = 1:6
    subplot(3,2,1); hold on; grid on
    plot(flwSpd,R.Pmax(:,alt)*eff);  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('Power [kW]');  xlim([.1 0.5]);
    subplot(3,2,3); hold on; grid on
    plot(flwSpd,R.Vavg(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('$V_\mathrm{kite}$ [m/s]');  xlim([.1 0.5]);
    subplot(3,2,6); hold on; grid on
    plot(flwSpd,R.alpha(:,alt));  xlabel('$V_\mathrm{flow}$ [m/s]');  ylabel('AoA [deg]');  xlim([.1 0.5]);
    subplot(3,2,5); hold on; grid on
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
FS1 = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\PowCurve_FS1.mat');
FS3 = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\PowCurve_FS3.mat');
FS5 = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\PowCurve_FS5.mat');
PDR = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\output\Tmax Study\PowCurve_PDR_1.mat');
figure;
for i = 1:6
    subplot(3,2,i); hold on; grid on;
%     plot(FS1.flwSpd,FS1.Pnet(:,i),'r-');    
%     plot(FS3.flwSpd,FS3.Pnet(:,i),'b-');   
    plot(FS5.flwSpd,FS5.Pnet(:,i),'b-');   
    plot(PDR.flwSpd,PDR.Pnet(:,i),'r-');   
%     plot(FS1.flwSpd,FS1.Pmax(:,i),'r-');    
%     plot(FS3.flwSpd,FS3.Pmax(:,i),'b-');   
%     plot(FS5.flwSpd,FS5.Pmax(:,i),'g-');   
    ylim([0 4]);   xlabel('Flow Speed [m/s]');   ylabel('Net Power [kW]');  
    title(sprintf('Altitude = %d',FS1.altitude(i)));
end
legend('Old','New')
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
Pmax = R.Pmax;
fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
save([fpath 'PowCurve_PDR_1.mat'],'Pnet','Pmax','flwSpd','altitude')
%%  Extract Results 
simScenario = 1.3;  TDiam = 0.0125;   eff = 0.95;
fpath2 = fullfile(fileparts(which('OCTProject.prj')),'vehicleDesign','Tether\');
Tmax = 20;
thrLength = 200:50:600;                                     %   m - Initial tether length
flwSpd = 0.1:0.05:0.5;                                      %   m/s - Flow speed
altitude = [50 100 150 200 250 300];
for kk = 1:numel(flwSpd)
    for ii = 1:numel(thrLength)
        for jj = 1:numel(altitude)
            if altitude(jj) >= 0.7071*thrLength(ii) || altitude(jj) <= 0.1736*thrLength(ii)
                el = NaN;
            else
                el = asind(altitude(jj)/thrLength(ii))*pi/180;
            end
            if ~isnan(el)
                filename = sprintf(strcat('Turb%.1f_V-%.3f_Alt-%.d_ThrL-%d_Tmax-%d.mat'),simScenario,flwSpd(kk),altitude(jj),thrLength(ii),Tmax);
                fpath = 'D:\Altitude Thr-L Study\';
                load(strcat(fpath,filename))
                [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
                [CLtot,CDtot] = tsc.getCLCD(vhcl);
                [Lift,Drag,Fuse,Thr] = tsc.getLiftDrag;
                Turb = squeeze(sqrt(sum(tsc.FTurbBdy.Data.^2,1)));
                Pow = tsc.rotPowerSummary(vhcl,env);
                Pavg(kk,ii,jj) = Pow.avg;    Pnet(kk,ii,jj) = Pow.avg*eff;
                V = squeeze(sqrt(sum(tsc.velCMvec.Data.^2,1)));
                Vavg(kk,ii,jj) = mean(V(ran));
                AoA(kk,ii,jj) = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
                airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
                gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
                ten(kk,ii,jj) = max([max(airNode(ran)) max(gndNode(ran))]);
                fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN;\t Elevation = %.1f\n',AoA(kk,ii,jj),ten(kk,ii,jj),el*180/pi);
                CL(kk,ii,jj) = mean(CLtot(ran));   CD(kk,ii,jj) = mean(CDtot(ran));
                Fdrag(kk,ii,jj) = mean(Drag(ran)); Flift(kk,ii,jj) = mean(Lift(ran));
                Ffuse(kk,ii,jj) = mean(Fuse(ran)); Fthr(kk,ii,jj) = mean(Thr(ran));   Fturb(kk,ii,jj) = mean(Turb(ran));
                elevation(kk,ii,jj) = el*180/pi;
            else
                Pavg(kk,ii,jj) = NaN;  AoA(kk,ii,jj) = NaN;   ten(kk,ii,jj) = NaN;
                CL(kk,ii,jj) = NaN;    CD(kk,ii,jj) = NaN;    Fdrag(kk,ii,jj) = NaN;
                Flift(kk,ii,jj) = NaN; Ffuse(kk,ii,jj) = NaN; Fthr(kk,ii,jj) = NaN;
                Fturb(kk,ii,jj) = NaN; elevation(kk,ii,jj) = el*180/pi;
                Pnet(kk,ii,jj) = NaN;   Vavg(kk,ii,jj) = NaN;
            end
        end
    end
end

