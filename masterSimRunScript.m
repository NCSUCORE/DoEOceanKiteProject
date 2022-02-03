
%% Input flow speed 
flwSpd = 1.75;
constXYZTFun_bs(flwSpd)
%% Input control parameters
period =7.25;
rollAmp = 56;
yawAmp = 85;
phaseOffset = .3;
spoolInSpeed = .4;
spoolOutSpeed = .15;
spoolOutElevator = -4;
spoolInElevator = .5;
jamesMultiCycleExpFun_bs(period,rollAmp,yawAmp,phaseOffset,spoolInSpeed,spoolOutSpeed,spoolOutElevator,spoolInElevator) 

%% Run simulation
modelVDataRunner_ts
%% Plot power

plotSimILCPower