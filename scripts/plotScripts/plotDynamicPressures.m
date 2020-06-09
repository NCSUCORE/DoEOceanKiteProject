figure('Name','Dyn Press');

for ii = 1:numel(tsc.dynPress.Data(1,:,1))
   subplot(numel(tsc.dynPress.Data(1,:,1)),1,ii)
   plot(tsc.dynPress.Time,squeeze(tsc.dynPress.Data(1,ii,:)),...
       'LineStyle','-','Color','k','LineWidth',2);
   grid on
   xlabel('Time, t [s]')
   ylabel({'Dyn Press',sprintf('Surf %d',ii)})
   
end

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')