function [j] = plotVelAugTrack(runData,i,j,title)
%Plots velocity augmentation based on an experimental data run
[~,velAug] = estExpVelMag(runData{i},1);
figure(j);
set(gcf,'Position',[100 100 900 400])

subplot(2,1,1); hold on; grid on;
if isfield(runData{i},'yawDeadRec')
    plot(runData{i}.kiteRoll*180/pi,'k');
else
    plot(runData{i}.kiteRoll,'k');
end

plot(runData{i}.rollSP,'--k');

if max(runData{i}.yawSP.Data) ~= 0
    if isfield(runData{i},'yawDeadRec')
        plot(runData{i}.yawDeadRec,'r');
    else
        plot(runData{i}.kiteYaw,'r');
    end
    plot(runData{i}.yawSP,'--r');
end

ylabel 'Angle [deg]'
ylim([-100 100])
legend('Roll','Roll SP','Yaw','Yaw SP')
set(gca,'FontSize',15)
subplot(2,1,2); hold on; grid on;
plot(runData{i}.kite_azi.Time(1:end-1),velAug.^3)
set(gca,'FontSize',15)
ylim([0 20])
yticks([0  5 10 15 20])
ylabel({'Power','Augmentation'})
xlabel 'Time [s]'
sgtitle(title,'FontSize',18)
j=j+1;
end

