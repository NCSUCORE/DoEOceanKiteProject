function [j] = plotExpVelAug(runData,i,j,run)
%Plots velocity augmentation based on an experimental data run
[~,velAug] = estExpVelMag(runData{i},1);
figure(j); hold on; grid on;
set(gcf,'Position',[100 100 800 400])
    plot(runData{i}.kite_azi.Time(1:end-1),velAug,'LineWidth',1.5,...
    'DisplayName',run)
set(gca,'FontSize',15)
ylim([0 4])
legend
ylabel '$|v_{kite}|/|v_{tow}|$'
xlabel 'Time [s]'

j=j+1;
end

