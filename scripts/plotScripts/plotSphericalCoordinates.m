figure('Name','Spherical Position');

subplot(3,1,1)
plot(tsc.positionVec.Time,squeeze(sqrt(sum(tsc.positionVec.Data.^2,1))),...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on
xlabel('Time, [s]')
ylabel('Radius, [m]')


subplot(3,1,2)
plot(tsc.positionVec.Time,...
    atan2d(squeeze(tsc.positionVec.Data(2,:,:)),squeeze(tsc.positionVec.Data(1,:,:))),...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on
xlabel('Time, [s]')
ylabel('Azimuth, [deg]')

subplot(3,1,3)
plot(tsc.positionVec.Time,...
    acosd(squeeze(tsc.positionVec.Data(3,:,:))./squeeze(sqrt(sum(tsc.positionVec.Data.^2,1)))),...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on
xlabel('Time, [s]')
ylabel('Zenith, [deg]')


set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')