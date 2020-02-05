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
            
            % Set the block path property
            obj.blockPath = p.Results.BlockPath;
            
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
        
        %Plots the magnitude of a given signal. Assumes vectors have a
        %length of 3 unless given a vector Dimention.
        function varargout = plotMag(obj,varargin)
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
            if nargout == 1
                varargout{1}=newobj.plot;
            else
                newobj.plot;
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
        function newObj = crop(obj,varargin)
            newObj = obj;
            % User can provide either a two element vector or two inputs
            switch numel(varargin)
                case 1
                    % If it's a two element vector take the min and max values
                    if numel(varargin{1})==2
                        newObj = timesignal(newObj.getsampleusingtime(...
                            min(varargin{1}(:)),...
                            max(varargin{1}(:))));
                    else % If they gave more than two elements, throw error
                        error('Incorrect number of times provided')
                    end
                case 2
                    % If two inputs, take the first as start and second as end
%                     getsampleusingtime@timeseries(newObj,varargin{1},varargin{2})
                    newObj = timesignal(newObj.getsampleusingtime(varargin{1},varargin{2}));
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
        
        %Method to calculate 3 point numerical derivative
        function derivSignal = diff(obj)
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
        
        function derivSignal = diffMC(obj)
            derivSignal = timesignal(obj);
            timeDimInd = find(size(obj.Data) == numel(obj.Time));
            tDimsDes             = ones(1,ndims(obj.Data));
            tDimsDes(timeDimInd) = length(obj.Time)-1;
            dxts = timeseries(diff(obj.Data,1,timeDimInd),obj.Time(1:end-1));
            dtts = timeseries(reshape(diff(obj.Time(:)),tDimsDes),obj.Time(1:end-1));
            dxdt = dxts./dtts; % Using timeseries in the last two lines makes this work smoothly
            derivSignal.Data  = cat(    ...
                timeDimInd,dxdt.getdatasamples(1),... % First 2 point derivitive
                0.5*(dxdt.getdatasamples(1:dxdt.Length-1) + dxdt.getdatasamples(2:dxdt.Length)),... % Average of ajacent derivitives
                dxdt.getdatasamples(dxdt.Length)); % Last 2 point derivitive
            %Add per seconds to the units if they exist
            if ~isempty(obj.DataInfo.Units)
                derivSignal.DataInfo.Units = [obj.DataInfo.Units 's^-1'];
            end
            derivSignal.Name = obj.Name + "Deriv";
        end
        
        function intSig = cumtrapz(obj,initVal)
            intSig = timesignal(obj);
            timeDimInd = find(size(obj.Data) == numel(obj.Time));
            intSig.Data = cumtrapz(intSig.Time,intSig.Data,timeDimInd)+initVal;
        end
        
        % Write function for two norm here
        function nrm = twoNorm(obj)
            timeDimInd = find(size(obj.Data) == numel(obj.Time));
            nrm = trapz(obj.Time,obj.Data.^2,timeDimInd).^(1/2);
        end
    end
end

