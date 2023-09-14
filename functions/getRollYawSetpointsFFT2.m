function [aRoll,bRoll,aYaw,bYaw,FREQ] = getRollYawSetpointsFFT2(tscP,n)

tsc2=tscP.resample(0.01);
%%
ind=find(tsc2.lapNumS.Data==max(tsc2.lapNumS.Data)-2);
times=tsc2.eulerAngles.Time(ind);
times=times-times(1);

rolls=squeeze(tsc2.eulerAngles.Data(1,ind)');
yaws=squeeze(tsc2.eulerAngles.Data(3,ind)');

[aRoll,bRoll, yFitRoll]=Fseries(times,rolls,n);
[aYaw,bYaw, yFitYaw]=Fseries(times,yaws,n);


FREQ=2*pi/times(end);

end