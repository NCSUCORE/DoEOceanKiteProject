%% Test script for John to control the kite model
clear; clc; close all;
Simulink.sdi.clear
%% Simulation Setup
% 1 - Vehicle Model:         1 = AR8b8, 2 = AR9b9, 3 = AR9b10
% 2 - High-level Controller: 1 = const basis, 2 = const basis/state flow
% 3 - Flight controller:     1 = pathFlow, 2 = full cycle
% 4 - Tether Model:          1 = Single link, 2 = Reel-in, 3 = Multi-node, 4 = Multi-node faired
% 5 - Environment:           1 = const flow, 2 = variable flow
% 6 - Save Results
% 7 - Animate
% 8 - Plotting
%%             1 2 3 4 5 6     7     8
thrSweep = [400 800 1200 1600 2000 2400 2800 3200 3600 4000 4400 4800]
flwSweep = 1;
altSweep = 1%thrSweep/2%100:50:450
x = meshgrid(thrSweep,flwSweep,altSweep);
[n,m,r] = size(x);
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
fpath = 'C:\Users\adabney\Documents\Results\longTetherStudy07-13-2022\';
fpathOut = 'C:\Users\adabney\iCloudDrive\NCSU HW Uploads\ULTPaper\'
clear mech loyd
for i = 1:2
    for j = 1:m
        for k = 1:r
            %%  Set Test Parameters
            fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
            Simulink.sdi.clear
            flwSpd = flwSweep;                                              %   m/s - Flow speed
            altitude = thrSweep(j)/2;     initAltitude = 100;                     %   m/m - cross-current and initial altitude
            thrLength = thrSweep(j);    initThrLength = 200;                    %   m/m - cross-current and initial tether length
            
            
            if i == 1
                fName = sprintf(strcat('ConstEl_V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);
            else
                fName = sprintf(strcat('BPConstEl_V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);
            end
            if exist([fpath fName])~=2
                thrLen(j,i) = NaN
                continue
            end
            
            load([fpath fName])
            
            if tsc.lapNumS.max<1 || tsc.lapNumS.Time(end)<5000
                thrLen(j,i) = NaN;
                mech(j,i) = NaN;
                loyd(j,i) = NaN;
                continue
            end
            pow{j} = tsc.rotPowerSummary(vhcl,env,thr);
            mech(j,i) = pow{j}.turb;
            loyd(j,i) = pow{j}.loyd;
                        lastLap = tsc.lapNumS.max;
            [idx1,idx2] = tsc.getLapIdxs(lastLap-1);
            ran = idx1:idx2;
            drag = squeeze(tsc.nodeDrag.mag.Data(1,:,ran));
            vApp = squeeze(tsc.vhclVapp.mag.Data(1,1,ran))';
%             drag = squeeze(tsc.nodeDrag.mag.Data(1,:,:));
%             vApp = squeeze(tsc.velCMvec.mag.Data(1,1,:))';
            ratio = drag./vApp.^2;
            thrLen(j,i) = mean(sum(2/(1000*1.2*0.022)*ratio));
%             thrLen{j,i} = sum(2/(1000*1.2*0.022)*ratio);
%             time{j,i} = tsc.nodeDrag.Time;
        end
    end
end


%%
% figure;
% hold on
% for i = 1:2
%     for j = m-3%:m
%         plot(time{j,i},thrLen{j,i})
%     end
% end
%%

thrLP = thrSweep
thrLP(isnan(mech(:,1))) = NaN;
figure('Position',[100 100 550 600])
tL = tiledlayout(2,1)
nexttile
hold on
plot(thrLP,mech(:,1),'-k','DisplayName','60m x 20 m','LineWidth',1.5)
plot(thrLP,mech(:,2),'--k','DisplayName','200 m x 40 m','LineWidth',1.5)
plot(thrLP,loyd(:,1),':k','DisplayName','Loyd','LineWidth',1.5)
% plot(thrSweep,loyd(:,2)/max([loyd mech],[],'all'),':r','DisplayName','Loyd','MarkerFaceColor','k','LineWidth',1.5)
% xlabel 'Tether Length [m]'
ylabel({'Lap-Averaged','Power [kW]'})
set(gca,'FontSize',15)
grid on
grid on

nexttile
hold on
plot(thrLP,thrLen(:,1),'-k','DisplayName','60 m x 20 m','LineWidth',1.5)
plot(thrLP,thrLen(:,2),'--k','DisplayName','200 m x 40 m','LineWidth',1.5)
plot(thrLP,thrSweep/4,':k','DisplayName','Loyd','LineWidth',1.5)

xlabel 'Tether Length [m]'
ylabel '$l_{\mu,eff} [m]$'
% legend
set(gca,'FontSize',15)
grid on
tL.Padding = 'compact'
tL.TileSpacing = 'compact'

% nexttile
% hold on
% plot(thrLP,thrLen(:,1)'./thrSweep,'-k','DisplayName','60 m x 20 m','LineWidth',1.5)
% plot(thrLP,thrLen(:,2)'./thrSweep,'--k','DisplayName','200 m x 40 m','LineWidth',1.5)
% plot(thrLP,thrSweep./(4*thrSweep),':k','DisplayName','Loyd','LineWidth',1.5)
% xlabel 'Tether Length [m]'
% ylabel '$||l_{\mu,eff}||$'
legend('Location','northwest')
% set(gca,'FontSize',15)
% grid on

fName = 'ULTconstEl';

saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'eps')

figure
hold on
plot(thrLP,cos(asin(thrSweep/2./thrSweep)).^3,'-k','LineWidth',1.5)
plot(thrLP,.18^2./(.18+1.2*thrLen(:,1)*0.022/9).^2,'--k','LineWidth',1.5)
plot(thrLP,.18^2./(.18+1.2*thrLen(:,1)*0.022/9).^2.*cos(asin(thrSweep/2./thrSweep)).^3,':k','LineWidth',1.5)
xlabel 'Tether Length [m]'
ylabel 'Efficiency'
legend('$\eta_1$','$\eta_2$','$\eta_1\eta_2$','FontSize',15)
set(gca,'FontSize',15)
grid on

yticks([0:0.1:1])
ylim([0 1])

fName = 'constElLossCoeff';

% saveas(gcf,[fpathOut fName],'fig')
% saveas(gcf,[fpathOut fName],'eps')

h = figure
hold on
plot(thrLP,cos(asin(thrSweep/2./thrSweep)).^3,'-k','LineWidth',1.5)
ylabel '$\eta_1$'
ylim([0 1])
yticks([0:0.1:1])
yyaxis right
plot(thrSweep,.18^2./(.18+1.2*thrLen(:,1)*0.022/(9)).^2,'--k','LineWidth',1.5)
% plot(thrSweep,.18^2./(.18+1.2*thrLen(:,1)*0.022/(9)).^2.*cos(asin(thrSweep/2./thrSweep)).^3,':k','LineWidth',1.5)
set(gca,'YColor','k')
ylim([0 .1])
yticks([0:0.01:.1])
xlabel 'Tether Length [m]'
ylabel '$\eta_2$'
legend('$\eta_1$','$\eta_2$','$\eta_1\eta_2$','FontSize',15)
set(gca,'FontSize',15)
grid on

fName = 'constElLossCoeff1';

% saveas(gcf,[fpathOut fName],'fig')
% saveas(gcf,[fpathOut fName],'eps')
%%             1 2 3 4 5 6     7     8

%Constant Altitude

thrSweep = [400  800 1200 1600 2000 2400 2800 3200 3600 4000 4400 4800]
flwSweep = 1;
altSweep = 300%100:50:450
x = meshgrid(thrSweep,flwSweep,altSweep);
[n,m,r] = size(x);
powGen = zeros(n,m,r);
pathErr = zeros(n,m,r);
dragRatio = zeros(n,m,r);
Pow = cell(n,m,r);
% fpath = 'C:\Users\adabney\Documents\Results\longTetherStudy04-08-2022\';

clear mech loyd thrLen
for i = 1:2
    for j = 1:m
        for k = 1:r
            j
            %%  Set Test Parameters
            fprintf(sprintf('%.2f Percent Complete\n',((i-1)*m*r+(j-1)*r+k)/(n*m*r)*100))
            Simulink.sdi.clear
            flwSpd = flwSweep;                                              %   m/s - Flow speed
            altitude = 300;     initAltitude = 100;                     %   m/m - cross-current and initial altitude
            thrLength = thrSweep(j);    initThrLength = 200;                    %   m/m - cross-current and initial tether length
            
            if i == 1
                fName = sprintf(strcat('ConstAlt_V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);
            else
                fName = sprintf(strcat('BPConstAlt_V-%.2f_Alt-%d_thr-%d.mat'),flwSpd,altitude,thrLength);
            end
            if exist([fpath fName])~=2
                thrLen(j,i) = NaN;
                continue
            end
            
            load([fpath fName])
            
            if tsc.lapNumS.max<1 
                continue
            end
            pow{j} = tsc.rotPowerSummary(vhcl,env,thr);
            mech(j,i) = pow{j}.turb;
            loyd(j,i) = pow{j}.loyd;
                        lastLap = tsc.lapNumS.max;
            [idx1,idx2] = tsc.getLapIdxs(lastLap-1);
            ran = idx1:idx2;
            drag = squeeze(tsc.nodeDrag.mag.Data(1,:,ran));
            vApp = squeeze(tsc.vhclVapp.mag.Data(1,1,ran))';
            ratio = drag./vApp.^2;
            thrLen(j,i) = mean(sum(2/(1000*1.2*0.022)*ratio));
        end
    end
end
%%
thrLP = thrSweep
thrLP(isnan(mech(:,1))) = NaN;
figure('Position',[100 100 550 600])
tL = tiledlayout(2,1)
nexttile
hold on
plot(thrLP,mech(:,1),'-k','DisplayName','60m x 20 m','LineWidth',1.5)
plot(thrLP,mech(:,2),'--k','DisplayName','200 m x 40 m','LineWidth',1.5)
plot(thrLP,loyd(:,1),':k','DisplayName','Loyd','LineWidth',1.5)
% plot(thrSweep,loyd(:,2)/max([loyd mech],[],'all'),':r','DisplayName','Loyd','MarkerFaceColor','k','LineWidth',1.5)
% xlabel 'Tether Length [m]'
ylabel({'Lap-Averaged','Power [kW]'})
set(gca,'FontSize',15)
grid on
grid on

nexttile
hold on
plot(thrLP,thrLen(:,1),'-k','DisplayName','60 m x 20 m','LineWidth',1.5)
plot(thrLP,thrLen(:,2),'--k','DisplayName','200 m x 40 m','LineWidth',1.5)
plot(thrLP,thrSweep/4,':k','DisplayName','Loyd','LineWidth',1.5)

xlabel 'Tether Length [m]'
ylabel '$l_{\mu,eff} [m]$'
% legend
set(gca,'FontSize',15)
grid on
tL.Padding = 'compact'
tL.TileSpacing = 'compact'

% nexttile
% hold on
% plot(thrLP,thrLen(:,1)'./thrSweep,'-k','DisplayName','60 m x 20 m','LineWidth',1.5)
% plot(thrLP,thrLen(:,2)'./thrSweep,'--k','DisplayName','200 m x 40 m','LineWidth',1.5)
% plot(thrLP,thrSweep./(4*thrSweep),':k','DisplayName','Loyd','LineWidth',1.5)
% xlabel 'Tether Length [m]'
% ylabel '$||l_{\mu,eff}||$'
legend('Location','northwest')
% set(gca,'FontSize',15)
% grid on

fName = 'ULTconstAlt';

saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'eps')


h = figure
hold on
plot(thrLP,cos(asin(300./thrSweep)).^3,'-k','LineWidth',1.5)
ylabel '$\eta_1$'
ylim([0 1])
yticks([0:0.1:1])
yyaxis right
plot(thrLP,.18^2./(.18+1.2*thrLen(:,1)*0.022/(9)).^2,'--k','LineWidth',1.5)
% plot(thrLP,.18^2./(.18+1.2*thrLen(:,1)*0.022/(9)).^2.*cos(asin(thrSweep/2./thrSweep)).^3,':k','LineWidth',1.5)
set(gca,'YColor','k')
ylim([0 .1])
yticks([0:0.01:.1])
xlabel 'Tether Length [m]'
ylabel '$\eta_2$'
legend('$\eta_1$','$\eta_2$','$\eta_1\eta_2$','FontSize',15)
set(gca,'FontSize',15)
grid on

fName = 'constAltLossCoeff1';

saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'eps')


%%
load('C:\Users\adabney\Documents\Results\longTetherStudy04-08-2022\ConstAlt_V-1.00_Alt-300_thr-4800.mat')

[idx1,idx2] = tsc.getLapIdxs(15);
ran = idx1:idx2;
s = [0:.1:.9];
for i = 1:numel(s)
    idx(i) =  find(tsc.closestPathVariable.Data(ran)>=s(i),1,'first')+idx1
end

thrPos = tsc.thrNodePosVecs.Data(:,:,idx)
figure
C = colororder
for i = 1:numel(s)
hold on
plot3(thrPos(1,:,i),thrPos(2,:,i),thrPos(3,:,i),'LineWidth',1,'DisplayName',sprintf('s = %.3f',s(i)))
end
grid on
xlabel 'X [m]'
ylabel 'Y [m]'
ylim([-30 30])
set(gca,'YScale','lin')
set(gca,'FontSize',15)
set(gca,'ColorOrder',C(1:5,:))
set(gca,'LineStyleOrder',{'-','--'})
legend('NumColumns',2)

fName = 'thrCurve'


saveas(gcf,[fpathOut fName],'fig')
saveas(gcf,[fpathOut fName],'epsc')