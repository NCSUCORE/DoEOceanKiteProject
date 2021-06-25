function [j] = plotExpPowAug(runData,i,j,run)
%Plots velocity augmentation based on an experimental data run
[~,velAug] = estExpVelMag(runData{i},1);
figure(j); hold on; grid on;
set(gcf,'Position',[100 100 800 400])
    plot(runData{i}.kite_azi.Time(1:end-1),velAug.^3,'LineWidth',1.5,...
    'DisplayName',sprintf('Exp Run - %d 1Hz Filter',run))
ylim([0 20])
legend
ylabel({'Power','Augmentation'})
xlabel 'Time [s]'
set(gca,'FontSize',15)
j=j+1;
end

