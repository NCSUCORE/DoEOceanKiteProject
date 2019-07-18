classdef FPID < handle
    %@FPID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        kp
        ki
        kd
        tau
    end
    
    methods
        function obj = FPID(inUnits,outUnits)
            %@FPID Construct an instance of this class
            %   Detailed explanation goes here
            obj.kp  = SIM.parameter('Value',0,'Unit',sprintf('(%s)/(%s)',outUnits,inUnits),'Description','Proportional gain');
            obj.ki  = SIM.parameter('Value',0,'Unit',sprintf('(%s)/(%s*s)',outUnits,inUnits),'Description','Integral gain');
            obj.kd  = SIM.parameter('Value',0,'Unit',sprintf('(%s)/(%s/s)',outUnits,inUnits),'Description','Derivative gain');
            obj.tau = SIM.parameter('Value',1,'Unit','s','Description','Time Constant');
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

