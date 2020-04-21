function derivSignal = diffMC(obj)
derivSignal = timesignal(obj);
timeDimInd = find(size(obj.Data) == numel(obj.Time));
tDimsDes             = ones(1,ndims(obj.Data));
tDimsDes(timeDimInd) = length(obj.Time)-1;
dxts = timeseries(diff(obj.Data,1,timeDimInd),obj.Time(1:end-1));
dtts = timeseries(reshape(diff(obj.Time(:)),tDimsDes),obj.Time(1:end-1));
dxdt = dxts./dtts; % Using timeseries in the last two lines makes this work smoothly
derivSignal.Data  = cat(    ...
    timeDimInd,dxdt.getdatasamples(1),... % First 2 point derivitive
    0.5*(dxdt.getdatasamples(1:dxdt.Length-1) + dxdt.getdatasamples(2:dxdt.Length)),... % Average of ajacent derivitives
    dxdt.getdatasamples(dxdt.Length)); % Last 2 point derivitive
%Add per seconds to the units if they exist
if ~isempty(obj.DataInfo.Units)
    derivSignal.DataInfo.Units = [obj.DataInfo.Units 's^-1'];
end
derivSignal.Name = obj.Name + "Deriv";
end