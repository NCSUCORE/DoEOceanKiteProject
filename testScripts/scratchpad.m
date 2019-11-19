t = 1;
uSt = ones(2,2,2,5);
uTh = ones(2,2,2,5);



ff = linspace(env.waterTurb.minFreqHz.Value,env.waterTurb.maxFreqHz.Value,env.waterTurb.numMidFreqs.Value);
rf = repmat(ff',1,2,2,1)
u = sum((abs(uSt).*sin(rf*2*pi*t + uTh)),4);