classdef flow < handle
    %FLOW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        velVec
        density
        speed
        elevation
        heading
    end
    
    methods
        function obj = flow
            obj.velVec      = SIM.parameter('Unit','m/s');
            obj.density     = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.speed       = SIM.parameter('Unit','m/s');
            obj.elevation   = SIM.parameter('Unit','deg');
            obj.heading     = SIM.parameter('Unit','deg');
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
        function val = speed.get(obj)
            obj.speed.setValue(sqrt(sum(obj.velVec.Value.^2)),'m/s');
            val = obj.Speed;
        end
        
        function val = get.elevation(obj)
            obj.elevation.setValue(acosd(obj.velVec.Value(3)./sqrt(obj.velVec.Value(1)^2+obj.velVec.Value(2).^2)),'deg');
            val = obj.elevation;
        end
        
        function val = get.heading(obj)
            obj.heading.setValue(atan2d(obj.velVec.Value(2),obj.velVec.Value(1)),'deg');
            val = obj.heading;
        end
    end
end

