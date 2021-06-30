classdef tetherM < handle
    % tetherM is the tether for the Manta Ray kite.  This model allows for
    % reel-in, reel-out, multi-node tether, and the addition of fairing to
    % reduce drag at the top of the tether near the kite.  It is a bead
    % model where the forces are applied to the nodes
    
    properties (SetAccess = private)
        linkLength       % Length of a single link
        nominalDrag      % Drag coeff on tether
        fairingDrag      % Drag coeff on tether with farrings
        fairingLength    % Fairing length measured from kite
        diameter         % Total tether diameter
        youngsMod        % Total tether Youngs Modulus
        dampingRatio     % Tether damping ratio
        density          % Total tether density
        initGndNodePos   % Initial ground node (glider/ground) position
        initAirNodePos   % Initial air node (kite) position
        initGndNodeVel   % Initial ground node (glider/ground) velocity
        initAirNodeVel   % Initial air node (kite) velocity
        maxTetherLength  % Max tether that is avalible total
        minLinkLength    % Minimum individual link length (increasing this
        % value can help with stiffness seen at short link
        % lengths)
        initTetherLength % Initial total tether length
        numTethers
        minLinkDeviation
        minSoftLength
        numNodes    % Total nodes in tether
    end
    
    properties (Dependent) % Dependent properties
        orgLengths  % link lengths based on total tether and reeled-out
        dragCoeff   % Total drag vector based on fairing drag, nominal
        initNodePos % Initial intermediate node positions
        initNodeVel % Initial intermediate node velocities
    end
    
    methods
        %% Set the tetherM object
        function obj = tetherM %%%'Description','Number of tethers',%%%
            obj.linkLength       = SIM.parameter('Unit','m');
            obj.nominalDrag      = SIM.parameter;
            obj.fairingDrag      = SIM.parameter;
            obj.fairingLength    = SIM.parameter('Unit','m');
            obj.diameter         = SIM.parameter('Unit','m');
            obj.youngsMod        = SIM.parameter('Unit','Pa');
            obj.dampingRatio     = SIM.parameter;
            obj.density          = SIM.parameter('Unit','kg/m^3');
            obj.initGndNodePos   = SIM.parameter('Unit','m');
            obj.initAirNodePos   = SIM.parameter('Unit','m');
            obj.initGndNodeVel   = SIM.parameter('Unit','m/s');
            obj.initAirNodeVel   = SIM.parameter('Unit','m/s');
            obj.maxTetherLength  = SIM.parameter('Unit','m');
            obj.minLinkLength    = SIM.parameter('Unit','m');
            obj.initTetherLength = SIM.parameter('Unit','m');
            obj.numTethers       = SIM.parameter('Value',1,'Unit','');
            obj.minLinkDeviation = SIM.parameter('Value',.1,'Unit','');
            obj.minSoftLength    = SIM.parameter('Value',0,'Unit','');
            obj.numNodes         = SIM.parameter('Unit','');
        end
        
        
        %% Set properties
        function obj = setLinkLength(obj,val,units)         %
            obj.linkLength.setValue(val,units);
        end
        
        function obj = setNominalDrag(obj,val,units)      % Nominal Drag tether
            obj.nominalDrag.setValue(val,units);
        end
        
        function obj = setFairingDrag(obj,val,units)      % Tether fairing drag
            obj.fairingDrag.setValue(val,units);
        end
        
        function obj = setFairingLength(obj,val,units)    % Tether fairing length from kite
            obj.fairingLength.setValue(val,units);
        end
        
        function obj = setDiameter(obj,val,units)         % Diameter of tether
            obj.diameter.setValue(val,units);
        end
        
        function obj = setYoungsMod(obj,val,units)        % Youngs modulus of tether
            obj.youngsMod.setValue(val,units);
        end
        
        function obj = setVehicleMass(obj,val,units)      % Mass of vehicle for damping
            obj.vehicleMass.setValue(val,units);
        end
        
        function obj = setDampingRatio(obj,val,units)     % Damping ratio of tether
            obj.dampingRatio.setValue(val,units);
        end
        
        function obj = setDensity(obj,val,units)          % Tether density
            obj.density.setValue(val,units);
        end
        
        function obj = setInitGndNodePos(obj,val,units)   % Initial gnd node position
            obj.initGndNodePos.setValue(val,units);
        end
        
        function obj = setInitAirNodePos(obj,val,units)   % Initial air node position
            obj.initAirNodePos.setValue(val,units);
        end
        
        function obj = setInitGndNodeVel(obj,val,units)   % Initial gnd node velocity
            obj.initGndNodeVel.setValue(val,units);
        end
        
        function obj = setInitAirNodeVel(obj,val,units)   % Initial air node velocity
            obj.initAirNodeVel.setValue(val,units);
        end
        
        function obj = setMaxTetherLength(obj,val,units)  % Max tether length
            obj.maxTetherLength.setValue(val,units);
        end
        
        function obj = setMinLinkLength(obj,val,units)    % Min link length for rediscretization
            obj.minLinkLength.setValue(val,units);
        end
        
        function obj = setInitTetherLength(obj,val,units) % Total initial tether length
            obj.initTetherLength.setValue(val,units);
        end
        
        
        %% Set the dependend properties
%         function val = get.numNodes(obj) %length of segments at full extension
%             val = obj.maxTetherLength.Value/obj.linkLength.Value+1;
%             if mod(val,1)~=0
%                 error('Total length/link length is not and integer')
%             elseif obj.fairingLength.Value <= obj.linkLength.Value
%                 error('Link length is to large')
%             else
%                 val = SIM.parameter('Value',val,'Unit','m');
%             end
%         end
        function val = get.orgLengths(obj) %length of segments at full extension
            val = ((obj.maxTetherLength.Value)/(obj.numNodes.Value-1))*ones(1,obj.numNodes.Value-1);
            val = SIM.parameter('Value',val,'Unit','m');
        end
        
        function val = get.dragCoeff(obj)  % Total drag coeff vector based on fair/nom drag farring length
            numFairingLinks = floor((obj.numNodes.Value-1)*obj.fairingLength.Value/obj.maxTetherLength.Value);
            numNominalLinks = (obj.numNodes.Value-1)-numFairingLinks;
            val = [obj.fairingDrag.Value*ones(1,numFairingLinks),obj.nominalDrag.Value*ones(1,numNominalLinks)];
            val = SIM.parameter('Value',fliplr(val),'Unit','');
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
                
                if obj.initTetherLength.Value == obj.maxTetherLength.Value  %Full Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1);
                elseif obj.initTetherLength.Value >= obj.maxTetherLength.Value  %Over Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1) + obj.initTetherLength.Value - obj.maxTetherLength.Value;
                else %Any amount of reel-in
                    while tetherInitflag1 == false %finds position of bottom link
                        if obj.initTetherLength.Value == sum(obj.orgLengths.Value(a:end))
                            tetherInitflag1 = true;
                        elseif obj.initTetherLength.Value > sum(obj.orgLengths.Value(a:end))
                            tetherInitflag1 = true;
                        else
                            a=a+1;
                        end
                        if a == 15
                            g=7;
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
        
        function val = get.initNodeVel(obj) %sets intermediate node velocities based on reeled out length
            if obj.numNodes.Value > 2 %sets intermediat nodes IC
                %Initilize
                ActiveLengths = zeros(size(obj.orgLengths.Value));
                L = zeros(size(ActiveLengths));
                
                %set flags and counters
                a = 1;
                tetherInitflag1 = false;
                tetherInitflag2 = false;
                
                if obj.initTetherLength.Value == obj.maxTetherLength.Value  %Full Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1);
                elseif obj.initTetherLength.Value >= obj.maxTetherLength.Value  %Over Extension
                    a = a+1;
                    L(1:end) = obj.orgLengths.Value(1:end);
                    FirstLink = obj.orgLengths.Value(1) + obj.initTetherLength.Value - obj.maxTetherLength.Value;
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
        
        
        %% Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

