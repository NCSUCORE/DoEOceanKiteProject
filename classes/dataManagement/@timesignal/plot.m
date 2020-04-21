function varargout = plot(obj,varargin)
%% Plot method used in the timesignal class

% If it's a scalar signal, plot this way
if ndims(obj.Data) == 2 && any(size(obj.Data) == 1)
    plot@timeseries(obj,varargin{:})
else % Plot vector/matrix
    % Number of time steps
    nt = numel(obj.Time);
    % size of the data
    sz = size(obj.Data);
    % Which dimension is time
    timeDim = find(sz==nt);
    % Number of rows and columns
    switch ndims(obj.Data)
        case 2
            if timeDim == 1
                nc = sz(2);
                nr = 1;
                cDim = 2;
                rDim = 3;
            else
                nr = sz(2);
                nc = 1;
                cDim = 3;
                rDim = 1;
            end
        case 3
            nonTimeDims=1:3;
            nonTimeDims(timeDim)=[];
            nr=sz(nonTimeDims(1));
            nc=sz(nonTimeDims(2));
            rDim=nonTimeDims(1);
            cDim=nonTimeDims(2);
        case 4
            % If the data is 4D, slice along 3rd dimension,
            % call plotting on each of the slides
            for ii = 1:size(obj.Data,3)
                figure('Name',sprintf('Slice %d',ii));
                newObj = timesignal(obj);
                newObj.Data = squeeze(obj.Data(:,:,ii,:));
                newObj.plot;
            end
            return
            % If the signal is 5D or higher, no plot method
        otherwise
            error('Incorrect number of data dimensions, IDK how to plot that')
    end
    
    % Actually do the plotting
    % Preallocate cells of indices used to extract data
    inds={[],[],[]};
    inds{timeDim} = 1:nt;
    % Create tseries with all the same properties as origional
    tsPlot = obj;
    % Create counter
    cnt = 1;
    % Loop over rows
    for ii = 1:nr
        % Loop over columns
        for jj = 1:nc
            % Create subplot
            subplot(nr,nc,cnt)
            % Set which row and col we're looking at
            inds{rDim} = ii;
            inds{cDim} = jj;
            % Pull out the right data to plot
            tsPlot.Data = squeeze(obj.Data(inds{:}));
            % Plot the data using the timeseries plot method
            plot@timeseries(tsPlot,varargin{:})
            % increment counter
            cnt = cnt+1;
        end
    end
end
% If the user wants it, return the figure handle
if nargout==1
    varargout{1} = gcf;
end
end