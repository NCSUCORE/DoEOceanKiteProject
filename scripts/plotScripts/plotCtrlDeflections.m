figure('Name','Control Surface Deflections');

subplot(2,2,1); hold on; grid on;
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,1,1)),...
    'LineStyle','-','Color','k','LineWidth',1.5,'DisplayName','Port Aileron')
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,2,1)),...
    'LineStyle','-','Color','r','LineWidth',1.5,'DisplayName','Starboard Aileron')
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,3,1)),...
    'LineStyle','-','Color','g','LineWidth',1.5,'DisplayName','Elevator')
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,4,1)),...
    'LineStyle','-','Color','b','LineWidth',1.5,'DisplayName','Rudder')
xlabel('Time, [s]')
ylabel({'Control Surface','Deflection [deg]'})
legend('FontSize',20)

subplot(2,2,2); hold on; grid on;
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5,'DisplayName','Roll')
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(2,:,:))*180/pi,...
    'LineStyle','-','Color','r','LineWidth',1.5,'DisplayName','Pitch')
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi,...
    'LineStyle','-','Color','b','LineWidth',1.5,'DisplayName','Yaw')
legend('FontSize',20)
xlabel('Time, [s]')
ylabel('Euler Angle [deg]')

subplot(2,2,3); hold on; grid on;
plot(tsc.azimuthAngle.Time,squeeze(tsc.azimuthAngle.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5,'DisplayName','Azimuth')
plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data),...
    'LineStyle','-','Color','b','LineWidth',1.5,'DisplayName','Elevation')
legend('FontSize',20)
xlabel('Time, [s]')
ylabel('Azimuth Angle [deg]')

subplot(2,2,4); hold on; grid on;
plot(tsc.airTenVecs.Time,squeeze(tsc.airTenVecs.mag.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Tether Tension [N]')

set(findall(gcf,'Type','axes'),'FontSize',32)
linkaxes(findall(gcf,'Type','axes'),'x')