function newObj = resample(obj,varargin)
%% Resample all signals in the signal container
newObj = signalcontainer(obj);
props  = properties(newObj);
for ii = 1:numel(props)
    switch class(newObj.(props{ii}))
        case {'timesignal','timeseries'}
            if ismethod(newObj.(props{ii}),'crop')
                newObj.(props{ii}) = newObj.(props{ii}).resample(varargin{:});
            end
        case 'struct'
            subProps = fields(newObj.(props{ii}));
            for jj = 1:numel(newObj.(props{ii})) % Loop through stuct
                for kk = 1:numel(subProps) % Loop through properties
                    if ismethod(newObj.(props{ii})(jj).(subProps{kk}),'crop')
                        newObj.(props{ii})(jj).(subProps{kk}) = newObj.(props{ii})(jj).(subProps{kk}).resample(varargin{:});
                    end
                end
            end
    end
end
end