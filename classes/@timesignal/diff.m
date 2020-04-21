function derivSignal = diff(obj)
%% 3 point numerical approximation of derivitive with respect to time
derivSignal=timesignal(obj);
tdiffvec = diff(obj.Time(:));
%tdiffs(1) = tdiffvec(1)/2
%tdiffs(end) = tdiffvec(end)/2
%tdiffs(n) = (tdiffvec(n-1)+tdiffvec(n))/2
tdiffs = .5*([0; tdiffvec]+[tdiffvec; 0]);
timeDimInd = find(size(obj.Data) == numel(obj.Time));
otherDims = size(obj.Data);
otherDims = otherDims(1:ndims(obj.Data) ~= timeDimInd);
ddiffvec = diff(obj.Data,1,timeDimInd);
%ddiffs(1) = ddiffvec(1)/2
%ddiffs(end) = ddiffvec(end)/2
%ddiffs(n) = (ddiffvec(n-1)+ddiffvec(n))/2
ddiffs = .5*(cat(timeDimInd,zeros(otherDims),ddiffvec)+cat(timeDimInd,ddiffvec,zeros(otherDims)));
tdimsDes=ones(1,ndims(obj.Data));
tdimsDes(timeDimInd)=length(obj.Time);
derivSignal.Data = ddiffs./reshape(tdiffs',tdimsDes);
%Add per seconds to the units if they exist
if ~isempty(obj.DataInfo.Units)
    derivSignal.DataInfo.Units = [obj.DataInfo.Units 's^-1'];
end
derivSignal.Name = obj.Name + "Deriv";
end
