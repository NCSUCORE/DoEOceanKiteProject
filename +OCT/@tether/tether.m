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
            obj.numNodes        = SIM.param('IgnoreScaling',true);
            obj.diameter        = SIM.param('Unit','m');
            obj.youngsMod       = SIM.param('Unit','N/m^3');
            obj.vehicleMass     = SIM.param('Unit','kg');
            obj.dampingRatio    = SIM.param;
            obj.dragCoeff       = SIM.param;
            obj.density         = SIM.param('Unit','kg/m^3');
            obj.initGndNodePos  = SIM.param('Unit','m');
            obj.initAirNodePos  = SIM.param('Unit','m');
            obj.initGndNodeVel  = SIM.param('Unit','m/s');
            obj.initAirNodeVel  = SIM.param('Unit','m/s');
            obj.initNodePos     = SIM.param('Unit','m');
            obj.initNodeVel     = SIM.param('Unit','m/s');
        end 
        
        function val = get.initNodePos(obj)
            val = obj.initNodePos;
            if obj.numNodes.Value>2
                vel = ...
                    [linspace(obj.initGndNodePos.Value(1),obj.initAirNodePos.Value(1),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(2),obj.initAirNodePos.Value(2),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(3),obj.initAirNodePos.Value(3),obj.numNodes.Value)];
                obj.initNodePos.Value = vel(:,2:end-1);
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
                obj.initNodeVel.Value = vel(:,2:end-1);
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

