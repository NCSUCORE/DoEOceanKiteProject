figure('Name','Buoyant Force, Body Frame');

subplot(3,1,1)
plot(tsc.FBuoyBdy.Time,tsc.FBuoyBdy.Data(:,1),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{Buoy,x}^{Body}$, [N]')

subplot(3,1,2)
plot(tsc.FBuoyBdy.Time,tsc.FBuoyBdy.Data(:,2),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{Buoy,y}^{Body}$, [N]')

subplot(3,1,3)
plot(tsc.FBuoyBdy.Time,tsc.FBuoyBdy.Data(:,3),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$F_{Buoy,z}^{Body}$, [N]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')