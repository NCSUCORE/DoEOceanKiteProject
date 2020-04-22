classdef timesignal < timeseries
    %TIMESIGNAL is a custom class used to implement commonly used signal
    %operations.  It is a subclass of timeseries and thus inherets all the
    %properties and methods associated with timeseries objects.
    
    properties
        blockPath
    end
    
    methods

        function obj = timesignal(tsIn,varargin)
            %% Constructor
            
            % Parse inputs
            p = inputParser;
            addOptional(p,'BlockPath',[],@(x) isa(x,'Simulink.SimulationData.BlockPath'))
            parse(p,varargin{:})
            
            % Call superclass constructor
            obj = obj@timeseries(tsIn);
            
            % Set the block path property
            obj.blockPath = p.Results.BlockPath;
            
        end
        
        % Other methods are stored in standalone .m files
        % See doc timesignal, methods('timesignal'), or
        % cd(fileparts(which('timesignal.m'))) for details.
    end
end

