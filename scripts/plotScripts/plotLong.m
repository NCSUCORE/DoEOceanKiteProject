figure('Name','Longitudinal Dynamics');
subplot(3,2,1)

subplot(3,2,1)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(1,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Body-X Velocity [m/s]')

subplot(3,2,2)
plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(1,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Body-X Position [m]')

subplot(3,2,3)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(3,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Body-Z Velocity [m/s]')

subplot(3,2,4)
plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(3,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Body-Z Position [m]')

subplot(3,2,5)
plot(tsc.angularVel.Time,squeeze(tsc.angularVel.Data(2,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Pitch Rate [deg/s]')

subplot(3,2,6)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(2,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Pitch Angle [deg]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')