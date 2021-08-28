classdef tetherF < handle
    %TETHER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        numNodes
        diameter
        youngsMod
        vehicleMass
        dampingRatio
        nomDragCoeff
        fairedDragCoeff
        fairedLength
        fairedLinks
        maxThrLength
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
        transVoltage
    end
    properties (Dependent)
        dragCoeff
        resistance
        linkLengths
    end
    methods
        function obj = tetherF(numNodes)
            obj.numNodes        = SIM.parameter('Value',numNodes,'NoScale',true);
            obj.diameter        = SIM.parameter('Unit','m');
            obj.youngsMod       = SIM.parameter('Unit','Pa');
            obj.vehicleMass     = SIM.parameter('Unit','kg');
            obj.dampingRatio    = SIM.parameter;
            obj.nomDragCoeff    = SIM.parameter;
            obj.fairedDragCoeff = SIM.parameter;
            obj.fairedLength    = SIM.parameter('Unit','m');
            obj.fairedLinks     = SIM.parameter('Unit','');
            obj.maxThrLength    = SIM.parameter('Unit','m');
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
            obj.transVoltage        = SIM.parameter('Unit','V','Description','Tether transmission voltage');
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
        function obj = setNumNodes(obj,val,units)
            obj.numNodes.setValue(val,units);
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


        function val = get.dragCoeff(obj)  % Total drag coeff vector based on fair/nom drag farring length
            numLinks = obj.numNodes.Value-1;  
            numNominalLinks = numLinks-obj.fairedLinks.Value;
            val = [obj.fairedDragCoeff.Value*ones(1,obj.fairedLinks.Value),obj.nomDragCoeff.Value*ones(1,numNominalLinks)];
            val = SIM.parameter('Value',fliplr(val),'Unit','');
        end               
%         function val = get.dragCoeff(obj)  % Total drag coeff vector based on fair/nom drag farring length
%             numLinks = obj.numNodes.Value-1;  linkLength = obj.maxThrLength.Value/numLinks;
%             numFairingLinks = floor(obj.fairedLength.Value/linkLength);
%             numNominalLinks = numLinks-numFairingLinks;
%             val = [obj.fairedDragCoeff.Value*ones(1,numFairingLinks),obj.nomDragCoeff.Value*ones(1,numNominalLinks)];
%             val = SIM.parameter('Value',fliplr(val),'Unit','');
%         end        
        function val = get.resistance(obj) 
            maxTL = obj.maxThrLength.Value;
            refTL = 304.8;  refR = 7.1;
            val = SIM.parameter('Value',refR*maxTL/refTL,'Unit','Ohm','Description','Internal conductor resistance');
        end        
        function val = get.linkLengths(obj)
            vecs = diff([obj.initGndNodePos.Value obj.initNodePos.Value obj.initAirNodePos.Value],1,2);
            lengths  = sqrt(dot(vecs,vecs));
            val = SIM.parameter('Value',lengths,'Description','Unstretched Lengths of Tether Links','Unit','m');
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
                if obj.fairedLength == 0
                pos = ...
                    [linspace(obj.initGndNodePos.Value(1),obj.initAirNodePos.Value(1),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(2),obj.initAirNodePos.Value(2),obj.numNodes.Value);...
                    linspace(obj.initGndNodePos.Value(3),obj.initAirNodePos.Value(3),obj.numNodes.Value)];
                pos = pos(:,2:end-1);
                else
                unfairedLinks = obj.numNodes.Value-1-obj.fairedLinks.Value;
                    if rem(obj.fairedLinks.Value,1) ~= 0
                        error('Incorrect faired length or faired link lenght. Must be divisible')
                    end
                    rAG = obj.initAirNodePos.Value-obj.initGndNodePos.Value;
                    magRAG = sqrt(dot(rAG,rAG));
                    fairStop = rAG*(1-obj.fairedLength.Value/magRAG);
                    posFair = ...
                        [linspace(fairStop(1),obj.initAirNodePos.Value(1),obj.fairedLinks.Value+1);
                         linspace(fairStop(2),obj.initAirNodePos.Value(2),obj.fairedLinks.Value+1);
                         linspace(fairStop(3),obj.initAirNodePos.Value(3),obj.fairedLinks.Value+1)];
                    posUnfair = ...
                        [linspace(obj.initGndNodePos.Value(1),fairStop(1),unfairedLinks+1);
                         linspace(obj.initGndNodePos.Value(2),fairStop(2),unfairedLinks+1);
                         linspace(obj.initGndNodePos.Value(3),fairStop(3),unfairedLinks+1)];
                    pos = [posUnfair(:,2:end) posFair(:,2:end-1)];
                end                    
            else
                pos = [];
            end
            val = SIM.parameter('Value',pos,'Unit','m');
        end
        
        function val = get.initNodeVel(obj)
            if obj.numNodes.Value>2
                if obj.fairedLength == 0
                vel = ...
                    [linspace(obj.initGndNodeVel.Value(1),obj.initAirNodeVel.Value(1),obj.numNodes.Value);...
                    linspace(obj.initGndNodeVel.Value(2),obj.initAirNodeVel.Value(2),obj.numNodes.Value);...
                    linspace(obj.initGndNodeVel.Value(3),obj.initAirNodeVel.Value(3),obj.numNodes.Value)];
                vel = vel(:,2:end-1);
                else
                unfairedLinks = obj.numNodes.Value-1-obj.fairedLinks.Value;
                    if rem(obj.fairedLinks.Value,1) ~= 0
                        error('Incorrect faired length or faired link lenght. Must be divisible')
                    end
                    rAG = obj.initAirNodePos.Value-obj.initGndNodePos.Value
                    vAG = obj.initAirNodeVel.Value-obj.initGndNodeVel.Value
                    magRAG = sqrt(dot(rAG,rAG));
                    fairStop = vAG*(1-obj.fairedLength.Value/magRAG)
                    velFair = ...
                        [linspace(fairStop(1),obj.initAirNodeVel.Value(1),obj.fairedLinks.Value+1);
                         linspace(fairStop(2),obj.initAirNodeVel.Value(2),obj.fairedLinks.Value+1);
                         linspace(fairStop(3),obj.initAirNodeVel.Value(3),obj.fairedLinks.Value+1)];
                    velUnfair = ...
                        [linspace(obj.initGndNodeVel.Value(1),fairStop(1),unfairedLinks+1);
                         linspace(obj.initGndNodeVel.Value(2),fairStop(2),unfairedLinks+1);
                         linspace(obj.initGndNodeVel.Value(3),fairStop(3),unfairedLinks+1)];
                    vel = [velUnfair(:,2:end) velFair(:,2:end-1)]
                end        
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

