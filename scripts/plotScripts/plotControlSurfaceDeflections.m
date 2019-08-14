figure('Name','Ctrl Surf Deflections');

numSurfs = numel(tsc.ctrlSurfDeflection.Data(:,:,1));
for ii = 1:numSurfs
    subplot(numSurfs,1,ii)
    plot(tsc.ctrlSurfDeflection.Time,...
        squeeze(tsc.ctrlSurfDeflection.Data(ii,:,:)),...
    'LineStyle','-','Color','k','LineWidth',1.5)
    xlabel('Time, [s]')
    ylabel(sprintf('$ \\delta_{%d}$, [deg]',ii))
end

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')