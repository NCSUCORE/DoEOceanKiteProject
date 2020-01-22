classdef timesignal < timeseries
    %SIGNAL derived from timeseries class.  Custom class to implement
    %overloaded methods like cropping and plotting.
    
    properties
        blockPath
    end
    
    methods
        % Contstructor
        function obj = timesignal(tsIn,varargin)
            p = inputParser;
            addOptional(p,'BlockPath',[],@(x) isa(x,'Simulink.SimulationData.BlockPath'))
            parse(p,varargin{:})
            % Call superclass constructor
            obj = obj@timeseries(tsIn);
            if ~isempty(p.Results.BlockPath)
               obj.blockPath = p.Results.BlockPath; 
            end
        end
        
        % Function to overload plot command
        function varargout = plot(obj,varargin)
            % If it's a scalar signal, plot this way
            if ndims(obj.Data) == 2 && any(size(obj.Data) == 1)
                plot@timeseries(obj,varargin{:})
            else % Plot vector/matrix
                
                % Number of time steps
                nt = numel(obj.Time);
                % size of the data
                sz = size(obj.Data);
                % Number of rows and columns
                switch ndims(obj.Data)
                    case 2
                        if sz(1) == nt
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
                        % Which dimension is time
                        switch (size(obj.Data)==nt)*(1:3)'
                            case 1
                                nc = sz(3);
                                nr = sz(2);
                                rDim = 2;
                                cDim = 3;
                            case 2
                                nc = sz(3);
                                nr = sz(1);
                                rDim = 1;
                                cDim = 3;
                            case 3
                                nc = sz(2);
                                nr = sz(1);
                                rDim = 1;
                                cDim = 2;
                        end
                        % If the signal is 4D or higher, no plot method
                    otherwise
                        error('Incorrect number of data dimensions, IDK how to plot that')
                end
                
                % Actually do the plotting
                timeDim = (1:ndims(obj.Data))*(size(obj.Data)==nt)';
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
        
        % Function to crop with GUI
        function newobj = guicrop(obj)
            newobj = timesignal(obj);
            hFig = newobj.plot;
            [x,~] = ginput(2);
            close(hFig);
            newobj = newobj.crop(min(x),max(x));
        end
        
        % Function to crop things
        function newobj = crop(obj,varargin)
            newobj = timesignal(obj);
            % User can provide either a two element vector or two inputs
            switch numel(varargin)
                case 1
                    % If it's a two element vector take the min and max values
                    if numel(varargin{1})==2
                        newobj = timesignal(newobj.getsampleusingtime(...
                            min(varargin{1}(:)),...
                            max(varargin{1}(:))));
                    else % If they gave more than two elements, throw error
                        error('Incorrect number of times provided')
                    end
                case 2
                    % If two inputs, take the first as start and second as end
                    newobj = timesignal(newobj.getsampleusingtime(varargin{1},varargin{2}));
                    %                     if numel(obj.Time)>0
                    %                         obj.Time = obj.Time-obj.Time(1);
                    %                     end
                    
                otherwise
                    % If they gave more inputs, throw error
                    error('Incorrect number of times provided')
            end
        end
        
        % Function to resample data to different rate
        function newobj = resample(obj,t,varargin)
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
                % Call superclass resample method on this object.
                newobj = resample@timeseries(newobj,tVec,varargin{:});
            end
        end
        
        % Method to calculate 3 point numerical derivative
        function newTimesignal = diff(obj)
            
            % find out which dimension in the data is time
            timeDim = find(size(obj.Data) == numel(obj.Time));
            
            % number of time steps
            nt  = numel(obj.Time);
            
            % dimensions of the data
            sz = size(obj.Data);
            
            % Code to populate lists of indices for each of 3 dimensions
            switch ndims(obj.Data)
                % If the data is 2D
                case 2
                    nc = 1;
                    switch timeDim
                        % If time corresponds to the first dimension
                        case 1
                            nr = sz(2);
                            % index of left points
                            lIdx{1} = 1:nt-2;
                            lIdx{2} = 1:nr;
                            lIdx{3} = 1;
                            % indices of center points
                            cIdx{1} = 2:nt-1;
                            cIdx{2} = 1:nr;
                            cIdx{3} = 1;
                            % indices of right points
                            rIdx{1} = 3:nt;
                            rIdx{2} = 1:nr;
                            rIdx{3} = 1;
                            % If time corresponds to the second dimension
                        case 2
                            nr = sz(1);
                            lIdx{2} = 1:nt-2;
                            lIdx{1} = 1:nr;
                            lIdx{3} = 1;
                            cIdx{2} = 2:nt-1;
                            cIdx{1} = 1:nr;
                            cIdx{3} = 1;
                            rIdx{2} = 3:nt;
                            rIdx{1} = 1:nr;
                            rIdx{3} = 1;
                    end
                case 3
                    switch timeDim
                        % If time corresponds to first dimension
                        case 1
                            nr = sz(1);
                            nc = sz(2);
                            lIdx{1} = 1:nt-2;
                            lIdx{2} = 1:nr;
                            lIdx{3} = 1:nc;
                            cIdx{1} = 2:nt-1;
                            cIdx{2} = 1:nr;
                            cIdx{3} = 1:nc;
                            rIdx{1} = 3:nt;
                            rIdx{2} = 1:nr;
                            rIdx{3} = 1:nc;
                            % If time corresponds to second dimension
                        case 2
                            nr = sz(1);
                            nc = sz(3);
                            lIdx{2} = 1:nt-2;
                            lIdx{1} = 1:nr;
                            lIdx{3} = 1:nc;
                            cIdx{2} = 2:nt-1;
                            cIdx{1} = 1:nr;
                            cIdx{3} = 1:nc;
                            rIdx{2} = 3:nt;
                            rIdx{1} = 1:nr;
                            rIdx{3} = 1:nc;
                            % If time corresponds to third dimension
                        case 3
                            nr = sz(1);
                            nc = sz(2);
                            lIdx{3} = 1:nt-2;
                            lIdx{1} = 1:nr;
                            lIdx{2} = 1:nc;
                            cIdx{3} = 2:nt-1;
                            cIdx{1} = 1:nr;
                            cIdx{2} = 1:nc;
                            rIdx{3} = 3:nt;
                            rIdx{1} = 1:nr;
                            rIdx{2} = 1:nc;
                    end
                otherwise
                    error('Unknown data dimension')
            end
            
            % Options for permute command to get dimensions right on
            % repmat(time) later
            switch timeDim
                case 1
                    pmt{1} = 1;
                    pmt{2} = 2;
                    pmt{3} = 3;
                case 2
                    pmt{1} = 3;
                    pmt{2} = 2;
                    pmt{3} = 1;
                case 3
                    pmt{1} = 3;
                    pmt{2} = 2;
                    pmt{3} = 1;
            end
            
            % 3 point derivative approximation
            % center pt minus left pt
            tsLeft   = obj.Time(2:end-1)-obj.Time(1:end-2);
            tsLeft   = tsLeft(:);  
            tsLeft   = repmat(permute(tsLeft,[pmt{:}]),[nr nc 1]);
            ddtLeft  = (obj.Data(cIdx{:})-obj.Data(lIdx{:}))./tsLeft;
            % right pt minus center pt
            tsRight  = obj.Time(3:end)-obj.Time(2:end-1);
            tsRight  = tsRight(:);
            tsRight  = repmat(permute(tsRight,[pmt{:}]),[nr nc 1]);
            ddtRight = (obj.Data(rIdx{:})-obj.Data(cIdx{:}))./tsRight;
            ddt = 0.5*(ddtLeft+ddtRight);
            
            % Use two point approximation for first and last point
            firstPt = obj.getsampleusingtime(obj.Time(2)).Data-obj.getsampleusingtime(obj.Time(1)).Data;
            firstPt = firstPt./(obj.Time(2)-obj.Time(1));
            
            lastPt = obj.getsampleusingtime(obj.Time(end)).Data-obj.getsampleusingtime(obj.Time(end-1)).Data;
            lastPt = lastPt./(obj.Time(end)-obj.Time(end-1));
            
            % concatenate the first and last point before and after the
            % results from the 3 point method
            ddt = cat(timeDim,firstPt,ddt,lastPt);
            
            % Create the new timesignal object
            newTimesignal = timesignal(timeseries(ddt,obj.Time),'Name',[obj.Name 'Deriv']);

            % Add per seconds to the units if they exist
            if ~isempty(obj.DataInfo.Units)
                newTimesignal.DataInfo.Units = [obj.DataInfo.Units 's^-1'];
            end
        end
    end
end

