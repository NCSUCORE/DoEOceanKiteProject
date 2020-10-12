figure('Name','Lateral Dynamics');
subplot(3,2,1)

subplot(3,2,1)
plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(2,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Body-Y Velocity [m/s]')

subplot(3,2,3)
plot(tsc.angularVel.Time,squeeze(tsc.angularVel.Data(1,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Roll Rate [deg/s]')

subplot(3,2,5)
plot(tsc.angularVel.Time,squeeze(tsc.angularVel.Data(3,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Yaw Rate [deg/s]')

subplot(3,2,4)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Roll Angle [deg]')

subplot(3,2,6)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Yaw Angle [deg]')

subplot(3,2,2)
plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(2,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Body-Y Position [m]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')
