figure('Position',[ 1 41 1920 963],'Units','pixels');

for ii = 1:size(tsc.winchSpeedCommands.Data,2)
    subplot(size(tsc.winchSpeedCommands.Data,2),1,ii)
    plot(tsc.winchSpeedCommands.Time,tsc.winchSpeedCommands.Data(:,ii),...
        'LineStyle','-','Color','k','LineWidth',1.5)
    xlabel('Time, [s]')
    ylabel({sprintf('Winch %d Speed',ii),'Command [m/s]'})
end

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')