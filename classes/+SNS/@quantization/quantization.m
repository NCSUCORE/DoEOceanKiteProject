classdef quantization
    %QUANTIZATION simple classdef to store properties of a quantization
    
    properties (SetAccess = private)
        zeroOffset
        stepSize
    end
    
    methods
        function obj = quantization
            %QUANTIZATION Construct an instance of this class
            %   Detailed explanation goes here
            obj.zeroOffset = SIM.parameter('Value',0,'Unit','');
            obj.stepSize   = SIM.parameter('Unit','');
        end
        
        function setZeroOffset(obj,val,unit)
            obj.zeroOffset.setValue(val,unit);
        end
        
        function setStepSize(obj,val,unit)
            if val<=0
                error('Quantization level cannot be negative')
            end
            obj.stepSize.setValue(val,unit);
        end
    end
end

