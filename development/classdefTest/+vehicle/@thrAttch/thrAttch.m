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
        
    end
end

