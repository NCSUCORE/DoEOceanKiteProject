function intSig = cumtrapz(obj,initVal)
intSig = timesignal(obj);
timeDimInd = find(size(obj.Data) == numel(obj.Time));
intSig.Data = cumtrapz(intSig.Time,intSig.Data,timeDimInd)+initVal;
end