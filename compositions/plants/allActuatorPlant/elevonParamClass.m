classdef elevonParamClass < handle
    properties
        elevon_max_deflection
        elevon_gain
        elevator_control
        aileron_control
        P_cs_mat
        CM_nom
        k_CM
    end
    methods
        function obj = elevonParamsClass
            obj.elevon_max_deflection   = simulinkProperty(30*ones(2,1));
            obj.elevon_gain             = simulinkProperty(0.4);
            obj.elevator_control        = simulinkProperty()
            obj.aileron_control
            obj.P_cs_mat
            obj.CM_nom
            obj.k_CM
        end
    end
end