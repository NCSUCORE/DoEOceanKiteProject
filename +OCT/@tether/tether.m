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
            obj.numNodes        = OCT.param('IgnoreScaling',true);
            obj.diameter        = OCT.param('Unit','m');
            obj.youngsMod       = OCT.param('Unit','N/m^3');
            obj.vehicleMass     = OCT.param('Unit','kg');
            obj.dampingRatio    = OCT.param;
            obj.dragCoeff       = OCT.param;
            obj.density         = OCT.param('Unit','kg/m^3');
            obj.initGndNodePos  = OCT.param('Unit','m');
            obj.initAirNodePos  = OCT.param('Unit','m');
            obj.initGndNodeVel  = OCT.param('Unit','m/s');
            obj.initAirNodeVel  = OCT.param('Unit','m/s');
            obj.initNodePos     = OCT.param('Unit','m');
            obj.initNodeVel     = OCT.param('Unit','m/s');
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

