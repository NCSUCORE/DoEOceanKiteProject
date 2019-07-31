classdef constantUniformFlow < handle
    %CONSTANT UNIVFORM FLOW
    
    properties (SetAccess = public)
        velVec
        density
    end
    
    properties (Dependent)
        speed
        elevation
        heading
    end
    
    methods
<<<<<<< HEAD:classes/+ENV/@constantUniformFlow/constantUniformFlow.m
        function obj = constantUniformFlow
=======
        %% contructor
        function obj = flow
>>>>>>> master:classes/+ENV/@flow/flow.m
            obj.velVec      = SIM.parameter('Unit','m/s');
            obj.density     = SIM.parameter('Unit','kg/m^3','NoScale',false);
        end
        
        %% getters
        function val = get.speed(obj)
            val = SIM.parameter('Value',sqrt(sum(obj.velVec.Value.^2)),...
                'Unit','m/s');
        end
        
        function val = get.elevation(obj)
            val =  SIM.parameter('Value',acosd(obj.velVec.Value(3)./sqrt(obj.velVec.Value(1)^2+obj.velVec.Value(2).^2)),...
                'Unit','deg');
            
        end
        
        function val = get.heading(obj)
            val = SIM.parameter('Value',atan2d(obj.velVec.Value(2),obj.velVec.Value(1)),...
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

