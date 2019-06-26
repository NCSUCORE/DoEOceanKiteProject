classdef sat
    %SAT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        upperLimit
        lowerLimit
    end 
    
    methods
        function obj = sat
            %SAT Construct an instance of this class
            %   Detailed explanation goes here
                    obj.upperLimit = SIM.param('Value',inf);
                    obj.lowerLimit = SIM.param('Value',-inf);
        end
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
            end
        end
        
    end
end

