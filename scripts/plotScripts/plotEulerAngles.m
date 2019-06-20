figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Euler Angles');
subplot(3,1,1)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on
hold on
plot(set_roll.Time,squeeze(set_roll.Data),...
    'LineStyle','--','Color',[1 0 0] ,'LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Roll, [deg]')

subplot(3,1,2)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(2,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on
hold on
plot(set_pitch.Time,squeeze(set_pitch.Data),...
    'LineStyle','--','Color',[1 0 0] ,'LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Pitch, [deg]')

subplot(3,1,3)
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('Yaw, [deg]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')