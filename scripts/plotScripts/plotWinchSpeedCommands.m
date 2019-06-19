figure('Position',[ 1 41 1920 963],'Units','pixels','Name','Winch Speed Commands');

for ii = 1:size(tsc.winchSpeeds.Data,2)
    subplot(size(tsc.winchSpeeds.Data,2),1,ii)
    plot(tsc.winchSpeeds.Time,tsc.winchSpeeds.Data(:,ii),...
        'LineStyle','-','Color','k','LineWidth',1.5)
    xlabel('Time, [s]')
    ylabel({sprintf('Winch %d Speed',ii),'Command [m/s]'})
end

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')