classdef thrAttch
    %THRATTCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        posVec
        velVec
    end
    methods
        function obj = thrAttch
            obj.posVec = SIM.parameter('Unit','m');
            obj.velVec = SIM.parameter('Unit','m/s');
        end
        function setPosVec(obj,val,units)
            obj.posVec.setValue(val,units);
        end
        function setVelVec(obj,val,units)
            obj.velVec.setValue(val,units);
        end
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
    end
end

