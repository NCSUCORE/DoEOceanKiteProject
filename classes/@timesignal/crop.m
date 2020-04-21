function newObj = crop(obj,varargin)
%% Select a subset of data spanning a time-range
newObj = timesignal(obj);
% User can provide either a two element vector or two inputs
switch numel(varargin)
    case 1
        % If it's a two element vector take the min and max values
        if numel(varargin{1})==2
            if length(obj.Time)==1 && obj.Time(1)==0
                newObj = timesignal(newObj.getsampleusingtime(0),min(varargin{1}(:)));
                newObj.Time = min(varargin{1}(:));
            else
                newObj = timesignal(newObj.getsampleusingtime(...
                    min(varargin{1}(:)),...
                    max(varargin{1}(:))));
            end
        else % If they gave more than two elements, throw error
            error('Incorrect number of times provided')
        end
    case 2
        % If two inputs, take the first as start and second as end
        %                     getsampleusingtime@timeseries(newObj,varargin{1},varargin{2})
        if length(obj.Time)==1 && obj.Time(1)==0
            newObj = timesignal(newObj.getsampleusingtime(0));
            newObj.Time = varargin{1};
        else
            newObj = timesignal(newObj.getsampleusingtime(varargin{1},varargin{2}));
        end
    otherwise
        % If they gave more inputs, throw error
        error('Incorrect number of times provided')
end
newObj.Name = obj.Name + "Cropped";
end