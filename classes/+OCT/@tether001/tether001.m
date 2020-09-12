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
        orgLengths
        maxLength
        minLinkLength
        minLinkDeviation
        minSoftLength
        initTetherLength
        minMaxLength
    end
    
    properties (Dependent)
        initNodePos
        initNodeVel
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
            obj.orgLengths          = SIM.parameter('Unit','m');
            obj.maxLength           = SIM.parameter('Unit','m');
            obj.minLinkLength       = SIM.parameter('Unit','m');
            obj.minLinkDeviation    = SIM.parameter('Unit','m');
            obj.minSoftLength       = SIM.parameter('Unit','m');
            obj.initTetherLength    = SIM.parameter('Unit','m');
            obj.minMaxLength        = CTR.sat;
        end
        
        function obj = setNumNodes(obj,val,units) %Number of nodes in tether
            obj.numNodes.setValue(val,units);
        end
        
        function obj = setDiameter(obj,val,units) %Diameter of tether
            obj.diameter.setValue(val,units);
        end
        
        function obj = setYoungsMod(obj,val,units) %Youngs modulus of tether
            obj.youngsMod.setValue(val,units);
        end
        
        function obj = setVehicleMass(obj,val,units) %mass of vehicle for damping
            obj.vehicleMass.setValue(val,units);
        end
        
        function obj = setDampingRatio(obj,val,units) %damping ratio of tether
            obj.dampingRatio.setValue(val,units);
        end
        
        function obj = setDragCoeff(obj,val,units) %drag coeff of tether
            obj.dragCoeff.setValue(val,units);
        end
        
        function obj = setDensity(obj,val,units) %tether density
            obj.density.setValue(val,units);
        end
        
        function obj = setInitGndNodePos(obj,val,units) %initial gnd node position
            obj.initGndNodePos.setValue(val,units);
        end
        
        function obj = setInitAirNodePos(obj,val,units) %initial air node position
            obj.initAirNodePos.setValue(val,units);
        end
        
        function obj = setInitGndNodeVel(obj,val,units) %initial gnd node velocity
            obj.initGndNodeVel.setValue(val,units);
        end
        
        function obj = setInitAirNodeVel(obj,val,units) %initial air node velocity
            obj.initAirNodeVel.setValue(val,units);
        end
     
        function val = get.orgLengths(obj) %length of segments at full extension
            val = ((obj.maxLength.Value)/(obj.numNodes.Value-1))*ones(1,obj.numNodes.Value-1);
            val = SIM.parameter('Value',val,'Unit','m');
        end
        
        function obj = setMaxLength(obj,val,units) %max tether length
            obj.maxLength.setValue(val,units);
        end
        
        function obj = setMinLinkLength(obj,val,units) %min link length for rediscretization
            obj.minLinkLength.setValue(val,units);
        end        
        
        function obj = setMinLinkDeviation(obj,val,units) %min link deviation for rediscretization
            obj.minLinkDeviation.setValue(val,units);
        end
        
        function obj = setMinSoftLength(obj,val,units) %length for spring softening to kick in
            obj.minSoftLength.setValue(val,units);
        end

        function obj = setInitTetherLength(obj,val,units) %intermediate nodes velocities
            obj.initTetherLength.setValue(val,units);
        end
        

        function val = get.initNodePos(obj) %sets intermediate node positions based on reeled out length
            if obj.numNodes.Value > 2 %sets intermediat nodes IC
                
                %Initilize
                ActiveLengths = zeros(size(obj.orgLengths.Value));
                L = zeros(size(ActiveLengths));
                
                %set flags and counters 
                a = 1;
                tetherInitflag1 = false;
                tetherInitflag2 = false;
                
                if obj.initTetherLength.Value == obj.maxLength.Value  %Full Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1);
                elseif obj.initTetherLength.Value >= obj.maxLength.Value  %Over Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1) + obj.initTetherLength.Value - obj.maxLength.Value;
                else %Any amount of reel-in
                    while tetherInitflag1 == false %finds position of bottom link
                        if obj.initTetherLength.Value == sum(obj.orgLengths.Value(a:end))
                            tetherInitflag1 = true;
                        elseif obj.initTetherLength.Value > sum(obj.orgLengths.Value(a:end))
                            tetherInitflag1 = true;
                        else
                            a=a+1;
                        end
                    end
                    %Update first link length value
                    FirstLink = obj.orgLengths.Value(a-1)-(sum(obj.orgLengths.Value((a-1):end))-obj.initTetherLength.Value);
                end
                
                if FirstLink < obj.minLinkLength.Value %If below limit
                    tetherInitflag2  = true;
                end
                
                if tetherInitflag2==true %If below min lenght absorb into next link
                    L((a):end) = [obj.orgLengths.Value(a)+FirstLink,obj.orgLengths.Value((a+1):end)];
                else %if not below limit just set first link to value
                    L((a-1):end) = [FirstLink,obj.orgLengths.Value((a):end)];
                end
                activeNodes = nnz(L)+1;

                spacingWeights = L/sum(L); %Weights spaces based on link lengths
                %Prealocates the nodes at the ground
                pos = [obj.initGndNodePos.Value(1)*ones(1,obj.numNodes.Value);...
                       obj.initGndNodePos.Value(2)*ones(1,obj.numNodes.Value);...
                       obj.initGndNodePos.Value(3)*ones(1,obj.numNodes.Value)]; 
                for ii = (obj.numNodes.Value-activeNodes+2):obj.numNodes.Value %sets nodes based on weights along line
                    if ii == find(spacingWeights,1,'first')+1
                        pos(1,ii) = spacingWeights(find(spacingWeights,1,'first'))*(obj.initAirNodePos.Value(1)-obj.initGndNodePos.Value(1))+pos(1,ii-1);
                        pos(2,ii) = spacingWeights(find(spacingWeights,1,'first'))*(obj.initAirNodePos.Value(2)-obj.initGndNodePos.Value(2))+pos(2,ii-1);
                        pos(3,ii) = spacingWeights(find(spacingWeights,1,'first'))*(obj.initAirNodePos.Value(3)-obj.initGndNodePos.Value(3))+pos(3,ii-1);
                    else
                        pos(1,ii) = spacingWeights(find(spacingWeights,1,'first')+1)*(obj.initAirNodePos.Value(1)-obj.initGndNodePos.Value(1))+pos(1,ii-1);
                        pos(2,ii) = spacingWeights(find(spacingWeights,1,'first')+1)*(obj.initAirNodePos.Value(2)-obj.initGndNodePos.Value(2))+pos(2,ii-1);
                        pos(3,ii) = spacingWeights(find(spacingWeights,1,'first')+1)*(obj.initAirNodePos.Value(3)-obj.initGndNodePos.Value(3))+pos(3,ii-1);
                    end
                end
                pos = pos(:,2:end-1);
            else %no intermediat nodes
                pos = [];
            end
            val = SIM.parameter('Value',pos,'Unit','m');
        end
        
        function val = get.initNodeVel(obj)
            if obj.numNodes.Value > 2 %sets intermediat nodes IC
                %Initilize
                ActiveLengths = zeros(size(obj.orgLengths.Value));
                L = zeros(size(ActiveLengths));
                
                %set flags and counters 
                a = 1;
                tetherInitflag1 = false;
                tetherInitflag2 = false;
                
                if obj.initTetherLength.Value == obj.maxLength.Value  %Full Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1);
                elseif obj.initTetherLength.Value >= obj.maxLength.Value  %Over Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1) + obj.initTetherLength.Value - obj.maxLength.Value;
                else %Any amount of reel-in
                    while tetherInitflag1 == false %finds position of bottom link
                        if obj.initTetherLength.Value == sum(obj.orgLengths.Value(a:end))
                            tetherInitflag1 = true;
                        elseif obj.initTetherLength.Value > sum(obj.orgLengths.Value(a:end))
                            tetherInitflag1 = true;
                        else
                            a=a+1;
                        end
                    end
                    %Update first link length value
                    FirstLink = obj.orgLengths.Value(a-1)-(sum(obj.orgLengths.Value((a-1):end))-obj.initTetherLength.Value);
                end
                
                if FirstLink < obj.minLinkLength.Value %If below limit
                    tetherInitflag2  = true;
                end
                
                if tetherInitflag2==true %If below min lenght absorb into next link
                    L((a):end) = [obj.orgLengths.Value(a)+FirstLink,obj.orgLengths.Value((a+1):end)];
                else %if not below limit just set first link to value
                    L((a-1):end) = [FirstLink,obj.orgLengths.Value((a):end)];
                end
                activeNodes = nnz(L)+1;

                spacingWeights = L/sum(L); %Weights spaces based on link lengths
                %Prealocates the nodes at the ground
                vel = [obj.initGndNodeVel.Value(1)*ones(1,obj.numNodes.Value);...
                       obj.initGndNodeVel.Value(2)*ones(1,obj.numNodes.Value);...
                       obj.initGndNodeVel.Value(3)*ones(1,obj.numNodes.Value)];
                for ii = (obj.numNodes.Value-activeNodes+2):obj.numNodes.Value %sets node velocities based on weights along line
                    if ii == find(spacingWeights,1,'first')+1
                        vel(1,ii) = spacingWeights(find(spacingWeights,1,'first'))*(obj.initAirNodeVel.Value(1)-obj.initGndNodeVel.Value(1))+vel(1,ii-1);
                        vel(2,ii) = spacingWeights(find(spacingWeights,1,'first'))*(obj.initAirNodeVel.Value(2)-obj.initGndNodeVel.Value(2))+vel(2,ii-1);
                        vel(3,ii) = spacingWeights(find(spacingWeights,1,'first'))*(obj.initAirNodeVel.Value(1)-obj.initGndNodeVel.Value(3))+vel(3,ii-1);
                    else
                        vel(1,ii) = spacingWeights(find(spacingWeights,1,'first')+1)*(obj.initAirNodeVel.Value(1)-obj.initGndNodeVel.Value(1))+vel(1,ii-1);
                        vel(2,ii) = spacingWeights(find(spacingWeights,1,'first')+1)*(obj.initAirNodeVel.Value(2)-obj.initGndNodeVel.Value(2))+vel(2,ii-1);
                        vel(3,ii) = spacingWeights(find(spacingWeights,1,'first')+1)*(obj.initAirNodeVel.Value(3)-obj.initGndNodeVel.Value(3))+vel(3,ii-1);
                    end
                end
                vel = vel(:,2:end-1);
            else %no intermediat nodes
                vel = [];
            end
            val = SIM.parameter('Value',vel,'Unit','m');
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

