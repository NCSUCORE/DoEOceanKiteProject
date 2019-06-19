figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Net Force, Body Frame');
subplot(3,1,1)
plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(1,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{x}^{Body}$, [N]')

subplot(3,1,2)
plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(2,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{y}^{Body}$, [N]')


subplot(3,1,3)
plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(3,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{z}^{Body}$, [N]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')