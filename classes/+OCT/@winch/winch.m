classdef winch < handle
    %WINCH Simple model of winch dynamics, velocity is rate limited,
    %filtered and saturated.  Output is tether length.  Also includes power
    %consumption/production estimate. 
    
    properties (SetAccess = private)
        initLength
        maxSpeed
        timeConst
        maxAccel
        motorEfficiency
        generatorEfficiency
    end
    
    methods
        function obj = winch
            obj.initLength  = SIM.parameter('Unit','m');
            obj.maxSpeed    = SIM.parameter('Unit','m/s');
            obj.timeConst   = SIM.parameter('Unit','s');
            obj.maxAccel    = SIM.parameter('Unit','m/s^2');
            obj.motorEfficiency     = SIM.parameter('Value',0.95,'Min',0,'Max',1);
            obj.generatorEfficiency = SIM.parameter('Value',0.9,'Min',0,'Max',1);
            
            obj.motorEfficiency.Description = sprintf('Electromechanical efficiency of winches during spool in, default = %.2f',obj.motorEfficiency.Value);
            obj.generatorEfficiency.Description = sprintf('Electromechanical regenerative efficiency of winches during spool out, default = %.2f',obj.generatorEfficiency.Value);
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

