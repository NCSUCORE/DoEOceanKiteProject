clc 
clear all
close all

direc = 'G:\Shared drives\Kite Experimentation\Pool testing\Friday Pool Test\06 16 21\Data'
listing =  dir(direc) 
runs = 28;
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
    runStart = find(tsc.rollSP.Data(ind:end) > 0 , 1)+ind;
    if isempty(runStart)
        j=j+1;
        continue
    end
        
    T = tsc.winch1LinPos.Time(runStart);
    runData{i} = reSampleDataUsingTime(tsc,T,T+30);
    i = i+1;
    runCount = runCount+1
    ind = [];
    runStart = [];
end
[~,velAug] = estExpVelMag(runData{1},3);
figure
plot(runData{1}.ax.Time(1:end-1),velAug)
ylim([0 4])

figure
runData{1}.kiteRoll.plot
hold on
runData{1}.rollSP.plot
runData{1}.kiteYaw.plot
runData{1}.yawSP.plot

figure
runData{1}.kite_elev.plot
hold on
runData{1}.kite_azi.plot
legend('Elevation','Azimuth')
xlabel('Time [s]')
ylabel('Angle [deg]')
