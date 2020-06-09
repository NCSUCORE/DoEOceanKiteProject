figure; 
plot(tsc.LThr.time,tsc.LThr.data)
grid on
hold on
plot(tsc.LThrSP.time,tsc.LThrSP.data)
% scatter(tsc.LThrSP.Time(tsc.currentPathVar.Data<0.005),tsc.LThrSP.Data(tsc.currentPathVar.Data<0.005),'r')
xlim([500,800])

title('Tether Length vs. Tether Length SP')
xlabel('Time (s)')
ylabel('Length (m)')
legend('Tether Length','Tether Length SP') %,' SP at S = 0')

set(findall(gcf,'Type','axes'),'FontSize',16)

grid on
box off