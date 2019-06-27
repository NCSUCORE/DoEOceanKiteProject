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
            obj.initLength  = SIM.parameter('Unit','m');
            obj.maxSpeed    = SIM.parameter('Unit','m/s');
            obj.timeConst   = SIM.parameter('Unit','s');
            obj.maxAccel    = SIM.parameter('Unit','m/s^2');
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

