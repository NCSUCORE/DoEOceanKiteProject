figure; 
tsc.LThr.plot
grid on
hold on
tsc.LThrSP.plot
scatter(tsc.LThrSP.Time(tsc.currentPathVar.Data<0.005),tsc.LThrSP.Data(tsc.currentPathVar.Data<0.005),'r')
title('Tether Length vs. Tether Length SP')
xlabel('Time (s)')
ylabel('Length (m)')
legend('Tether Length','Tether Length SP',' SP at S = 0')