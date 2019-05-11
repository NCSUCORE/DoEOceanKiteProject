classdef tetherParamClass < handle
    properties
        tether_actual_density
        tether_density
        tether_diameter
        tether_youngs
        tether_CS
        damping_ratio
        CD_cylinder
    end
    methods
        function obj = tetherParamClass
            obj.tether_actual_density = simulinkProperty(1300);
            obj.tether_diameter       = simulinkProperty([0.055; 0.076; 0.055]);
            obj.tether_youngs         = simulinkProperty(3.8e9);
            obj.tether_CS             = simulinkProperty((pi/4)*obj.tether_diameter.Value.^2);
            obj.damping_ratio         = simulinkProperty(0.05);
            obj.CD_cylinder           = simulinkProperty(0.5);
        end
        function obj = setupTether(obj,envParam)
            obj.tether_density = simulinkProperty(...
                obj.tether_actual_density.Value - envParam.density.Value);
        end
    end
end