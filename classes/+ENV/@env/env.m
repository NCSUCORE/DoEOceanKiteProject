classdef env < dynamicprops
    properties
        gravAccel
    end
    methods
        function obj = env
            obj.gravAccel = SIM.parameter('Value',9.81,'Unit','m/s^2','NoScale',true);
        end

        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end
