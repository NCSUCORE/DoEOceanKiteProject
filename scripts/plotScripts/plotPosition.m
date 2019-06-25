figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Position');
subplot(3,1,1)
plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(1,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on

xlabel('Time, [s]')
ylabel('x Position, [m]')

subplot(3,1,2)
plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(2,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on
xlabel('Time, [s]')
ylabel('y Position, [m]')

subplot(3,1,3)
plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(3,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
grid on
hold on
try
set_alt.plot('LineWidth',1.5,'Color','r','LineStyle','--')
catch
end
xlabel('Time, [s]')
ylabel('z Position, [m]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')