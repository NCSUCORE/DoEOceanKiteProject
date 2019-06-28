figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Ctrl Surf Deflections');
subplot(4,1,1)
plot(tsc.prtAilDefl.Time,tsc.prtAilDefl.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{ail}^{prt}$, [deg]')

subplot(4,1,2)
plot(tsc.stbAilDefl.Time,tsc.stbAilDefl.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{ail}^{sbd}$, [deg]')

subplot(4,1,3)
plot(tsc.stbElevDefl.Time,tsc.stbElevDefl.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{elev}$, [deg]')


subplot(4,1,4)
plot(tsc.ruddDefl.Time,tsc.ruddDefl.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{rudd}$, [deg]')


set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')