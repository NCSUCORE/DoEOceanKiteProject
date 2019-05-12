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
            obj.tether_actual_density = simulinkProperty(1300,'Unit','(1000*g)/(m^3)','Description','tether actual density');
            obj.tether_diameter       = simulinkProperty([0.055; 0.076; 0.055],'Unit','m','Description','tether diameter');
            obj.tether_youngs         = simulinkProperty(3.8e9,'Unit','Pa','Description','tether youngs modulus');
            obj.tether_CS             = simulinkProperty((pi/4)*obj.tether_diameter.Value.^2,'Unit','m^2','Description','tether cross sectional area');
            obj.damping_ratio         = simulinkProperty(0.05,'Description','tether damping ratio');
            obj.CD_cylinder           = simulinkProperty(0.5,'Description','cylinder drag coefficient');
        end
        function obj = setupTether(obj,envParam)
            obj.tether_density = simulinkProperty(...
                obj.tether_actual_density.Value - envParam.density.Value,'Unit','(1000*g)/(m^3)','Description','tether density');
        end
    end
end