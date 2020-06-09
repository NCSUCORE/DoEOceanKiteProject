figure('Name','Spherical Velocity');

subplot(3,1,1)
plot(tsc.positionVec.Time,squeeze(dot(tsc.velocityVec.Data,tsc.positionVec.Data./sqrt(sum((tsc.positionVec.Data).^2,1)))),...
    'LineWidth',1.5','Color','k');
grid on
xlabel('Time, t [s]')
ylabel('Radial Speed [m/s]')

set(findall(gcf,'Type','axes'),'FontSize',20)
linkaxes(findall(gcf,'Type','axes'),'x')

% Haven't written the other components yet because I don't need them yet