classdef fuselage < handle
    %FUSE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        diameter
        rNose_LE
        rEnd_LE
        sideDragCoeff
        endDragCoeff
    end
    
    properties (Dependent)
        length
        rAeroCent_LE
        volume
    end
    
    methods
        %% Constructor
        function obj = fuselage
            obj.diameter             = SIM.parameter('Unit','m');
            obj.rNose_LE             = SIM.parameter('Unit','m','Description','Vector from the wing LE to the front of the fuselage');
            obj.rEnd_LE              = SIM.parameter('Unit','m','Description','Vector from the wing LE to the end of the fuselage');
            obj.sideDragCoeff        = SIM.parameter('Description','Drag Coeff if at 90 degrees angle of attack');
            obj.endDragCoeff         = SIM.parameter('Description','Drag Coeff if at 0 degrees angle of attack');
        end
        %% Setters
        function setDiameter(obj,val,units)
            obj.diameter.setValue(val,units)
        end

        function setRNose_LE(obj,val,units)
            obj.rNose_LE.setValue(val,units)
        end

        function setREnd_LE(obj,val,units)
            obj.rEnd_LE.setValue(val,units)
        end

        function setSideDragCoeff(obj,val,units)
            obj.sideDragCoeff.setValue(val,units)
        end

        function setEndDragCoeff(obj,val,units)
            obj.endDragCoeff.setValue(val,units)
        end
        
        %% Getters        
        function val = get.length(obj)
            val = SIM.parameter('Value',norm(obj.rNose_LE.Value-obj.rEnd_LE.Value),...
                'Unit','m','Description','Total length of fuselage');
        end
        
        function val = get.volume(obj)
            vol = obj.length.Value*pi*(obj.diameter.Value/2)^2 ... % Volume of a cylinder with flat ends
                  -(obj.diameter.Value^3-(4/3)*pi*(obj.diameter.Value/2)^3); % Subtract off missing volume round off the ends
            val = SIM.parameter('Value',vol,'Unit','m^3');
        end
        
        function val = get.rAeroCent_LE(obj)
            %Currently assumes front to back symmetry (aero cent at
            % 50% of total length.
            val = SIM.parameter('Value',(obj.rNose_LE.Value+obj.rEnd_LE.Value)*.5,...
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

