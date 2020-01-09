classdef sixDoFStation < dynamicprops
    
    %SIXDOFSTATION Class definition for the floating, six DoF gnd station
    
    properties (SetAccess = private)
        % Inertial properties
        mass
        inertiaMatrix
        
        % Buoyancy properties
        volume
        lumpedMassPositionMatrixBdy
        lumpedMassSphereRadius
        lumpedMassNetBouyancyForce
        addedMassMatrix
        
        % Initial conditions
        posVec
        initVel
        initAngPos
        initAngVel
        initAnchTetherLength
        
        
        %kite tether
        numTethers 
        
        % Anchor tethers
        anchThrs
        
    end
    
    methods
        function obj = sixDoFStation
            % Inertial properties
            obj.mass                        = SIM.parameter('Unit','kg','Description','Total mass of system');
            obj.inertiaMatrix               = SIM.parameter('Unit','kg*m^2','Description','3x3 inertia matrix');
            
            % Buoyancy properties
            obj.volume                      = SIM.parameter('Unit','m^3','Description','Total volume used in buoyancy calculation');
            obj.lumpedMassPositionMatrixBdy = SIM.parameter('Unit','m','Description','lumped mass position matrix');
            obj.lumpedMassSphereRadius      = SIM.parameter('Unit','m','Description','lumped mass sphere radius');
            obj.lumpedMassNetBouyancyForce  = SIM.parameter('Unit','N','Description','lumped mass net bouyancy force');
            % Initial conditions
            obj.posVec                      = SIM.parameter('Unit','m','Description','Initial position of the station in the ground frame.');
            obj.initVel                     = SIM.parameter('Unit','m/s','Description','Initial velocity of the station in the ground frame.');
            obj.initAngPos                  = SIM.parameter('Unit','rad','Description','Initial Euler angles of the station in the ground frame, radians.');
            obj.initAngVel                  = SIM.parameter('Unit','rad/s','Description','Initial angular velocity of the station in the ground frame, radians per sec');
            obj.initAnchTetherLength        = SIM.parameter('Unit','m','Description','Unstretched Tether Length');
            obj.numTethers                  = SIM.parameter('Unit','','Description','number of kite tethers');
            
            % Anchor tethers
            obj.anchThrs = OCT.tethers;
        end
        
        %function to add tether attach points for the kites tether
        function obj = build(obj,varargin)
            % Populate cell array of default names
            defThrName = {};
            for ii = 1:obj.numTethers.Value
                defThrName{ii} = sprintf('thrAttch%d',ii);
            end
            p = inputParser;
            addParameter(p,'TetherNames',defThrName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            parse(p,varargin{:})
            
            % Create tethers
            for ii = 1:obj.numTethers.Value
                obj.addprop(p.Results.TetherNames{ii});
                obj.(p.Results.TetherNames{ii}) = OCT.thrAttch;
            end
        end
        
   
        % Method to add tether attachment points
        function obj = addThrAttch(obj,Name,posVec)
            addprop(obj,Name);
            obj.(Name) = OCT.thrAttch;
            obj.(Name).setPosVec(posVec,'m');
        end
        
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
        % Setters
        % Inertial properties
        function setMass(obj,val,unit)
            obj.mass.setValue(val,unit);
        end
        function setInertiaMatrix(obj,val,unit)
            obj.inertiaMatrix.setValue(val,unit);
        end
        % Buoyancy properties
        function setVolume(obj,val,unit)
            obj.volume.setValue(val,unit);
        end
        
        function setLumpedMassSphereRadius(obj,val,unit)
            obj.lumpedMassSphereRadius.setValue(val,unit);
        end
        
        function setLumpedMassPositionMatrixBdy(obj,val,unit)
            obj.lumpedMassPositionMatrixBdy.setValue(val,unit);
        end
        
        function setLumpedMassNetBouyancyForce(obj,val,unit)
            obj.lumpedMassNetBouyancyForce.setValue(val,unit)
        end
        
        function setInitAnchTetherLength(obj,val,unit)
            obj.initAnchTetherLength.setValue(val,unit)
        end
        
        function setNumTethers(obj,val,unit)
            obj.numTethers.setValue(val,unit)
        end
        
        function bouyancy(obj)
            numLM     =  numel(obj.lumpedMassPositionMatrixBdy.Value)/3;
            gravForce = (obj.mass.Value/numLM)*9.81;
            bouyForce = (obj.volume.Value/numLM)*1000*9.81;
            netBouyancyPerLM = -gravForce + bouyForce;
            obj.setLumpedMassNetBouyancyForce(netBouyancyPerLM,'N')
        end
        % Initial conditions
        function setPosVec(obj,val,unit)
            obj.posVec.setValue(val,unit);
        end
        function setInitVel(obj,val,unit)
            obj.initVel.setValue(val,unit);
        end
        function setInitAngPos(obj,val,unit)
            obj.initAngPos.setValue(val,unit);
        end
        function setInitAngVel(obj,val,unit)
            obj.initAngVel.setValue(val,unit);
        end
        
        % Function to get properties according to their class
        % May be able to vectorize this somehow
        function val = getPropsByClass(obj,className)
            props = properties(obj);
            val = {};
            for ii = 1:length(props)
                if isa(obj.(props{ii}),className)
                    val{end+1} = props{ii};
                end
            end
        end
        function val = struct(obj,className,prefix)
            % Function returns all properties of the specified class in a
            % 1xN struct useable in a for loop in simulink
            % Example classnames: OCT.turb, OCT.aeroSurf
            props = sort(obj.getPropsByClass(className));
            props = props(contains(props,prefix,'IgnoreCase',true)); % Sort on the ones containing the prefix
            if numel(props)<1
                return
            end
            subProps = properties(obj.(props{1}));
            for ii = 1:length(props)
                for jj = 1:numel(subProps)
                    val(ii).(subProps{jj}) = obj.(props{ii}).(subProps{jj}).Value;
                end
            end
        end
        
        function plotLumps(obj)
            
            scatter3(obj.lumpedMassPositionMatrixBdy.Value(1,:),obj.lumpedMassPositionMatrixBdy.Value(2,:),obj.lumpedMassPositionMatrixBdy.Value(3,:))
            hold on
            plot3(obj.lumpedMassPositionMatrixBdy.Value(1,:),obj.lumpedMassPositionMatrixBdy.Value(2,:),obj.lumpedMassPositionMatrixBdy.Value(3,:))
        end
        
    end
end

