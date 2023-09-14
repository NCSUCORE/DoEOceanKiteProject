function [aRoll,bRoll,aYaw,bYaw,FREQ] = getRollYawSetpointsFFT(tscP)

tsc2=tscP.resample(0.01);
%%
ind=find(tsc2.lapNumS.Data==max(tsc2.lapNumS.Data)-2);
times=tsc2.eulerAngles.Time(ind);
times=times-times(1);

rolls=squeeze(tsc2.eulerAngles.Data(1,ind)');
yaws=squeeze(tsc2.eulerAngles.Data(3,ind)');

[aRoll,bRoll, yFitRoll]=Fseries(times,rolls,50);
[aYaw,bYaw, yFitYaw]=Fseries(times,yaws,50);


FREQ=2*pi/times(end);

end