figure('Position',[ 1 41 1920 963],'Units','pixels');
subplot(2,1,1)
plot(tsc.angleOfAttackDeg.Time,squeeze(tsc.angleOfAttackDeg.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\alpha$, [deg]')

subplot(2,1,2)
plot(tsc.sideSlipAngleDeg.Time,squeeze(tsc.sideSlipAngleDeg.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\beta$, [deg]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')