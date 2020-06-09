classdef PID < handle
    %@FPID Summary of this class goes here
    %   Detailed explanation goes here
    properties  (SetAccess = private)
        kp
        ki
        kd
    end
    
    methods
        function obj = FPID(inUnits,outUnits)
            %@FPID Construct an instance of this class
            %   Detailed explanation goes here
            obj.kp  = SIM.parameter('Value',0,'Unit',sprintf('(%s)/(%s)',outUnits,inUnits),'Description','Proportional gain');
            obj.ki  = SIM.parameter('Value',0,'Unit',sprintf('(%s)/(%s*s)',outUnits,inUnits),'Description','Integral gain');
            obj.kd  = SIM.parameter('Value',0,'Unit',sprintf('(%s)/(%s/s)',outUnits,inUnits),'Description','Derivative gain');
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        function setKp(obj,val,unit)
            obj.kp.setValue(val,unit);
        end
        function setKi(obj,val,unit)
            obj.ki.setValue(val,unit);
        end
        function setKd(obj,val,unit)
            obj.kd.setValue(val,unit);
        end
    end
end

