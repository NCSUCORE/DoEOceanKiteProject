classdef thrAttchLE
    %THRATTCH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        rThrAttch_LE
    end
    methods
        function obj = thrAttchLE
            obj.rThrAttch_LE = SIM.parameter('Unit','m');
        end
        function setRThrAttch_LE(obj,val,units)
           obj.rThrAttch_LE.setValue(val,units); 
        end
        
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
    end
end

