classdef allActuatorPlantClass < handle
    properties
        N = simulinkProperty(5,'Description','Number of tether nodes');
        aero_param
        geom_param
        env_param
        turbine_param
        tether_param
        tether_imp_nodes
        platform_param
    end
    
    methods
        % Constructor function
        function obj = allActuatorPlantClass
            % Initialize all the sub-classes (not the right word)
            obj.aero_param    = aeroParamsClass;
            obj.geom_param    = geomParamsClass;
            obj.env_param     = envParamsClass;
            obj.turbine_param = turbineParamClass;
            obj.tether_param  = tetherParamClass;
            obj.tether_imp_nodes = tetherImpNodesParamClass;
            obj.platform_param = platformParamClass;
            
            % Calculate all the parameters with interdependence
            obj.aero_param.setupGeometry(obj.geom_param);
            obj.geom_param.setupInertial(obj.aero_param,obj.env_param);
            obj.turbine_param.setupTurbines(obj.env_param,obj.geom_param);
            obj.tether_param.setupTether(obj.env_param);
            obj.tether_imp_nodes.setupTetherEndNodes(obj.aero_param,obj.geom_param);
        end
        % Function to scale all parameters
        function obj = scale(obj,scaleFactor)
            obj = scaleObj(obj,scaleFactor);
        end
    end
end
