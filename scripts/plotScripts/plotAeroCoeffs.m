figure('Name','Aero Loads')
numPlots = size(tsc.FLiftBdyPart.Data(:,:,1),2);
mag = sqrt(sum(tsc.FLiftBdyPart.Data.^2,1))...
    + sqrt(sum(tsc.FDragBdyPart.Data.^2,1));

% Plot magnitudes at fluid dynamic centers
for ii = 1:numPlots
    subplot(numPlots,1,ii)
    plot(tsc.FLiftBdyPart.Time,squeeze(mag(:,ii,:)),...
        'Color','k','LineWidth',1.5)
    grid on
    xlabel('Time [s]')
    ylabel(sprintf('$F_%d^{Fluid}$',ii))
end

% set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')
set(findall(gcf,'Type','axes'),'FontSize',18)
clear numplots ii mag