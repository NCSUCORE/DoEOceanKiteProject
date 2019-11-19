path = lemOfBooth(linspace(0,1,1000),[0.8 1.4 0 0 100],[0 0 0]);

plot(path(2,:),path(3,:),...\
    'LineWidth',1.5,'Color','k')
box off
grid off
axes off
daspect([1 1 1])
set(gca,'Visible','off')
