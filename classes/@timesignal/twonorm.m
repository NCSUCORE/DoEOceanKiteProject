% Write function for two norm here
function nrm = twonorm(obj)
timeDimInd = find(size(obj.Data) == numel(obj.Time));
nrm = trapz(obj.Time,obj.Data.^2,timeDimInd).^(1/2);
end