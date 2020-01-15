classdef timesignal < timeseries
    %SIGNAL derived from timeseries class.  Custom class to implement
    %overloaded methods like cropping and plotting.
    
    properties
        
    end
    
    methods
        % Contstructor
        function obj = timesignal(tsIn)
            obj = obj@timeseries(tsIn);
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
                
                timeDim = (1:ndims(obj.Data))*(size(obj.Data)==nt)';
                inds={[],[],[]};
                inds{timeDim} = 1:nt;
                cnt = 1;
                tsPlot = obj;
                for ii = 1:nr
                    for jj = 1:nc
                        subplot(nr,nc,cnt)
                        inds{rDim} = ii;
                        inds{cDim} = jj;
                        tsPlot.Data = squeeze(obj.Data(inds{:}));
                        plot@timeseries(tsPlot,varargin{:})
                        cnt = cnt+1;
                    end
                end
            end
            if nargout==1
                varargout{1} = gcf;
            end
        end
        
        % Function to crop with GUI
        function obj = guicrop(obj)
            hFig = obj.plot;
            [x,~] = ginput(2);
            close(hFig);
            obj = obj.crop(min(x),max(x));
            
        end
        
        % Function to crop things
        function obj = crop(obj,varargin)
            switch numel(varargin)
                case 1
                    if numel(varargin{1})==2
                        obj = obj.getsampleusingtime(varargin{1}(1),varargin{1}(2));
                    else
                        error('Incorrect number of times provided')
                    end
                case 2
                    obj = obj.getsampleusingtime(varargin{1},varargin{2});
                otherwise
                    error('Incorrect number of times provided')
            end
        end
        
        
    end
end

