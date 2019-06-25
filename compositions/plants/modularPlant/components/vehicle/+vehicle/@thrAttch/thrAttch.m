classdef thrAttch
    %THRATTCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posVec
    end
    methods
        function obj = thrAttch
            obj.posVec = vehicle.param('Unit','m');
        end
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).Value = scaleParam(obj.(props{ii}),scaleFactor);
            end
        end
        
    end
end

