function [j] = plotExpThrTen(runData,i,j,run)
%Plots tether tension based on an experimental data run
figure(j); hold on; grid on;
set(gcf,'Position',[100 100 800 400])
plot(runData{i}.LoadCell_N/2,'LineWidth',1.5,...
    'DisplayName',sprintf('Exp Run %d',run))
legend
ylabel 'Tether Tension [N]'
xlabel 'Time [s]'
j = j+1;
end

