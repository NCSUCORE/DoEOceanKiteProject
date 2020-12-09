figure('Name','Longitudinal Dynamics');
subplot(2,1,1)

subplot(2,1,1); hold on; grid on;
plot(tsc.azimuthAngle.Time,squeeze(tsc.azimuthAngle.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Azimuth Angle [deg]')

subplot(2,1,2); hold on; grid on;
plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Elevation Angle [deg]')


set(findall(gcf,'Type','axes'),'FontSize',32)
linkaxes(findall(gcf,'Type','axes'),'x')