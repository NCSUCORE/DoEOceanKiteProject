clc 
% clear all
close all

direc = 'G:\Shared drives\Kite Experimentation\Pool testing\Friday Pool Test\06 16 21\Data'
listing =  dir(direc) 
testCond = '\0-77\mvd'
saveFig = 0
saveDir = strcat('output',testCond)
status = mkdir(saveDir)
runs = [62];
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
    runStart = find(tsc.turns_w1.Data(ind:end) < tsc.turns_w1.Data(ind) , 1)+ind
    ind = runStart;
    runStart = find(tsc.turns_w1.Data(ind:end) < tsc.turns_w1.Data(ind) , 1)+ind
    ind = runStart;
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

% simCtrlStart = find(tscSim.rollSP.Data < 180 , 1);
% T = tscSim.rollSP.Time(simCtrlStart);
% simData = reSampleDataUsingTime(tscSim,T,T+30);
%%
close all
j = 1
for i = 1:numel(runs)
%%
% if i == 1 
% j=3
% figure(j); hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% plot(runData{i}.rollSP,'--','LineWidth',1.5,...
%     'DisplayName','Set Point')
% j = j+1;
% 
% %   if simComp == 1
% figure(j); hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% % %     vels=simData.velCMvec.Data(:,:,:);
% % %     velMag= squeeze(sqrt(sum((vels).^2,1)))/0.77;
% % %     plot(simData.velCMvec.Time,velMag,':','LineWidth',1.5,...
% % %         'DisplayName','Simulation')
% % j = j+1;
% figure(j); hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% %     plot(simData.gndTenVecs,':','LineWidth',1.5,...
% %         'DisplayName','Simulation')
% j = j+1
% end
%%
j = plotExpPowAug(runData,i,j,runs(i));
j = plotExpThrTen(runData,i,j,runs(i));
j = plotExpData(runData,'yawDeadRec','yLegend','Yaw [deg]',...
    'legendEntry',sprintf('Run %d',runs(i)),'dataScale',1,...
    'runNum',i,'figNum',j)
j = plotExpData(runData,'kiteRoll','yLegend','Roll [deg]',...
    'legendEntry',sprintf('Run %d',runs(i)),'dataScale',180/pi,...
    'runNum',i,'figNum',j)
j = plotExpData(runData,'kite_elev','yLegend','Angle [deg]',...
    'legendEntry',sprintf('Elevation Run %d',runs(i)),'dataScale',1,...
    'runNum',i,'figNum',j)
j = plotExpData(runData,'kite_azi','yLegend','Angle [deg]',...
    'legendEntry',sprintf('Azimuth Run %d',runs(i)),'dataScale',1,...
    'runNum',i,'figNum',j-1)
% figure(j); hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% plot(runData{i}.rollSP,'--','LineWidth',1.5,...
%     'DisplayName','Set Point')
% % plot(-1*(simData.rollDeg-180),':','LineWidth',1.5,...
% %     'DisplayName','Simulation')
% end
% plot(runData{i}.kiteRoll*180/pi,'LineWidth',1.5,...
%     'DisplayName',sprintf('Exp Run %d',runs(i)))
% xlabel 'Time [s]'
% ylabel 'Roll [deg]'
% legend
% set(gca,'FontSize',15)
% j = j+1;
% if i == numel(runs) && saveFig == 1
%     saveas(gcf,strcat(saveDir,'\rollMVD.png'))
%     saveas(gcf,strcat(saveDir,'\rollMVD.fig'))
% end
% %Roll + Velo Aug
% figure(j);
% set(gcf,'Position',[100 100 900 400])
% subplot(2,1,1); hold on; grid on;
% if i == 1
% plot(runData{i}.rollSP,'--k','LineWidth',1.5,...
%     'DisplayName','Set Point')
% % plot(-1*(simData.rollDeg-180),':','LineWidth',1.5,...
% %     'DisplayName','Simulation')
% end
% plot(runData{i}.kiteRoll*180/pi,'k','LineWidth',1.5,...
%     'DisplayName',sprintf('Exp Run %d',runs(i)))
% % xlabel 'Time [s]'
% ylabel 'Roll [deg]'
% legend
% set(gca,'FontSize',15)
% 
% subplot(2,1,2); hold on; grid on;
% plot(runData{1}.kite_azi.Time(1:end-1),velAug2,'LineWidth',1.5,...
%     'DisplayName',sprintf('Exp Run - %d 1Hz Filter',runs(i)))
% xlabel 'Time [s]'
% ylabel ({'Power','Augmentation'})
% set(gca,'FontSize',15)
% ylim([0 3])
% % sgtitle('$v_{tow}$ = 0.77 m/s  60 Deg Roll 80 Deg Yaw 7.5 s period','FontSize',18)
% sgtitle('$v_{tow}$ = 0.77 m/s  30 Deg Roll 8 s period','FontSize',18)
% 
% j = j+1;
% if i == numel(runs) && saveFig == 1
%     saveas(gcf,strcat(saveDir,'\rollMVD.png'))
%     saveas(gcf,strcat(saveDir,'\rollMVD.fig'))
% end
% 
% 
% figure(j); hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% if i == 1
% plot(runData{i}.yawSP,'--','LineWidth',1.5,...
%     'DisplayName','Set Point')
% % plot(simData.yawDeg-180,':','LineWidth',1.5,...
% %     'DisplayName','Simulation')
% end
% plot(runData{i}.kiteYaw,'LineWidth',1.5,...
%     'DisplayName',sprintf('Exp Run %d',runs(i)))
% xlabel 'Time [s]'
% ylabel 'Yaw [deg]'
% legend
% set(gca,'FontSize',15)
% if i == numel(runs) && saveFig == 1
%     saveas(gcf,strcat(saveDir,'\yawMVD.png'))
%     saveas(gcf,strcat(saveDir,'\yawMVD.fig'))
% end
% j = j+1;
% 
% % figure(j); hold on; grid on;
% % set(gcf,'Position',[100 100 800 400])
% % if i == 1
% % plot(runData{i}.rollSP,'--','LineWidth',1.5,...
% %     'DisplayName','SP')
% % plot(-1*(simData.-180),':','LineWidth',1.5,...
% %     'DisplayName','Simulation')
% % end
% % plot(runData{i}.kiteRoll,'LineWidth',1.5,...
% %     'DisplayName',sprintf('Exp Run %d',runs(i)))
% % xlabel 'Time [s]'
% % ylabel 'Pitch [deg]'
% % legend
% % set(gca,'FontSize',15)
% % j = j+1;
% 
% figure(j); hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% if i == 1
% % plot(simData.phi*180/pi,':','LineWidth',1.5,...
% %     'DisplayName','Simulation')
% end
% plot(runData{i}.kite_azi,'LineWidth',1.5,...
%     'DisplayName',sprintf('Exp Run %d',runs(i)))
% xlabel 'Time [s]'
% ylabel 'Azimuth Angle [deg]'
% set(gca,'FontSize',15)
% legend
% if i == numel(runs) && saveFig == 1
%     saveas(gcf,strcat(saveDir,'\aziMVD.png'))
%     saveas(gcf,strcat(saveDir,'\aziMVD.fig'))
% end
% j = j+1;
% 
% figure(j); hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% if i == 1
% % plot(simData.theta*-180/pi,':','LineWidth',1.5,...
% %     'DisplayName','Simulation')
% end
% plot(runData{i}.kite_elev,'LineWidth',1.5,...
%     'DisplayName',sprintf('Exp Run %d',runs(i)))
% xlabel 'Time [s]'
% ylabel 'Elevation Angle [deg]'
% set(gca,'FontSize',15)
% legend
% if i == numel(runs) && saveFig == 1
%     saveas(gcf,strcat(saveDir,'\elMVD.png'))
%     saveas(gcf,strcat(saveDir,'\elMVD.fig'))
% end
% j = j+1;

j = 1;
end
%% 
velAngle = plotExpVelAng(runData{1},0.77,3);
tanRoll = plotExpTanRoll(runData{1});

% figure; hold on; grid on;
% set(gcf,'Position',[100 100 800 400])
% plot(runData{1}.kite_azi.Time,tanRoll*180/pi,'DisplayName','Tan Roll')
% plot(runData{1}.kite_azi.Time(1:end-1),velAngle*180/pi,'DisplayName','Vel Angle')
% xlabel('Time [s]')
% legend
% ylabel('Angle [deg]')