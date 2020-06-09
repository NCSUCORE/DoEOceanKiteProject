figure('Name','Velocity');
subplot(3,1,1)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(1,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('x Speed, [m]')

subplot(3,1,2)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(2,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('y Speed, [m]')

subplot(3,1,3)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(3,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('z Speed, [m]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')