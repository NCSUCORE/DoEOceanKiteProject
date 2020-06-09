classdef constXYZT < handle
    %Flow that is constant with respect to x, y, z, and t
    
    properties (SetAccess = public)
        flowVec
        density
        zGridPoints
    end
    
    properties (Dependent)
        speed
        elevation
        heading
        
    end
    
    methods
        %% contructor
        function obj = constXYZT
            obj.flowVec      = SIM.parameter('Unit','m/s');
            obj.density      = SIM.parameter('Unit','kg/m^3','NoScale',false);
            obj.zGridPoints  = SIM.parameter('Value',0:10:200,'Unit','m','NoScale',false);
        end
        function setflowVec(obj,val,unit)
            obj.flowVec.setValue(val,unit);
        end
        function setDensity(obj,val,unit)
            obj.density(val,unit);
        end
        %% getters
        function val = get.speed(obj)
            val = SIM.parameter('Value',sqrt(sum(obj.flowVec.Value.^2)),...
                'Unit','m/s');
        end
        function val = get.elevation(obj)
            val =  SIM.parameter('Value',...
                acosd(obj.flowVec.Value(3)./sqrt(obj.flowVec.Value(1)^2+obj.flowVec.Value(2).^2)),...
                'Unit','deg');
        end
        function val = get.heading(obj)
            val = SIM.parameter('Value',atan2d(obj.flowVec.Value(2),obj.flowVec.Value(1)),...
                'Unit','deg');
        end
        %% other methods
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','public');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

