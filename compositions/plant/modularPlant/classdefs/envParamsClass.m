classdef envParamsClass < handle
    properties
        density
        grav
        mu
        flow
    end
    methods
        function obj = envParamsClass
            obj.density = simulinkProperty(1000,'Unit','(kg)/m^3','Description','water density');
            obj.grav    = simulinkProperty(9.81,'Unit','m/s^2','Description','gravity');
            obj.mu      = simulinkProperty(1e-3,'Unit','Pa*s','Description','water dynamic viscosity');
            obj.flow    = simulinkProperty([1 0  0]','Unit','m/s','Description','initial flow condition');
        end
    end
end