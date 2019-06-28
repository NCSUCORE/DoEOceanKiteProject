classdef tether < handle
    %TETHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numNodes
        diameter
        youngsMod
        vehicleMass
        dampingRatio
        dragCoeff
        density
        initGndNodePos
        initAirNodePos
        initGndNodeVel
        initAirNodeVel
        initNodePos
        initNodeVel
    end
    
    methods
        function obj = tether
            obj.numNodes        = SIM.parameter('NoScale',true);
            obj.diameter        = SIM.parameter('Unit','m');
            obj.youngsMod       = SIM.parameter('Unit','Pa');
            obj.vehicleMass     = SIM.parameter('Unit','kg');
            obj.dampingRatio    = SIM.parameter;
            obj.dragCoeff       = SIM.parameter;
            obj.density         = SIM.parameter('Unit','kg/m^3');
            obj.initGndNodePos  = SIM.parameter('Unit','m');
            obj.initAirNodePos  = SIM.parameter('Unit','m');
            obj.initGndNodeVel  = SIM.parameter('Unit','m/s');
            obj.initAirNodeVel  = SIM.parameter('Unit','m/s');
            obj.initNodePos     = SIM.parameter('Unit','m');
            obj.initNodeVel     = SIM.parameter('Unit','m/s');
        end 
        
        function val = get.initNodePos(obj)
            val = obj.initNodePos;
            if obj.numNodes.Value>2
                vel = ...
                    [linspace(obj.initGndNodePos.Value(1),obj.initAirNodePos.Value(1),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(2),obj.initAirNodePos.Value(2),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(3),obj.initAirNodePos.Value(3),obj.numNodes.Value)];
                obj.initNodePos.setValue(vel(:,2:end-1),'m');
                val = obj.initNodePos;
            end
        end
        function val = get.initNodeVel(obj)
            val = obj.initNodeVel;
            if obj.numNodes.Value>2
                vel = ...
                    [linspace(obj.initGndNodeVel.Value(1),obj.initAirNodeVel.Value(1),obj.numNodes.Value);...
                    linspace(obj.initGndNodeVel.Value(2),obj.initAirNodeVel.Value(2),obj.numNodes.Value);...
                    linspace(obj.initGndNodeVel.Value(3),obj.initAirNodeVel.Value(3),obj.numNodes.Value)];
                obj.initNodeVel.setValue(vel(:,2:end-1),'m/s');
                val = obj.initNodeVel;
            end
        end
        % Function to scale the object
        function obj = scale(obj,scaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(scaleFactor);
            end
        end
    end
end

