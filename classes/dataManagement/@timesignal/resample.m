
function newobj = resample(obj,t,varargin)
%% Resample data to different rate or time step sequence
newobj = timesignal(obj);
% If t has too many dimensions or if more than 1 dimension has
% more than 1 element
if ndims(t)>2 || sum(size(t)>1)>1
    error('Incorrect number of dimensions')
end
% Build the time vector
if numel(newobj.Time)>0 % Make sure it's not empty
    if numel(t)==1
        % Time vector spanning time of obj
        tVec = newobj.Time(1):t:newobj.Time(end);
    else % If it's a vector
        % crop t down to the range included in obj already
        tVec = t(and(t>=newobj.Time(1),t<=newobj.Time(end)));
    end
    
    if isenum(newobj.getsamples(1).Data) % If it's enumerated data
        % Get the name of the enumerated class
        enumName = class(obj.getsamples(1).Data);
        % Convert the data to double
        newobj.Data = double(newobj.Data);
        % Call superclass resample method on this object.
        newobj = resample@timeseries(newobj,tVec,varargin{:});
        % Round to integer and convert back to enumerated
        newobj.Data = feval(enumName,round(newobj.Data));
    else
        % Call superclass resample method on this object.
        newobj = resample@timeseries(newobj,tVec,varargin{:});
    end
end
end