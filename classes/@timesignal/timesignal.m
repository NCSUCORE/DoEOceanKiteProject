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
        
        
        
        
        
        

        
        
    end
end

