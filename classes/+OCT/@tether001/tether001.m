classdef tether001 < handle
    %TETHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
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
        dragEnable
        springDamperEnable
        netBuoyEnable
        orgLengths
        maxLength
        minMaxLength
        minLinkLength
        minLinkDeviation
        minSoftLength
    end
    
    methods
        function obj = tether001(numNodes)
            obj.numNodes        = SIM.parameter('Value',numNodes,'NoScale',true);
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
            obj.initNodePos     = SIM.parameter('Unit','m','Description','Initial conditions for intermediate (not end) nodes.');
            obj.initNodeVel     = SIM.parameter('Unit','m/s','Description','Initial conditions for intermediate (not end) nodes.');
            obj.dragEnable          = SIM.parameter('Value',true,'NoScale',true);
            obj.springDamperEnable  = SIM.parameter('Value',true,'NoScale',true);
            obj.netBuoyEnable       = SIM.parameter('Value',true,'NoScale',true);
            obj.orgLengths          = SIM.parameter('Unit','m');
            obj.maxLength           = SIM.parameter('Unit','m');
            obj.minLinkLength       = SIM.parameter('Unit','m');
            obj.minLinkDeviation    = SIM.parameter('Unit','m');
            obj.minSoftLength       = SIM.parameter('Unit','m');
            obj.minMaxLength        = CTR.sat;
        end
        
        function obj = setNumNodes(obj,val,units)
            obj.numNodes.setValue(val,units);
        end        
        function obj = setDiameter(obj,val,units)
            obj.diameter.setValue(val,units);
        end
        function obj = setYoungsMod(obj,val,units)
            obj.youngsMod.setValue(val,units);
        end
        function obj = setVehicleMass(obj,val,units)
            obj.vehicleMass.setValue(val,units);
        end
        function obj = setDampingRatio(obj,val,units)
            obj.dampingRatio.setValue(val,units);
        end
        function obj = setDragCoeff(obj,val,units)
            obj.dragCoeff.setValue(val,units);
        end
        function obj = setDensity(obj,val,units)
            obj.density.setValue(val,units);
        end
        function obj = setInitGndNodePos(obj,val,units)
            obj.initGndNodePos.setValue(val,units);
        end
        function obj = setInitAirNodePos(obj,val,units)
            obj.initAirNodePos.setValue(val,units);
        end
        function obj = setInitGndNodeVel(obj,val,units)
            obj.initGndNodeVel.setValue(val,units);
        end
        function obj = setInitAirNodeVel(obj,val,units)
            obj.initAirNodeVel.setValue(val,units);
        end
        function obj = setInit.setValueAirNodeVel(obj,val,units)
            % note rodney mitchell this looks like the same as above. DO we
            % need both methods?
            obj.initAirNodeVel.setValue(val,units);
        end
        function obj = setInitNodePos(obj,val,units)
            obj.initNodePos.setValue(val,units);
        end
        function obj = setInitNodeVel(obj,val,units)
            obj.initNodeVel.setValue(val,units);
        end
        function obj = setDragEnable(obj,val,units)
            if ~islogical(val)
                warning('Value is not logical, converting to %s',num2str(logical(val)))
                val = logical(val);
            end
            obj.dragEnable.setValue(val,units);
        end
        function obj = setSpringDamperEnable(obj,val,units)
            if ~islogical(val)
                warning('Value is not logical, converting to %s',num2str(logical(val)))
                val = logical(val);
            end
            obj.springDamperEnable.setValue(val,units);
        end
        function obj = setNetBuoyEnable(obj,val,units)
            if ~islogical(val)
                warning('Value is not logical, converting to %s',num2str(logical(val)))
                val = logical(val);
            end
            obj.netBuoyEnable.setValue(val,units);
        end
%         function obj = setOrgLengths(obj,val,units)
%             obj.setOrgLengths.setValue(val,units);
%         end
        function obj = setMaxLength(obj,val,units)
            obj.maxLength.setValue(val,units);
        end
        function obj = setMinLinkLength(obj,val,units)
            obj.minLinkLength.setValue(val,units);
        end
        function obj = setMinLinkDeviation(obj,val,units)
            obj.minLinkDeviation.setValue(val,units);
        end
        function obj = setMinSoftLength(obj,val,units)
            obj.minSoftLength.setValue(val,units);
        end
        
        function val = get.orgLengths(obj)
            val = ((obj.maxLength.Value)/(obj.numNodes.Value-1))*ones(1,obj.numNodes.Value-1);
            val = SIM.parameter('Value',val,'Unit','m');
        end
        
        function val = get.initNodePos(obj)
            % note rodney mitchell this forces the nodes to be evenly distributed between the gound and second to last node.
            % Is that what we want? This means that you cannot change the
            % initial value of any intermediate node. I mean, you can
            % change it, but you can't get it back once it's been changed.
            % If this behavior is intended I suggest making the property
            % dependent. If the behavior is not intended I suggest making a
            % class method for the intended behavior and releasing the get.
            if obj.numNodes.Value>2
                pos = ...
                    [linspace(obj.initGndNodePos.Value(1),obj.initAirNodePos.Value(1),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(2),obj.initAirNodePos.Value(2),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(3),obj.initAirNodePos.Value(3),obj.numNodes.Value)];
                pos = pos(:,2:end-1);
            else
                pos = [];
            end
            val = SIM.parameter('Value',pos,'Unit','m');
        end
        function val = get.initNodeVel(obj)
            if obj.numNodes.Value>2
                vel = ...
                    [linspace(obj.initGndNodeVel.Value(1),obj.initAirNodeVel.Value(1),obj.numNodes.Value);...
                    linspace(obj.initGndNodeVel.Value(2),obj.initAirNodeVel.Value(2),obj.numNodes.Value);...
                    linspace(obj.initGndNodeVel.Value(3),obj.initAirNodeVel.Value(3),obj.numNodes.Value)];
                vel = vel(:,2:end-1);
            else
                vel = [];
            end
            val = SIM.parameter('Value',vel,'Unit','m/s');
            
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

