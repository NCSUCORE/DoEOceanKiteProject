classdef turb < handle
    %TURB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mass
        diameter
        axisUnitVec
        attachPtVec
        powerCoeff
        axialInductionFactor
        tipSpeepRatio
    end
    properties (Dependent)
        dragCoeff
        momentArm
        momentOfInertia
    end
    methods
        function obj = turb
            obj.mass                 = SIM.parameter('Unit','kg','Description','Rotor mass');
            obj.diameter             = SIM.parameter('Unit','m','Description','Diameter of the rotor');
            obj.axisUnitVec          = SIM.parameter('Description','Vector defining axis of rotation in body frame, should be close to [1 0 0]');
            obj.attachPtVec          = SIM.parameter('Unit','m','Description','Vector from CoM to turbine center, in body frame');
            obj.powerCoeff           = SIM.parameter('Unit','','Description','Coefficient used in power calculation');
            obj.axialInductionFactor = SIM.parameter('Unit','','Description','Relationship between CP and CD');
            obj.tipSpeepRatio        = SIM.parameter('Unit','','Description','Relationship between flow speed and rotor tip speed');
        end
        
        function setMass(obj,val,units)
            obj.mass.setValue(val,units)
        end
        
        function setDiameter(obj,val,units)
            obj.diameter.setValue(val,units)
        end

        function setAxisUnitVec(obj,val,units)
            obj.axisUnitVec.setValue(val,units)
        end

        function setAttachPtVec(obj,val,units)
            obj.attachPtVec.setValue(val,units)
        end

        function setPowerCoeff(obj,val,units)
            obj.powerCoeff.setValue(val,units)
        end
        
        function setAxalInductionFactor(obj,val,units)
            obj.axialInductionFactor.setValue(val,units)
        end
        
        function setTipSpeedRatio(obj,val,units)
            obj.tipSpeepRatio.setValue(val,units)
        end

        function val = get.dragCoeff(obj)
            val = SIM.parameter('Value',obj.powerCoeff.Value*obj.axialInductionFactor.Value,'Unit','');
        end
        
        function val = get.momentArm(obj)
            veh = OCT.vehicleM;
            val = SIM.parameter('Value',-veh.rB_LE.Value + obj.attachPtVec.Value,'Unit','m');
        end        
        
        function val = get.momentOfInertia(obj)
            val = SIM.parameter('Value',(obj.diameter.Value/2)^2*obj.mass.Value,'Unit','kg*m^2');
        end     
        
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

