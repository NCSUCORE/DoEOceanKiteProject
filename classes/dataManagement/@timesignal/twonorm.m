function nrm = twonorm(obj)
%% two-norm of time-domain signal, unweighted
timeDimInd = find(size(obj.Data) == numel(obj.Time));
nrm = trapz(obj.Time,obj.Data.^2,timeDimInd).^(1/2);
end