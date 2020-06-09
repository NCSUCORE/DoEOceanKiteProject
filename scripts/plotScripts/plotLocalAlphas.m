figure('Name','Local AoAs')

for ii = 1:numel(tsc.alphaLocal.data(:,:,1))
    subplot(numel(tsc.alphaLocal.data(:,:,1)),1,ii)
    plot(tsc.alphaLocal.Time,squeeze(tsc.alphaLocal.data(:,ii,:)),...
        'LineWidth',1.5,'Color','k','LineStyle','-')
    grid on
    xlabel('Time, t [s]')
    ylabel({'AoA',sprintf('Surf %d',ii),'[deg]'})
end

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')