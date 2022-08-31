classdef FPID < handle
    %@FPID Summary of this class goes here
    %   Detailed explanation goes here
    
    properties  (SetAccess = private)
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
        function print(obj)
            fprintf('FPID Controller with the following parameters\n')
            fprintf(sprintf('Kp = %.2e %s\n',obj.kp.Value,obj.kp.Unit))
            fprintf(sprintf('Ki = %.2e %s\n',obj.ki.Value,obj.ki.Unit))
            fprintf(sprintf('Kd = %.2e %s\n',obj.kd.Value,obj.kd.Unit))
            fprintf(sprintf('Tau = %.2e %s\n',obj.tau.Value,obj.tau.Unit))
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
        function setTau(obj,val,unit)
            obj.tau.setValue(val,unit);
        end
        
        
    end
end

