classdef thrAttch
    %THRATTCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        posVec
    end
    methods
        function obj = thrAttch
            obj.posVec = SIM.parameter('Unit','m','Description','Position vector of the tether attachment point. Add frame name/origin info here');
        end
        function setPosVec(obj,val,units)
           obj.posVec.setValue(val,units); 
        end
        
        function setPosVecDesc(obj,strDescription)
           obj.posVec.Description = strDescription;
        end
        
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
    end
end

