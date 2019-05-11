classdef allActuatorPlantClass < handle
    properties
        
    end
    
    methods
        % Function to scale all parameters
        function obj = scale(obj,scaleFactor)
            obj = scaleObj(obj,scaleFactor);
        end
    end
end
