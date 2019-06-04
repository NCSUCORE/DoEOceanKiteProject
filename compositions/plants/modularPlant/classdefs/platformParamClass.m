classdef platformParamClass < handle
    properties
        platform_Izz
        platform_mass
        platform_damping
        gnd_station
    end
    methods
        function obj = platformParamClass
            obj.platform_Izz        = simulinkProperty(100,'Unit','kg*m^2','Description','mass moment of inertia of platform');
            obj.platform_mass       = simulinkProperty(1,'Unit','kg','Description','mass moment of inertia of platform');
            obj.platform_damping    = simulinkProperty(10,'Unit','N*s','Description','mass moment of inertia of platform');
            obj.gnd_station         = simulinkProperty([0;0;0],'Unit','m','Description','Location of platform');
        end
    end
end