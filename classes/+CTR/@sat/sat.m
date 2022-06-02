classdef sat
    %SAT Set controller saturation limits
    %   Class which defines upper and lower limits for a saturated signal.
    
    properties
        upperLimit
        lowerLimit
    end 
    
    methods
        function obj = sat(varargin)
            p = inputParser;
            addParameter(p,'upperLim',Inf,@(x)isnumeric(x))
            addParameter(p,'lowerLim',-Inf,@(x)isnumeric(x));
            addParameter(p,'Unit','',@(s) ischar(s));
            parse(p,varargin{:});
            %SAT Construct an instance of this class
            %   Detailed explanation goes here
                    obj.upperLimit = SIM.parameter('Value',...
                        p.Results.upperLim,'Unit',p.Results.Unit);
                    obj.lowerLimit = SIM.parameter('Value',...
                        p.Results.lowerLim,'Unit',p.Results.Unit);
        end
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
    end
end

