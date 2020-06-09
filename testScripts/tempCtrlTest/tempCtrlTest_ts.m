% temporary script to test controllers in isolation

% load('exp20Errors.mat')
load('SimErrors.mat')
timeExp = timeSim;
load('ayazThreeTetCtrl.mat');

ctrl = fltCtrl;

ignoreVals = 1;



pitchErrorWs = timeseries(pitchError(ignoreVals:end),timeExp(ignoreVals:end));
rollErrorWs = timeseries(rollError(ignoreVals:end),timeExp(ignoreVals:end));
altiErrorWs = timeseries(altiError(ignoreVals:end)./100,timeExp(ignoreVals:end));

simWithMonitor('tempCtrlTest');

parseLogsout;

if exist('fn','var')
    fn = fn+1;
else
    fn = 1;
end
figure(fn);
tetReleaseSpeeds = tsc.winchSpeeds.Data';
timeTest = tsc.winchSpeeds.Time;
vectorPlotter(timeTest,tetReleaseSpeeds,{'rgb','-'},...
    {'$u_{port}$','$u_{aft}$','$u_{stbd}$'},'Speed (m/s)','Tether release speeds');



