function intSig = cumtrapz(obj,initVal)
%% Cumulative trapezoidal integration of the data
intSig = timesignal(obj);
timeDimInd = find(size(obj.Data) == numel(obj.Time));
intSig.Data = cumtrapz(intSig.Time,intSig.Data,timeDimInd)+initVal;
end