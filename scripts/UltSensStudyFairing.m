simScenario = [1 1 1 3 1 1==1  1==0 1==1];
thrSweep = [2000 3000 4000];
fairing = [0:50:600];
altSweep = 1;
flwSweep = 1;%0.5:0.25:2;
flowMult = 0.25;
x = meshgrid(thrSweep,altSweep,fairing);
[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
fpath = ['C:\Users\adabney\Documents\Results\2022-08-24_sensitivityStudyFairing\'];
fpathOut = 'C:\Users\adabney\iCloudDrive\NCSU HW Uploads\ULTPaper\figs\'
%%

for j = 1:m
    if j < 1
        continue
    end
    for k = 1:r
        if k < 1
            continue
        end
        for ii = 1

            flwSpd = flwSweep;                                              %   m/s - Flow speed
            altitude = thrSweep(j)/2;                   %   m/m - cross-current and initial altitude\
            thrLength = thrSweep(j);
            fString = 'Sensitivity';
            if ii == 2
                fString = ['BP' fString];
            end
            filename = sprintf(strcat(fString,'_V-1_fairing-%d_Alt-%d_thr-%d.mat'),fairing(k),altitude,thrLength)
            load([fpath filename])
            if tsc.MFuseBdy.Time(end) >= 500
                Pow{j,k,ii} = tsc.rotPowerSummary(vhcl,env,thr);
                pMech(j,k,ii) = Pow{j,k,ii}.turb;
                pLoyd(j,k,ii) = Pow{j,k,ii}.loyd;
                
                lastLap = tsc.lapNumS.max;
                [idx1,idx2] = tsc.getLapIdxs(lastLap-1);
                ran = idx1:idx2;
                drag = squeeze(tsc.nodeDrag.mag.Data(1,:,ran));
                vApp = squeeze(tsc.vhclVapp.mag.Data(1,1,ran))';
                ten(j,k,ii) = max(tsc.airTenVecs.mag.Data(ran));
                AoA(j,k,ii) = tsc.AoASP.mean*180/pi;
                ratio = drag./vApp.^2;
                thrLen(j,k,ii) = mean(sum(2/(1000*1.2*0.022)*ratio));
            else
                pMech(j,k,ii) = NaN;
                pLoyd(j,k,ii) = NaN;
                Pow{j,k,ii} = NaN;
            end
        end
    end
end


%%
figure('position',[100 100 550 800])
tL = tiledlayout(3,1)
nexttile
plotsq(fairing,pMech(1,:,1),'k','LineWidth',1.5)
hold on
plotsq(fairing,pMech(2,:,1),'--k','LineWidth',1.5)
plotsq(fairing,pMech(3,:,1),'-.k','LineWidth',1.5)
% plotsq(flowMult,pMech(4,:,1),':k','LineWidth',1.5)
grid on
set(gca,'ColorOrderIndex',1)
set(gca,'FontSize',14)
% legend('2000 m Tether',...
%     '3000 m Tether',....
%     '4000 m Tether','location','southeast')
% xlabel 'Fairing Length [m]'
ylabel({'Lap-Averaged','Power [kW]'})

fName = 'sensFairStudyPow';

saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'eps')


thrLen(thrLen==0) = NaN;
% figure('position',[100 100 550 350])
nexttile
plotsq(fairing,thrLen(1,:,1),'k','LineWidth',1.5)
hold on
plotsq(fairing,thrLen(2,:,1),'--k','LineWidth',1.5)
plotsq(fairing,thrLen(3,:,1),'-.k','LineWidth',1.5)
% % plotsq(flowMult,thrLen(4,:,1),':k','LineWidth',1.5)
grid on
set(gca,'ColorOrderIndex',1)
set(gca,'FontSize',14)
% legend('2000 m Tether',...
%     '3000 m Tether',....
%     '4000 m Tether','Location','northeast')
% xlabel 'Fairing Length [m]'
ylabel '$l_{\mu,eff} [m]$'

% fName = 'sensFairingStudyThrLen';
% fName = 'tiledFairingFig';
% tL.TileSpacing = 'compact';
% tL.Padding = 'compact'
% saveas(gcf,[fpathOut fName],'fig')
% saveas(gcf,[fpathOut fName],'eps')

thrLen(thrLen==0) = NaN;
% figure('position',[100 100 550 350])
nexttile
plotsq(fairing,ten(1,:,1)/1e3,'k','LineWidth',1.5)
hold on
plotsq(fairing,ten(2,:,1)/1e3,'--k','LineWidth',1.5)
plotsq(fairing,ten(3,:,1)/1e3,'-.k','LineWidth',1.5)
plot([0 600],[55 55],':k','LineWidth',1.5)
% % plotsq(flowMult,thrLen(4,:,1),':k','LineWidth',1.5)
grid on
set(gca,'ColorOrderIndex',1)
set(gca,'FontSize',14)
legend('2000 m Tether',...
    '3000 m Tether',....
    '4000 m Tether','Tension Limit','Location','southeast')
xlabel 'Fairing Length [m]'
ylabel 'Peak Tension [kN]'
ylim([30 60])
% 
% fName = 'tenLim';
% 
% saveas(gcf,[fpathOut fName],'fig')
% saveas(gcf,[fpathOut fName],'eps')
fName = 'tiledFairingFig';
tL.TileSpacing = 'compact';
tL.Padding = 'compact'
saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'eps')