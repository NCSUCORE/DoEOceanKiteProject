figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Fluid Dynamic Coefficients');
subplot(5,1,1)
plot(tsc.netLiftCoeff.Time,squeeze(tsc.netLiftCoeff.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$C_{Lift}$')

subplot(5,1,2)
plot(tsc.netDragCoeff.Time,squeeze(tsc.netDragCoeff.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$C_{Drag}$')

subplot(5,1,3)
plot(tsc.netRollMomentCoeff.Time,squeeze(tsc.netRollMomentCoeff.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$C_{M,roll}$')

subplot(5,1,4)
plot(tsc.netPitchMomentCoeff.Time,squeeze(tsc.netPitchMomentCoeff.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$C_{M,pitch}$')

subplot(5,1,5)
plot(tsc.netYawMomentCoeff.Time,squeeze(tsc.netYawMomentCoeff.Data),...
    'LineStyle','-','Color','k','LineWidth',1.5)
xlabel('Time, [s]')
ylabel('$C_{M,yaw}$')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')