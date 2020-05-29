function [elevCmd, winchCmd] = combinedCmd(s,ctrlVec,spdVec,TL,TLSP,lapCount,elevDeflIn,firstSpoolLap)
sc = ctrlVec(1);
sw = ctrlVec(2);
vOut = spdVec(1);
vIn = spdVec(2);
deIn = elevDeflIn;
deOut = 0;

if s>=sc-sw && s<=sc+sw
    elevCmd = deIn;
elseif s>=0.5+sc-sw && s<=0.5+sc+sw
    elevCmd = deIn;
else
    elevCmd = deOut;
end
if lapCount >= firstSpoolLap 
    TLError = TL-TLSP;
    if TLError > 0
        winchCmd=vOut;
    else
        winchCmd=vIn;
    end
else
    winchCmd = 0;
    elevCmd = deOut;
end
    

end