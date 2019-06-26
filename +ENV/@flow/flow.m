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
            obj.velVec      = SIM.param('Unit','m/s');
            obj.density     = SIM.param('Unit','kg/m^3','IgnoreScaling',true);
            obj.speed       = SIM.param('Unit','m/s');
            obj.elevation   = SIM.param('Unit','deg');
            obj.heading     = SIM.param('Unit','deg');
        end
        
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
            end
        end
        
        function val = speed.get(obj)
            obj.speed.Value = sqrt(sum(obj.velVec.Value.^2));
            val = obj.Speed;
        end
        
        function val = get.elevation(obj)
            obj.elevation.Value = acosd(obj.velVec.Value(3)./sqrt(obj.velVec.Value(1)^2+obj.velVec.Value(2).^2));
            val = obj.elevation;
        end
        
        function val = get.heading(obj)
            obj.heading.Value = atan2d(obj.velVec.Value(2),obj.velVec.Value(1));
            val = obj.heading;
        end
    end
end

