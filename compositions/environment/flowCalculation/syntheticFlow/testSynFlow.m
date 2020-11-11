clear
clc

loadComponent('ayazSynFlow');

[f,a] = env.water.generateData();

for ii = 1:numel(f.Time)
   valFlow(ii) = interp1(a.Data(:,1,1),f.Data(:,1,ii),50); 
end

simOut = sim('syntheticFlow_th');

plot(f.Time./60,valFlow);
hold on
plot(simOut.tout./60,squeeze(simOut.simValOut.Data(1,1,:)),'--');

figure
F = animatedPlot(f,a,'plotTimeStep',2);

