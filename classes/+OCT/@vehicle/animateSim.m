function animateSim(obj,tsc,fltCtrl)
%ANIMATESIM Function to animate a simulation
tsc = resampleTSC(tsc,0.1);

%%%%% START HERE TOMORROW MITCHELL
fs = fieldnames(obj.surfaceOutlines);
for ii = 1:length(fs)
    aeroSurfPts{ii} = obj.surfaceOutlines.(fs{ii}).Value;
end


end

