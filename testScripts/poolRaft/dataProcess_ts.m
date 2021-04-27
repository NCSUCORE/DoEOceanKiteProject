%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear

%% Process Test Data
selPath = uigetdir;
listing = dir(selPath);

% selPath2 = uigetdir;
% listing2 = dir(selPath2);
figure; hold on; grid on;
for i = 3:numel(listing)-1
    load(strcat(selPath,'\',listing(i).name));
    tscData{i-2} = tsc;
    if i > 4
        a = find(tsc.speedCMD1.Data> 1,1);
        speed(i-2) = tsc.speedCMD1.Data(a);
        tscData{i-2}.linSpeed = tsc.speedCMD1.Data(a);
    else
        a = 1;
        speed(i-2) = 0;
        tscData{i-2}.linSpeed = 0;
    end
    tscData{i-2}.a = a;
    plot(tsc.speedCMD1.Time(a:end),tsc.speedCMD1.Data(a:end))
end
desRPM = [0 0 50 50 50 50 50 50 65 65 65 80 80 80 50 50 50 80 80 80,...
    50 50 50 80 80 80 50 50 50 80 80 80 50 50 50 80 80 80];
figure
plot(speed*30,'x','DisplayName','Commanded RPM')
hold on
plot(desRPM,'o','DisplayName','Test Plan RPM')
xlabel('Test Run')
ylabel('RPM')
legend location southeast


