clc 
clear all
close all
date = '06 30 21'
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



