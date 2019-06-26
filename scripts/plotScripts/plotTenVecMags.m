for ii = 1:numel(tsc.airTenVecBusArry)
    figure('Position',[ 1 41 1920 963],'Units','pixels','Name',sprintf('Thr %d Air Tens Mag',ii));
    subplot(numel(tsc.airTenVecBusArry),1,ii)
    plot(tsc.airTenVecBusArry(ii).tenVec.Time,squeeze(sqrt(sum(tsc.airTenVecBusArry(ii).tenVec.Data(:,:,:).^2))),...
        'LineStyle','-','Color','k','LineWidth',1.5,'DisplayName','Air')
    grid on
    hold on
    plot(tsc.gndTenVecBusArry(ii).tenVec.Time,squeeze(sqrt(sum(tsc.gndTenVecBusArry(ii).tenVec.Data(:,:,:).^2))),...
        'LineStyle','--','Color',[0.5 0.5 0.5],'LineWidth',1.5,'DisplayName','Ground')
    xlabel('Time, [s]')
    ylabel(sprintf('Thr %d $ |F^{Gnd}| $, [N]',ii))
    legend
    
    set(findall(gcf,'Type','axes'),'FontSize',20)
    linkaxes(findall(gcf,'Type','axes'),'x')
    
end