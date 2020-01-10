classdef signal < timeseries
    %SIGNAL derived from timeseries class.  Custom class to implement
    %overloaded methods like cropping and plotting.
    
    properties
        
    end
    
    methods
        % Contstructor
        function obj = signal(varargin)
            % Depending on the number of input arguments from the user
            switch nargin
                case 0
                    arg{1} = [];
                    arg{2} = [];
                    arg{3} = 'Name';
                    arg{4} = '';
                case 2
                    arg    = varargin;
                    arg{3} = 'Name';
                    arg{4} = '';
                case 4
                    arg = varargin;
                otherwise
                    error('Incorrect number of input arguments')
            end
            % Call the constructor for the timeseries (super)class
            obj@timeseries(arg{:})
        end
        
        % Function to overload plot command
        function varargout = plot(obj,varargin)
            % If it's a scalar signal, plot this way
            if ndims(obj.Data) == 2 && any(size(obj.Data) == 1)
                plot@timeseries(obj,varargin{:})
            else % Plot vector/matrix
                nRows = size(obj.Data,1);
                nCols = size(obj.Data,2);
                kk = 1;
                for ii = 1:nRows
                    for jj = 1:nCols
                        subplot(nRows,nCols,kk);
                        ts = obj;
                        ts.Data = squeeze(obj.Data(ii,jj,:));
                        plot@timeseries(ts,varargin{:});
                        %                         ylabel(sprintf('(%d,%d)',ii,jj));
                        kk = kk+1;
                    end
                end
                linkaxes(findall(gcf,'Type','axes'),'x');
                
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

