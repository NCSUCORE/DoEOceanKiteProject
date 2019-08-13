figure('Name','Tether Lengths');

for ii = 1:size(tsc.tetherLengths.Data,2)
    subplot(size(tsc.tetherLengths.Data,2),1,ii)
    plot(tsc.tetherLengths.Time,tsc.tetherLengths.Data(:,ii),...
        'LineStyle','-','Color','k','LineWidth',1.5)
    xlabel('Time, [s]')
    ylabel({sprintf('Tether %d',ii),' Length [m]'})
end

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')