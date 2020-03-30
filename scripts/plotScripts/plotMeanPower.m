timeMat = [];
lapNum = tsc.lapNumS.data;
lapTime = tsc.lapNumS.time; 
for i = 1:length(lapNum)-1
     
    if lapNum(i + 1) > lapNum(i)
        
        timeMat = [timeMat,lapTime(i)];
        
    end
    
end
iterPower = resample(tsc.avgPower, timeMat);
figure
stairs(squeeze(iterPower.Data),...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Lap Number')
ylabel({'Mean','Power [kw]'})
% title('Mean Power vs. Iteration Number')
set(findall(gcf,'Type','axes'),'FontSize',20)
xlim([0,lapNum(end)])
grid on
box off