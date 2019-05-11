classdef envParamsClass < handle
    properties
        density
        grav
        mu
        flow
    end
    methods
        function obj = envParamsClass
            obj.density = simulinkProperty(1000);
            obj.grav    = simulinkProperty(9.81);
            obj.mu      = simulinkProperty(1e-3);
            obj.flow    = simulinkProperty([1 0  0]');
        end
    end
end