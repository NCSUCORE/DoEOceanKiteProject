figure('Name','Drag Force, Body Frame');
subplot(3,1,1)
plot(tsc.FDragBdy.Time,squeeze(tsc.FDragBdy.Data(1,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{Drag,x}^{Body}$, [N]')

subplot(3,1,2)
plot(tsc.FDragBdy.Time,squeeze(tsc.FDragBdy.Data(2,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{Drag,y}^{Body}$, [N]')

subplot(3,1,3)
plot(tsc.FDragBdy.Time,squeeze(tsc.FDragBdy.Data(3,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{Drag,z}^{Body}$, [N]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')