figure('Name','Control Surface Deflections','units',...
    'normalized','outerposition',[0 0 1 1]);

subplot(2,2,1); hold on; grid on;
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,1,1)),...
    'LineStyle','-','Color','k','LineWidth',1.5,'DisplayName','Port Aileron')
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,2,1)),...
    'LineStyle','-','Color','r','LineWidth',1.5,'DisplayName','Stbd Aileron')
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,3,1)),...
    'LineStyle','-','Color','g','LineWidth',1.5,'DisplayName','Elevator')
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(:,4,1)),...
    'LineStyle','-','Color','b','LineWidth',1.5,'DisplayName','Rudder')
xlabel('Time, [s]')
ylabel('Deflection [deg]')
legend('FontSize',16,'Orientation','horizontal','Location','southeast')
% legend('boxoff')
% ylim([-10 5])

subplot(2,2,2); hold on; grid on;
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5,'DisplayName','Roll')
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(2,:,:))*180/pi,...
    'LineStyle','-','Color','r','LineWidth',1.5,'DisplayName','Pitch')
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi,...
    'LineStyle','-','Color','b','LineWidth',1.5,'DisplayName','Yaw')
% plot(tsc.rollSP.Time,squeeze(tsc.rollSP.Data)*180/pi,...
%     'LineStyle','--','Color','k','LineWidth',1.5)
% plot(tsc.pitchSP.Time,squeeze(tsc.pitchSP.Data),...
%     'LineStyle','--','Color','r','LineWidth',1.5)
% plot(tsc.yawSP.Time,squeeze(tsc.yawSP.Data),...
%     'LineStyle','--','Color','b','LineWidth',1.5)
legend('Roll','Pitch','Yaw','FontSize',16,'Orientation','horizontal',...
    'Location','southeast')
% legend('boxoff')
xlabel('Time, [s]')
ylabel('Angle [deg]')
% ylim([-2 1])

subplot(2,2,3); hold on; grid on;
plot(tsc.azimuthAngle.Time,squeeze(tsc.azimuthAngle.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5,'DisplayName','Azimuth')
plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data),...
    'LineStyle','-','Color','b','LineWidth',1.5,'DisplayName','Elevation')
legend('FontSize',16,'Orientation','horizontal','Location','southeast')
% legend('boxoff')
xlabel('Time, [s]')
ylabel('Azimuth Angle [deg]')

subplot(2,2,4); hold on; grid on;
plot(tsc.airTenVecs.Time,squeeze(tsc.airTenVecs.mag.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Tether Tension [N]')
% ylim([2000 2500])

set(findall(gcf,'Type','axes'),'FontSize',24)
linkaxes(findall(gcf,'Type','axes'),'x')
% xlim([0 35])%tsc.azimuthAngle.Time(end)])

elAng = round(tsc.elevationAngle.Data(end));
velo = tsc.velocityVec.mag.Data(end);
turn = round(tsc.gndStnEulerAngles.Data(3,:,end)*180/pi);
sgtitle(sprintf('System Response - Elevation = %d [deg], Tow Speed %.2f [m/s], Turning Angle %d [deg]',elAng,velo,turn),...
    'FontSize',30)