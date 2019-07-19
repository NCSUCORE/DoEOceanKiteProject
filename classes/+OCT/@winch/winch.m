classdef winch < handle
    %WINCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
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
        
        function obj = setInitLength(obj,val,units)
            obj.initLength.setValue(val,units)
        end
        function obj = setMaxSpeed(obj,val,units)
            obj.maxSpeed.setValue(val,units)
        end
        function obj = setTimeConst(obj,val,units)
            obj.timeConst.setValue(val,units)
        end
        function obj = setMaxAccel(obj,val,units)
            obj.maxAccel.setValue(val,units)
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

