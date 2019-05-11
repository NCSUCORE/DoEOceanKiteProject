classdef platformParamClass < handle
    properties
        platform_Izz
        platform_mass
        platform_damping
        gnd_station
    end
    methods
        function obj = platformParamClass
            obj.platform_Izz        = simulinkProperty(100);
            obj.platform_mass       = simulinkProperty(1);
            obj.platform_damping    = simulinkProperty(10);
            obj.gnd_station         = simulinkProperty([0;0;0]);
        end
    end
end