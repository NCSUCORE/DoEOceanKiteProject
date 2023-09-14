function [rollAmp, yawAmp, rollFreq, yawFreq, rollPhase, yawPhase] = getRollYawSetpoints(tsc)

tsc2=tsc.resample(0.01);
%%
ind=find(tsc2.lapNumS.Data==max(tsc2.lapNumS.Data)-1);
times=tsc2.eulerAngles.Time(ind);
times=times-times(1);

rolls=squeeze(tsc2.eulerAngles.Data(1,ind)');
yaws=squeeze(tsc2.eulerAngles.Data(3,ind)');

rollSine=sineFit(times,rolls);
yawSine=sineFit(times,yaws);
%       Output: SineParams(1): offset (offs)
%               SineParams(2): amplitude (amp)
%               SineParams(3): frequency (f)
%               SineParams(4): phaseshift (phi)

rollAmp=0.7*rollSine(2);
rollFreq=rollSine(3)*2*pi;
yawFreq=rollFreq;
rollPhase=rollSine(4);
yawAmp=0.7*yawSine(2);
yawPhase=yawSine(4);


rollAmp=0.7*max(rolls)
rollFreq=(1/times(end))*2*pi;
yawFreq=rollFreq;
%rollPhase=0;
yawAmp=0.7*max(yaws);
%yawPhase=yawSine(4)-rollSine(4);

%%

tsc2=tsc.resample(0.01);

ind=find(tsc2.lapNumS.Data==max(tsc2.lapNumS.Data)-1);
times=tsc2.eulerAngles.Time(ind);
times=times-times(1);

velos=squeeze(tsc2.velocityVec.mag.Data(ind));
sEstim=cumtrapz(velos)/trapz(velos);


end