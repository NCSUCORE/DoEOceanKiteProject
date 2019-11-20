classdef sixDoFStation < dynamicprops
    
    %SIXDOFSTATION Class definition for the floating, six DoF gnd station
    
    properties (SetAccess = private)
        % Inertial properties
        mass
        inertiaMatrix
        % Buoyancy properties
        volume
        centOfBuoy % Vector from CoM to CoB
        height
        
%         % Tether attachment point to the vehicle
%         airThrAttchPt
%         % Tether attachment point of anchor tether with body
%         bdyThrAttchPt1
%         bdyThrAttchPt2
%         bdyThrAttchPt3
%         % Tether attachment point of anchor tether with ground
%         gndThrAttchPt1
%         gndThrAttchPt2
%         gndThrAttchPt3
        
        % Drag coefficient
        dragCoeff
                
        % Initial conditions
        initPos
        initVel
        initEulAng
        initAngVel
        
        % Anchor tethers
        anchThrs
        
    end
    
    methods
        function obj = sixDoFStation
            % Inertial properties
            obj.mass            = SIM.parameter('Unit','kg','Description','Total mass of system');
            obj.height          = SIM.parameter('Unit','m','Description','Vertical Height of the Ground Station');
            obj.inertiaMatrix   = SIM.parameter('Unit','kg*m^2','Description','3x3 inertia matrix');
            
            % Buoyancy properties
            obj.volume          = SIM.parameter('Unit','m^3','Description','Total volume used in buoyancy calculation');
            obj.centOfBuoy      = SIM.parameter('Unit','m','Description','Vector from CoM to CoB, in body frame.');
            
%             % Tether attachment point to the vehicle
%             obj.airThrAttchPt   = OCT.thrAttch;
%             % Tether attachment point of anchor tether with body
%             obj.bdyThrAttchPt1  = OCT.thrAttch;
%             obj.bdyThrAttchPt2  = OCT.thrAttch;
%             obj.bdyThrAttchPt3  = OCT.thrAttch;
%             % Tether attachment point of anchor tether with ground
%             obj.gndThrAttchPt1 	= OCT.thrAttch;
%             obj.gndThrAttchPt2 	= OCT.thrAttch;
%             obj.gndThrAttchPt3 	= OCT.thrAttch;
                       
            % Drag coefficient
            obj.dragCoeff       = SIM.parameter('Unit','','Description','Drag coefficient of submerged bit of platform');
            
            % Initial conditions
            obj.initPos         = SIM.parameter('Unit','m','Description','Initial position of the station in the ground frame.');
            obj.initVel         = SIM.parameter('Unit','m/s','Description','Initial velocity of the station in the ground frame.');
            obj.initEulAng      = SIM.parameter('Unit','rad','Description','Initial Euler angles of the station in the ground frame, radians.');
            obj.initAngVel      = SIM.parameter('Unit','rad/s','Description','Initial angular velocity of the station in the ground frame, radians per sec');
            
            % Anchor tethers
            obj.anchThrs = OCT.tethers;
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
        function setCentOfBuoy(obj,val,unit)
            obj.centOfBuoy.setValue(val,unit);
        end
        % Drag coefficient
        function setDragCoefficient(obj,val,unit)
            obj.dragCoeff.setValue(val,unit);
        end
        
        % Initial conditions
        function setInitPos(obj,val,unit)
            obj.initPos.setValue(val,unit);
        end
        function setInitVel(obj,val,unit)
            obj.initVel.setValue(val,unit);
        end
        function setInitEulAng(obj,val,unit)
            obj.initEulAng.setValue(val,unit);
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
        
       
    end
end

