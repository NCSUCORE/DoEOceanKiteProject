clc 
clear all
close all

direc = 'G:\Shared drives\Kite Experimentation\Pool testing\Friday Pool Test\06 23 21\Data'
listing =  dir(direc) 
testCond = '\0-77\mvd'
saveFig = 0
saveDir = strcat('output',testCond)
status = mkdir(saveDir)
runs = [48];
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
runs = {'0.49 m/s','0.65 m/s','0.77 m/s'}
% simCtrlStart = find(tscSim.rollSP.Data < 180 , 1);
% T = tscSim.rollSP.Time(simCtrlStart);
% simData = reSampleDataUsingTime(tscSim,T,T+30);
%%
close all
j = 1
for i = [1]
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
j = plotExpPowAug(runData,i,j,runs{i});
% j = plotExpThrTen(runData,i,j,runs{i});
j = plotExpData(runData,'kiteYaw','yLegend','Yaw [deg]',...
    'legendEntry',runs{i},'dataScale',1,...
    'runNum',i,'figNum',j)
% j = plotExpData(runData,'yawSP','yLegend','Yaw [deg]',...
%     'legendEntry',strcat('Set Point - ',' ',runs{i}),'dataScale',1,...
%     'runNum',i,'figNum',j-1,'LineStyle','--')
j = plotExpData(runData,'kiteRoll','yLegend','Roll [deg]',...
    'legendEntry',runs{i},'dataScale',1,...
    'runNum',i,'figNum',j)
% j = plotExpData(runData,'rollSP','yLegend','Roll [deg]',...
%     'legendEntry',strcat('Set Point - ',' ',runs{i}),'dataScale',1,...
%     'runNum',i,'figNum',j-1,'LineStyle','--')
j = plotExpData(runData,'kite_elev','yLegend','Elevation [deg]',...
    'legendEntry',runs{i},'dataScale',1,...
    'runNum',i,'figNum',j)
j = plotExpData(runData,'kite_azi','yLegend','Azimuth [deg]',...
    'legendEntry',runs{i},'dataScale',1,...
    'runNum',i,'figNum',j)
j = plotExpData(runData,'LoadCell_N','yLegend','Tether Tension [N]',...
    'legendEntry',runs{i},'dataScale',1/2,...
    'runNum',i,'figNum',j)
end