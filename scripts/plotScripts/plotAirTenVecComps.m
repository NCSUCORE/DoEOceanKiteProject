for ii = 1:numel(tsc.airTenVecBusArry)
    fn=fn+1;
    figure(fn);
    set(gcf,'Position',locs(fn,:),[ 1 41 1920 963],'Units','pixels','Name',sprintf('Thr %d Air Node Frce Components',ii));
    subplot(3,1,1)
    plot(tsc.airTenVecBusArry(ii).tenVec.Time,squeeze(tsc.airTenVecBusArry(ii).tenVec.Data(1,:,:)),...
        'LineStyle','-','Color','k','LineWidth',1.5)
    grid on
    xlabel('Time, [s]')
    ylabel(sprintf('Thr %d $F_x^{Gnd}, [N]$',ii))
    
        subplot(3,1,2)
    plot(tsc.airTenVecBusArry(ii).tenVec.Time,squeeze(tsc.airTenVecBusArry(ii).tenVec.Data(2,:,:)),...
        'LineStyle','-','Color','k','LineWidth',1.5)
    grid on
    xlabel('Time, [s]')
    ylabel(sprintf('Thr %d $F_y^{Gnd}, [N]$',ii))
    
        subplot(3,1,3)
    plot(tsc.airTenVecBusArry(ii).tenVec.Time,squeeze(tsc.airTenVecBusArry(ii).tenVec.Data(3,:,:)),...
        'LineStyle','-','Color','k','LineWidth',1.5)
    grid on
    xlabel('Time, [s]')
    ylabel(sprintf('Thr %d $F_z^{Gnd}, [N]$',ii))
    
    
    set(findall(gcf,'Type','axes'),'FontSize',20)
    linkaxes(findall(gcf,'Type','axes'),'x')
    
end