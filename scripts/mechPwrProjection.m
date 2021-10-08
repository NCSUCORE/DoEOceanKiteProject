%   Simple mechanical power estimation
%   By Chris Vermillion
%   Update by Andrew Abney 6/29/21
clc
clear all
close all
%   Define tow speeds of interest
vTow = 0:0.01:2;

%   Right now I'm parameterizing tension as purely quadratic in flow speed
%   T_crosscurrent = k1*v_flow^2
%   T_steady = k2*v_flow^2
kP = 151.8;
k1 = 122
k2 = 18.31;

%   Compare tension levels at various tow speeds, with no spool-out/in
tOut = k1*vTow.^2;
tIn = k2*vTow.^2;

figure(1)
hold on
plot(vTow,tOut,'LineWidth',1.5);
plot(vTow,tIn,'r','LineWidth',1.5);
xlabel('Tow speed (m/s)','fontsize',12);
ylabel('Projected tension (N)','fontsize',12);
grid
legend('Spool out','Spool in','Location','northwest');
% Mark the operational areas
yl = ylim;
xBox = [.5, .5,     2,     2, 1, 1,   .5 ];
yBox = [k1, yl(2), yl(2), 0, 0, k1, k1];
patch(xBox, yBox, 'black', 'EdgeColor', 'none', 'FaceColor', 'blue', 'FaceAlpha', .2,...
    'DisplayName','Lake Operating Window');
xBox = [.5, .5, 1, 1, .5];
yBox = [0, k1, k1, 0, 0];
patch(xBox, yBox, 'black', 'EdgeColor','none', 'FaceColor', 'green', 'FaceAlpha', .2,...
    'DisplayName','Pool Operating Window');
xticks([0 0.5 1 1.5 2])
set(gca,'FontSize',15)
hold off;

%   Now, consider spool-out and spool-in operation, where K_in and K_out
%   represent the fraction of the tow speed at which spooling in and out
%   (respectively) occurs

kIn = [.1 .2 1/3]';
kOut = [.1 .2 1/3]';
vOut = (1-kIn)*vTow;
vIn = (1+kIn)*vTow;

pOut = k1*vOut.^2.*kOut.*vTow;
pOutPeak = kP*vOut.^2.*kOut.*vTow;
pIn = k2*vIn.^2.*kIn.*vTow;
titleCell = {'Spooling In/Out at 10$\%$ of $v_{tow}$',...
    'Spooling In/Out at 20$\%$ of $v_{tow}$',...
    'Spooling In/Out at 33$\%$ of $v_{tow}$'};

figure(2)
set(gcf,'Position',[100 100 1500 500]);
for i = 1:numel(kIn)
    subplot(1,3,i); grid on; hold on;
    plot(vTow,pOutPeak(i,:),'--','LineWidth',1.5) %Peak Power Spooling Out
    plot(vTow,pOut(i,:),'LineWidth',1.5); %Power Generated Spooling Out
    plot(vTow,pIn(i,:),'r','LineWidth',1.5); %Power Consumed Spooling In
    % plot(v_tow,P_out-P_in,'--k') %Net Mechanical Power
    xlabel('Tow speed (m/s)','fontsize',12);
    if i == 1
        ylabel('Projected mechanical power (W)','fontsize',12);
    end
    legend('Peak Spool Out','Mean Spool out','Spool in','Net Mechanical Power','Location','northwest');
    set(gca,'FontSize',15)
    ylim([0 250])
    title(titleCell{i},'FontSize',18)
end

%%
figure(3)
h=tiledlayout(1,3,'Padding','compact','TileSpacing','compact')
set(gcf,'Position',[100 100 1500 500]);
for i = 1:numel(kIn)
    nexttile
    grid on; hold on;
    plot(vTow,pOut(i,:),'LineWidth',1.5); %Power Generated Spooling Out
    plot(vTow,pIn(i,:),'r','LineWidth',1.5); %Power Consumed Spooling In
    plot(vTow,pOut(i,:)-pIn(i,:),'--k') %Net Mechanical Power
    xlabel('Tow speed (m/s)','fontsize',12);
    if i == 1
        ylabel('Projected mechanical power (W)','fontsize',12);
    end
    set(gca,'FontSize',15)
    ylim([0 250])
    title(titleCell{i},'FontSize',18)
    legend('Spool out','Spool in','Net Mechanical Power','Location','northwest');
end
%%
nameCell = {'10pct','20pct','30pct'}
fpath = fullfile(fileparts(which('OCTProject.prj')),'output\');
for i = 1:numel(kIn)
    fName = nameCell{i}
    figure
    set(gcf,'Position',[100 100 500 500]);
    grid on; hold on;
    plot(vTow,pOutPeak(i,:),'LineWidth',1.5) %Peak Power Spooling Out
    plot(vTow,pOut(i,:),'LineWidth',1.5); %Power Generated Spooling Out
    plot(vTow,pIn(i,:),'LineWidth',1.5); %Power Consumed Spooling In
    xlabel('Tow speed (m/s)','fontsize',15);

    ylim([0 200])
    legend('Peak Spool Out','Mean Spool Out','Spool in','Location','northwest');
    ylabel('Mechanical Power (W)','fontsize',15);
        set(gca,'FontSize',15)
    saveas(gcf,[fpath fName],'fig')
    saveas(gcf,[fpath fName],'png')
end
%%
%Plot Net Mechanical Power
fpath = fullfile(fileparts(which('OCTProject.prj')),'output\');
fName = 'netPowerComp'
figure
set(gcf,'Position',[100 100 500 500]);
grid on; hold on;
for i = 1:numel(kIn)
    plot(vTow,pOut(i,:)-pIn(i,:),'LineWidth',1.5) %Net Mechanical Power
end
xlabel('Tow speed (m/s)','fontsize',15);
ylabel('Power (W)','fontsize',12);
set(gca,'FontSize',15)
ylim([0 100])
legend('$\gamma = 0.1$','$\gamma = 0.2$','$\gamma = 0.33$','Location','northwest');
saveas(gcf,[fpath fName],'fig')
saveas(gcf,[fpath fName],'png')
%% Power vs Gamma
fpath = fullfile(fileparts(which('OCTProject.prj')),'output\');
fName = 'netPowerGamma'
vTow = [0.5 1 1.5 2]
kIn = [0:0.01:0.5]';
kOut = kIn;
vOut = (1-kIn)*vTow;
vIn = (1+kIn)*vTow;

pOutPeak = kP*vOut.^2.*kOut.*vTow; 
pOut = k1*vOut.^2.*kOut.*vTow;
pIn = k2*vIn.^2.*kIn.*vTow;
pNet = pOut-pIn;
pNetPeak = pOutPeak - pIn;
kIn(find(pNetPeak(:,i) == max(pNetPeak(:,i))))

kIn(find(pNet(:,i) == max(pNet(:,i))))
figure
set(gcf,'Position',[100 100 500 500]);
grid on; hold on;
plot(kIn,pNet,'LineWidth',1.5)
set(gca,'ColorOrderIndex',1)
plot(kIn,pNetPeak,'--','LineWidth',1.5)
xlabel '$\gamma$'
ylabel 'Net Power [W]'
ylim([0 120])
legend('$v_{tow}$ = 0.5 m/s','$v_{tow}$ = 1.0 m/s','$v_{tow}$ = 1.5 m/s',...
    '$v_{tow}$ = 2.0 m/s')
set(gca,'FontSize',15)
saveas(gcf,[fpath fName],'fig')
saveas(gcf,[fpath fName],'png')

fName = 'netPowerGammaPeak'
figure
set(gcf,'Position',[100 100 500 500]);
grid on; hold on;
plot(kIn,pNetPeak,'LineWidth',1.5)
xlabel '$\gamma$'
ylabel 'Net Power [W]'
legend('$v_{tow}$ = 0.5 m/s','$v_{tow}$ = 1.0 m/s','$v_{tow}$ = 1.5 m/s',...
    '$v_{tow}$ = 2.0 m/s')
set(gca,'FontSize',15)
saveas(gcf,[fpath fName],'fig')
saveas(gcf,[fpath fName],'png')