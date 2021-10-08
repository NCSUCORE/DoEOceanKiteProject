clc 
<<<<<<< Updated upstream
clear all
close all
date = '09 03 21'
=======
% clear all
% close all
date = '07 14 21'
>>>>>>> Stashed changes
direc = strcat('G:\Shared drives\Kite Experimentation\Pool testing\Friday Pool Test\',date,'\Data')
listing =  dir(direc) 
testCond = strcat(date,'\0-77\mvd')
saveFig = 0
saveDir = strcat('output\',testCond)
status = mkdir(saveDir)
plotData = 1
runs = [10];
runQuery = min(runs);
runCount = min(runs);
runLim = max(runs);
i = 1;
j = 1;
while runCount <= runLim
    if listing(j).isdir ~= 1
        load(strcat(direc,'\',listing(j).name));
    else
        j = j+1;
        continue
    end
    
    ind = find(tsc.runCounter.Data == runCount,1);
    if isempty(ind)
        j = j+1;
        continue
    end
    runStart = find(tsc.rollSP.Data(ind:end) ~= 0, 1)+ind;
    ind = runStart;
%     runStart = find(tsc.turns_w1.Data(ind:end) < tsc.turns_w1.Data(ind) , 1)+ind
%     ind = runStart;
%     runStart = find(tsc.turns_w1.Data(ind:end) < tsc.turns_w1.Data(ind) , 1)+ind
%     ind = runStart;
%     runStart = find(tsc.turns_w1.Data(ind:end) < tsc.turns_w1.Data(ind) , 1)+ind
    if isempty(runStart)
        j=j+1;
        continue
    end
        
    T = tsc.winch1LinPos.Time(runStart);
    runData{i} = reSampleDataUsingTime(tsc,T,T+30);
    i = i+1;
    if i > numel(runs)
        break
    end
    runCount = runs(i);
    ind = [];
    runStart = [];
end
<<<<<<< Updated upstream
figure;
plot(runData{1, 1}.rollCmd_PID);hold on;
plot(runData{1, 1}.heirAliCmd/-1)
plotsq(runData{1,1}.RollCMD_deg);
plot(runData{1, 1}.rollCmd_PID*.8+runData{1,1}.heirAliCmd*-.2);
legend('PID','Path','Comb','PredComb')

figure;
hold on
plot(runData{1,1}.rollCmd_PID)
plotsq(runData{1,1}.desiredMoment.Time,runData{1,1}.desiredMoment.Data(1,1,:))

figure;
hold on
plot(runData{1,1}.yawCmd_PID)
plotsq(runData{1,1}.desiredMoment.Time,runData{1,1}.desiredMoment.Data(2,1,:)*20)
=======
figure;plot(runData{1, 1}.yawSP)
hold on
plot(runData{1, 1}.rollSP)
>>>>>>> Stashed changes
% runs = {'0.49 m/s','0.65 m/s','0.77 m/s'}
% simCtrlStart = find(tscSim.rollSP.Data < 180 , 1);
% T = tscSim.rollSP.Time(simCtrlStart);
% simData = reSampleDataUsingTime(tscSim,T,T+30);
%% Calculate Mean Tension
% for i = 1:numel(runs)
%     ten(i) = rms(runData{i}.LoadCell_N.Data(1000:2000)/2)
%     tenPeak(i) = max(runData{i}.LoadCell_N.Data(1000:2000)/2)
%     
% end
% 
% 
%     y = ten
%     vel = [.78 .88 .69 ];
% %     constraint = [1 0 0];  % Ignore possible x^2 term
% % polyFunc = @(p) polyval(p.*constraint,vel);
% % objectiveFunc = @(p) (y - polyFunc(p)).^2;
% % p0 = [200 0 0];  % It pays to have a realistic initial guess
% % fminsearch( objectiveFunc, p0 );
%     figure(5)
%     plot(vel,ten,'x')
<<<<<<< Updated upstream
%%
=======
% %%
>>>>>>> Stashed changes
% if plotData == 1
%     runs={'Roll','Roll and Yaw','Allocated Roll and Yaw'};
% close all
% j = 1
% color={[0    0.4470    0.7410],...
%     [0.8500    0.3250    0.0980],...
%     [0.9290    0.6940    0.1250],...
%     [0.4940    0.1840    0.5560],...
%     [0.4660    0.6740    0.1880],...
%     [0.3010    0.7450    0.9330],...
%     [0.6350    0.0780    0.1840]};
% for i = 1:3
% %%
% % if i == 1 
% % j=3
% % figure(j); hold on; grid on;
% % set(gcf,'Position',[100 100 800 400])
% % plot(runData{i}.rollSP,'--','LineWidth',1.5,...
% %     'DisplayName','Set Point')
% % j = j+1;
% % 
% % %   if simComp == 1
% % figure(j); hold on; grid on;
% % set(gcf,'Position',[100 100 800 400])
% % % %     vels=simData.velCMvec.Data(:,:,:);
% % % %     velMag= squeeze(sqrt(sum((vels).^2,1)))/0.77;
% % % %     plot(simData.velCMvec.Time,velMag,':','LineWidth',1.5,...
% % % %         'DisplayName','Simulation')
% % % j = j+1;
% % figure(j); hold on; grid on;
% % set(gcf,'Position',[100 100 800 400])
% % %     plot(simData.gndTenVecs,':','LineWidth',1.5,...
% % %         'DisplayName','Simulation')
% % j = j+1
% % end
% %%
% 
% [~,velAug] = estExpVelMag(runData{i},1);
% velAugMean(i) = mean(velAug(1500:2250))
% powAugMean(i) = mean(velAug(1500:2250).^3)
% % powAugPlot{i} = velAug(500:2300).^3
% j = plotExpPowAug(runData,i,j,runs{i});
% j = plotExpVelAug(runData,i,j,runs{i});
% % j = plotVelAugTrack(runData,i,j,'');
% % j = plotVelAugElev(runData,i,j,'',runs{i});
% % j = plotExpData(runData,'kiteRoll','yLegend','Roll [deg]',...
% %     'legendEntry','Roll','dataScale',1,...
% %     'runNum',i,'figNum',j,'Color','k');
% % j = plotExpData(runData,'rollSP','yLegend','Angle [deg]',...
% %     'legendEntry','Roll SP','dataScale',1,...
% %     'runNum',i,'figNum',j-1,'LineStyle','--','Color','k');
% % j = plotExpData(runData,'yawDeadRec','yLegend','Yaw [deg]',...
% %     'legendEntry','Yaw','dataScale',1,...
% %     'runNum',i,'figNum',j-1,'LineStyle','-','Color','r')
% % j = plotExpData(runData,'yawSP','yLegend','Angle [deg]',...
% %     'legendEntry','Yaw SP','dataScale',1,...
% %     'runNum',i,'figNum',j-1,'LineStyle','--','Color','r')
% % 
% % j = plotExpData(runData,'kite_elev','yLegend','Elevation [deg]',...
% %     'legendEntry',runs{i},'dataScale',1,...
% %     'runNum',i,'figNum',j,'Color',color{i});
% % 
% % j = plotExpData(runData,'kite_azi','yLegend','Azimuth [deg]',...
% %     'legendEntry',runs{i},'dataScale',1,...
% %     'runNum',i,'figNum',j,'Color',color{i})
% % j = plotExpData(runData,'LoadCell_N','yLegend','Tether Tension [N]',...
% %     'legendEntry',runs{i},'dataScale',1/2,...
% %     'runNum',i,'figNum',j,'Color',color{i});
% % j = plotExpData(runData,'kitevely','yLegend','Lateral Velocity [m/s]',...
% %     'legendEntry',runs{i},'dataScale',1,...
% %     'runNum',i,'figNum',j,'Color',color{i});
% % j = plotExpData(runData,'rollSP','yLegend','Angle [deg]',...
% %     'legendEntry',runs{i},'dataScale',1,...
% %     'runNum',i,'figNum',j-1,'LineStyle','--','Color',color{i});
% % [~,velAug] = estExpVelMag(runData{1},1);
% % 
% % figure('Position',[100 100 800 400])
% % subplot(2,1,1); grid on; hold on;
% % plot(runData{1}.kiteRoll,'k-','DisplayName','Roll')
% % plot(runData{1}.rollSP,'k--','DisplayName','Roll SP')
% % % plot(runData{1}.kiteYaw,'r-','DisplayName','Yaw')
% % % plot(runData{1}.yawSP,'r--','DisplayName','YawSP')
% % ylim([-100 100])
% % legend
% % ylabel 'Angle [deg]'
% % set(gca,'FontSize',15)
% % subplot(2,1,2); grid on; hold on;
% % plot(runData{1}.kiteRoll.Time(1:end-1),velAug.^3)
% % ylabel({'Power','Augmentation'})
% % ylim([0 15])
% % xlabel 'Time [s]'
% % sgtitle('Roll Only Setpoint Tracking','FontSize',20)
% % set(gca,'FontSize',15)
% j = 1
% end
% end
% 
% figure
% subplot(3,1,1); hold on; grid on;
% plot(runData{1,1}.kiteRoll*180/pi)
% plotsq(tscSim.eulerAngles.Time-1,tscSim.eulerAngles.Data(1,:,:)*180/pi)
% ylabel 'Roll [deg]'
% set(gca,'FontSize',15)
% subplot(3,1,2); hold on; grid on;
% plot(runData{1,1}.kitePitch*180/pi)
% plotsq(tscSim.eulerAngles.Time-1,tscSim.eulerAngles.Data(2,:,:)*180/pi)
% ylabel 'Pitch [deg]'
% set(gca,'FontSize',15)
% subplot(3,1,3); hold on; grid on;
% plot(runData{1,1}.yawDeadRec)
% plotsq(tscSim.eulerAngles.Time-1,tscSim.eulerAngles.Data(3,:,:)*180/pi-180)
% ylabel 'Yaw [deg]'
% xlabel 'Time [s]'
% legend('Exp','Sim')
% set(gca,'FontSize',15)
% 
% figure
% plot(runData{1,1}.kite_azi*-1)
% hold on
% plot(tscSim.phi*180/pi)
% legend('Experiment','Simulation')
% 
% figure; 
% plot(runData{1}.velAngleDes)
% hold on; grid on;
% plot(runData{1}.velAngle)
% legend('Vel Ang Des','Vel Ang')
% xlabel 'Time [s]'
% ylabel 'Angle [deg]'
% set(gca,'FontSize',15)
% 
% figure; 
% plot(runData{1}.tanRollDes*180/pi)
% hold on; grid on;
% plot(runData{1}.tanRoll*180/pi)
% plot(runData{1}.RollCMD_deg)
% legend('Tan Roll Des','Tan Roll','Aileron')
% xlabel 'Time [s]'
% ylabel 'Angle [deg]'
% set(gca,'FontSize',15)
% 
% 
% figure
% plot(runData{1}.kite_azi.Data,runData{1}.kite_elev.Data)
% xlabel 'Azimuth [s]'
% ylabel 'Elevation [deg]'
% set(gca,'FontSize',15)
% xlim([-70 70]);
% ylim([0 90]);