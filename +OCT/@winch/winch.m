classdef winch < handle
    %WINCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        initLength
        maxSpeed
        timeConst
        maxAccel
    end
    
    methods
        function obj = winch
            obj.initLength  = OCT.param('Unit','m');
            obj.maxSpeed    = OCT.param('Unit','m/s');
            obj.timeConst   = OCT.param('Unit','s');
            obj.maxAccel    = OCT.param('Unit','m/s^2');
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

