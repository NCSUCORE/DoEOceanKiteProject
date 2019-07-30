classdef sixDoFStation < dynamicprops
    
    %SIXDOFSTATION Class definition for the floating, six DoF gnd station
    
    properties (SetAccess = private)
        % Inertial properties
        mass
        inertiaMatrix
        % Buoyancy properties
        volume
        centOfBuoy % Vector from CoM to CoB
        
        % Tether attachment points
        thrAttchPt1
        thrAttchPt2
        thrAttchPt3
        
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
            obj.inertiaMatrix   = SIM.parameter('Unit','kg*m^2','Description','3x3 inertia matrix');
            
            % Buoyancy properties
            obj.volume          = SIM.parameter('Unit','m^3','Description','Total volume used in buoyancy calculation');
            obj.centOfBuoy      = SIM.parameter('Unit','m','Description','Vector from CoM to CoB, in body frame.');
            
            % Tether attachment points
            obj.thrAttchPt1     = SIM.parameter('Unit','m','Description','Vector from CoB to tether attachment point 1, in body frame.');
            obj.thrAttchPt2     = SIM.parameter('Unit','m','Description','Vector from CoB to tether attachment point 2, in body frame.');
            obj.thrAttchPt3     = SIM.parameter('Unit','m','Description','Vector from CoB to tether attachment point 3, in body frame.');
            
            % Initial conditions
            obj.initPos         = SIM.parameter('Unit','m','Description','Initial position of the station in the ground frame.');
            obj.initVel         = SIM.parameter('Unit','m/s','Description','Initial velocity of the station in the ground frame.');
            obj.initEulAng      = SIM.parameter('Unit','rad','Description','Initial Euler angles of the station in the ground frame, radians.');
            obj.initAngVel      = SIM.parameter('Unit','rad/s','Description','Initial angular velocity of the station in the ground frame, radians per sec');
            
            % Anchor tethers
%             obj.numNodes = SIM.parameter('Unit','','NoScale',true,'Description','Number of nodes on each anchor tether');
            obj.anchThrs = OCT.tethers;
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
        
        % Tether attachment points
        function setThrAttchPt1(obj,val,unit)
        	obj.thrAttchPt1.setValue(val,unit);
        end
        function setThrAttchPt2(obj,val,unit)
        	obj.thrAttchPt2.setValue(val,unit);
        end
        function setThrAttchPt3(obj,val,unit)
        	obj.thrAttchPt3.setValue(val,unit);
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
        function setNumNodes(obj,val,unit)
            obj.numNodes.setValue(val,unit);
            obj.anchThrs.setNumTethers(3,'');
            obj.anchThrs.setNumNodes(obj.numNodes.Value,'');
            obj.anchThrs.build;
        end
        
    end
end

