classdef thrAttch
    %THRATTCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        posVec
    end
    methods
        function obj = thrAttch
            obj.posVec = SIM.parameter('Unit','m');
        end
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(factor);
            end
        end
        
    end
end

