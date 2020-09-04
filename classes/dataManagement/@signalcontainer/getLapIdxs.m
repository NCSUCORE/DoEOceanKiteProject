function [Idx1,Idx2] = getLapIdxs(obj,N)

lapNum = squeeze(obj.lapNumS.Data);
Idx1 = find(lapNum == N,1,'first');
Idx2 = find(lapNum == N+1,1,'first');
if isempty(Idx1) || isempty(Idx2)
    error('Lap %d was never started or finished. Simulate longer or reassess the meaning to your life',N)
end
end

