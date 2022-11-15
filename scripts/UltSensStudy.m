clc 
clear all
close all
simScenario = [1 1 1 3 1 1==1  1==0 1==1];
thrSweep = [2000 3000 4000];
altSweep = 1;
flwSweep = [1];%0.5:0.25:2;
flowMult = 0.1:0.1:1;
x = meshgrid(thrSweep,altSweep,flowMult);
[n,m,r] = size(x);
numCase = n*m*r;
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
fpath = ['C:\Users\adabney\Documents\Results\2022-08-24_sensitivityStudy\'];
fpathOut = 'C:\Users\adabney\iCloudDrive\NCSU HW Uploads\ULTPaper\figs\'
%%
shearLayer = [200:200:2000];

for j = 1:m
    if j < 1
        continue
    end
    for k = 1:numel(shearLayer)
        for ii = 1%:2
            flwSpd = flwSweep;                                              %   m/s - Flow speed
            altitude = thrSweep(j)/2;                   %   m/m - cross-current and initial altitude\
            thrLength = thrSweep(j);
            fString = 'Sensitivity';
            if ii == 2
                fString = ['BP' fString];
            end
            filename = sprintf(strcat(fString,'_V-1_shearLayer-%d_Alt-%d_thr-%d.mat'),k*200,altitude,thrLength)
            if exist([fpath filename])==2
                load([fpath filename])
                if tsc.MFuseBdy.Time(end) >= 1000+200*k
                    Pow{j,k,ii} = tsc.rotPowerSummary(vhcl,env,thr);
                    pMech(j,k,ii) = Pow{j,k,ii}.turb;
                    pLoyd(j,k,ii) = Pow{j,k,ii}.loyd;

                    lastLap = tsc.lapNumS.max;
                    [idx1,idx2] = tsc.getLapIdxs(lastLap-1);
                    ran = idx1:idx2;
                    drag = squeeze(tsc.nodeDrag.mag.Data(1,:,ran));
                    vApp = squeeze(tsc.vhclVapp.mag.Data(1,1,ran))';
                    ratio = drag./vApp.^2;
                    thrLen(j,k,ii) = mean(sum(2/(1000*1.2*0.022)*ratio));
                else
                    pMech(j,k,ii) = NaN;
                    pLoyd(j,k,ii) = NaN;
                    Pow{j,k,ii} = NaN;
                    thrLen(j,k,ii) = NaN;
                end
            else
                pMech(j,k,ii) = NaN;
                pLoyd(j,k,ii) = NaN;
                Pow{j,k,ii} = NaN;
            end
        end
    end
end


%%

figure('position',[100 100 550 600])
tL = tiledlayout(2,1)
nexttile
plotsq(shearLayer,pMech(1,:,1),'k','LineWidth',1.5)
hold on
plotsq(shearLayer,pMech(2,:,1),'--k','LineWidth',1.5)
plotsq(shearLayer,pMech(3,:,1),'-.k','LineWidth',1.5)
% plotsq(flowMult,pMech(4,:,1),':k','LineWidth',1.5)
grid on
set(gca,'ColorOrderIndex',1)
set(gca,'FontSize',14)
% legend('2000 m Tether',...
%     '3000 m Tether',....
%     '4000 m Tether','location','southwest')
% xlabel 'Shear Layer Thickness [m]'
ylabel({'Lap-Averaged','Power [kW]'})
ylim([2.5 6])
% fName = 'sensStudyPow';
% 
% saveas(gcf,[fpathOut fName],'fig')
% saveas(gcf,[fpathOut fName],'eps')


thrLen(thrLen==0) = NaN;
nexttile
% figure('position',[100 100 550 350])
plotsq(shearLayer,thrLen(1,:,1),'k','LineWidth',1.5)
hold on
plotsq(shearLayer,thrLen(2,:,1),'--k','LineWidth',1.5)
plotsq(shearLayer,thrLen(3,:,1),'-.k','LineWidth',1.5)
% plotsq(flowMult,thrLen(4,:,1),':k','LineWidth',1.5)
grid on
set(gca,'ColorOrderIndex',1)
set(gca,'FontSize',14)
legend('2000 m Tether',...
    '3000 m Tether',....
    '4000 m Tether','Location','northwest')
xlabel 'Shear Layer Thickness [m]'
ylabel '$l_{\mu,eff} [m]$'
fName = 'tiledShearFig';
tL.TileSpacing = 'compact';
tL.Padding = 'compact'
saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'eps')
fName = 'tiledShear';

saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'eps')
