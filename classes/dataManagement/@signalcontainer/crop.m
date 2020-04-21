function newObj = crop(obj,varargin)
%% Crop all signals in the signal container

% Call the crop method of each property
newObj = signalcontainer(obj);
props  = properties(newObj);
for ii = 1:numel(props)
    switch class(newObj.(props{ii}))
        case 'timesignal'
            if ismethod(newObj.(props{ii}),'crop')
                newObj.(props{ii}) = newObj.(props{ii}).crop(varargin{:});
            end
        case 'struct'
            subProps = fields(newObj.(props{ii}));
            for jj = 1:numel(newObj.(props{ii})) % Loop through stuct
                for kk = 1:numel(subProps) % Loop through properties
                    if ismethod(newObj.(props{ii})(jj).(subProps{kk}),'crop')
                        newObj.(props{ii})(jj).(subProps{kk}) = newObj.(props{ii})(jj).(subProps{kk}).crop(varargin{:});
                    end
                end
            end
            
    end
end
end