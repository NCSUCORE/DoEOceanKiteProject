classdef fuselage < handle
    %FUSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        diameter
        rCmToNose
        rCmToEnd
        sideDragCoeff
        endDragCoeff
    end
    
    properties (Dependent)
        length
        aeroCentPosVec
    end
    
    methods
        %% Constructor
        function obj = fuselage
            obj.diameter             = SIM.parameter('Unit','m');
            obj.rCmToNose            = SIM.parameter('Unit','m','Description','Vector from the kite CM to the front of the fuselage');
            obj.rCmToEnd             = SIM.parameter('Unit','m','Description','Vector from the kite CM to the end of the fuselage');
            obj.sideDragCoeff        = SIM.parameter('Description','Drag Coeff if at 90 degrees angle of attack');
            obj.endDragCoeff         = SIM.parameter('Description','Drag Coeff if at 0 degrees angle of attack');
        end
        %% Setters
        
        function setDiameter(obj,val,units)
            obj.diameter.setValue(val,units)
        end

        function setRCmToNose(obj,val,units)
            obj.rCmToNose.setValue(val,units);
        end
        
        function setRCmToEnd(obj,val,units)
            obj.rCmToEnd.setValue(val,units);
        end
        
        function setSideDragCoeff(obj,val,units)
            obj.sideDragCoeff.setValue(val,units);
        end
        
        function setEndDragCoeff(obj,val,units)
            obj.endDragCoeff.setValue(val,units);
        end
        %% Getters 
        function val = get.length(obj)
            val = SIM.parameter('Value',norm(obj.rCmToNose.Value-obj.rCmToEnd.Value),...
                'Unit','m','Description','Total length of fuselage');
        end
        
        function val = get.aeroCentPosVec(obj)
            %Currently assumes front to back symmetry (aero cent at
            % 50% of total length.
            val = SIM.parameter('Value',(obj.rCmToNose.Value+obj.rCmToEnd.Value)*.5,...
                'Unit','m','Description','Vector from the kite CM to the fuselage aero center');
        end
        
        %% Other Methods
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

