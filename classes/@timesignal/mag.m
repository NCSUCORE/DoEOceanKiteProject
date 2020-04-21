function newobj = mag(obj,varargin)
%% Calculate magnitude of signal, return as new timesignal
p=inputParser;
p.addOptional('vectorDim',[],@(x)isnumeric(x));
parse(p,varargin{:})
sz = size(obj.Data);
timeDim = find(sz==length(obj.Time));
nonTimeDims = 1:length(sz);
nonTimeDims(timeDim)=[]; %#ok<FNDSB>
%Decide Vector Dimention
if ~isempty(p.Results.vectorDim)
    vdim=p.Results.vectorDim;
else
    switch length(nonTimeDims)
        case 1
            vdim=nonTimeDims;
        otherwise
            if length(nonTimeDims(sz(nonTimeDims)==3))==1
                vdim=nonTimeDims(sz(nonTimeDims)==3);
            else
                error("You need to specify dimentions with plotMag('vectorDim',#,...)")
            end
    end
end
newobj=timesignal(obj);
newobj.Data = sqrt(sum(obj.Data.^2,vdim));
newobj.Name = obj.Name + "Mag";
end