figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Ctrl Surf Deflections');
subplot(4,1,1)
plot(tsc.FNetBdy.Time,tsc.flapDeflDeg.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{flap}$, [deg]')

subplot(4,1,2)
plot(tsc.FNetBdy.Time,tsc.ailDeflDeg.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{ail}$, [deg]')

subplot(4,1,3)
plot(tsc.FNetBdy.Time,tsc.elevDeflDeg.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{elev}$, [deg]')

subplot(4,1,4)
plot(tsc.FNetBdy.Time,tsc.rudDeflDeg.Data,...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$\delta_{rud}$, [deg]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')