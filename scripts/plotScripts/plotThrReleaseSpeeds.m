figure('Name','Tether Release Speeds')

for ii = 1:size(tsc.thrReleaseSpeeds.Data,2)
    subplot(size(tsc.thrReleaseSpeeds.Data,2),1,ii)
    plot(tsc.thrReleaseSpeeds.Time,tsc.thrReleaseSpeeds.Data(:,ii),...
        'LineStyle','-','Color','k','LineWidth',1.5)
    hold on
    plot(tsc.cmdThrReleaseSpeeds.Time,tsc.cmdThrReleaseSpeeds.Data(:,ii),...
        'LineStyle','--','Color','r','LineWidth',1.5)
    xlabel('Time, [s]')
    ylabel({sprintf('Winch %d Speed',ii),'Command [m/s]'})
end

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')