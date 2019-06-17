figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Apparent Wind, Body Frame');
subplot(3,1,1)
plot(tsc.vAppBdy.Time,squeeze(tsc.vAppBdy.Data(1,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$v_{app,x}^{Body}$, [m/s]')

subplot(3,1,2)
plot(tsc.vAppBdy.Time,squeeze(tsc.vAppBdy.Data(2,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$v_{app,y}^{Body}$, [m/s]')

subplot(3,1,3)
plot(tsc.vAppBdy.Time,squeeze(tsc.vAppBdy.Data(3,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$v_{app,z}^{Body}$, [m/s]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')