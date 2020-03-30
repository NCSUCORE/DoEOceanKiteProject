figure('Name','Velocity Magnitude');

plot(tsc.velocityVec.Time,squeeze(sqrt(sum(tsc.velocityVec.Data.^2,1))),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Speed, [m]')
box off
grid on

set(findall(gcf,'Type','axes'),'FontSize',20)