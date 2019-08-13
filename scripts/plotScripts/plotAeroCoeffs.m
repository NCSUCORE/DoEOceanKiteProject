figure('Name','Aero Coeffs')

for ii = 1:numel(tsc.dynPress.Data(1,:,1))
    subplot(numel(tsc.dynPress.Data(1,:,1)),1,ii)
    plot(tsc.CL.Time,squeeze(tsc.CL.Data(1,ii,:)),...
        'LineStyle','-','Color','k','LineWidth',1.5);
    grid on
    hold on
    plot(tsc.CD.Time,squeeze(tsc.CD.Data(1,ii,:)),...
        'LineStyle','--','Color',0.5*[1 1 1],'LineWidth',1.5);
    xlabel('Time, t [s]')
    ylabel(sprintf('$C_L^{%d}$,  $C_D^{%d}$',ii,ii),'Interpreter','Latex')
    
end

% set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')