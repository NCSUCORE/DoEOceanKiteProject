classdef turb < handle
    %TURB Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        numBlades
        hubMass
        bladeMass
        diameter
        hubDiameter
        axisUnitVec
        attachPtVec
        powerCoeff
        axialInductionFactor
        tipSpeepRatio
        dragCoef
        staticArea
        staticCD
        CpLookup
        CtLookup
        RPMref
    end
    properties (Dependent)
        mass
        dragCoeff
        momentArm
        momentOfInertia
    end
    methods
        function obj = turb
            obj.numBlades            = SIM.parameter('Unit','','Description','Number of blades');
            obj.hubMass              = SIM.parameter('Unit','kg','Description','Hub mass');
            obj.bladeMass            = SIM.parameter('Unit','kg','Description','Blade mass');
            obj.diameter             = SIM.parameter('Unit','m','Description','Total diameter of the rotor');
            obj.hubDiameter          = SIM.parameter('Unit','m','Description','Diameter of the hub');
            obj.axisUnitVec          = SIM.parameter('Description','Vector defining axis of rotation in body frame, should be close to [1 0 0]');
            obj.attachPtVec          = SIM.parameter('Unit','m','Description','Vector from CoM to turbine center, in body frame');
            obj.powerCoeff           = SIM.parameter('Unit','','Description','Coefficient used in power calculation');
            obj.dragCoef             = SIM.parameter('Unit','','Description','Coefficient used in drag calculation');
            obj.axialInductionFactor = SIM.parameter('Unit','','Description','Relationship between CP and CD');
            obj.tipSpeepRatio        = SIM.parameter('Unit','','Description','Relationship between flow speed and rotor tip speed');
            obj.staticArea           = SIM.parameter('Unit','m^2','Description','Projected area of the static turbine');
            obj.staticCD             = SIM.parameter('Unit','','Description','Turbine drag coefficient while static');
            obj.CpLookup             = SIM.parameter('Unit','','Description','Turbine power coefficient lookup');
            obj.CtLookup             = SIM.parameter('Unit','','Description','Turbine thrust coefficient lookup');
            obj.RPMref               = SIM.parameter('Unit','','Description','Turbine lookup table reference vector for tip-speed-ratio');
        end
        
        function setHubMass(obj,val,units)
            obj.hubMass.setValue(val,units)
        end

        function setBladeMass(obj,val,units)
            obj.bladeMass.setValue(val,units)
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
        
        function setDragCoef(obj,val,units)
            obj.dragCoef.setValue(val,units)
        end
        
        function setAxalInductionFactor(obj,val,units)
            obj.axialInductionFactor.setValue(val,units)
        end
        
        function setTipSpeedRatio(obj,val,units)
            obj.tipSpeepRatio.setValue(val,units)
        end
        
        function setStaticArea(obj,val,units)
            obj.staticArea.setValue(val,units)
        end

        function setStaticCD(obj,val,units)
            obj.staticCD.setValue(val,units)
        end

        function val = get.dragCoeff(obj)
            val = SIM.parameter('Value',obj.powerCoeff.Value*obj.axialInductionFactor.Value,'Unit','');
        end

        function val = get.mass(obj)
            val = SIM.parameter('Value',obj.numBlades.Value*obj.bladeMass.Value+obj.hubMass.Value,'Unit','kg','Description','Total turbine mass');
        end
        
        function val = get.momentArm(obj)
            veh = OCT.vehicleM;
            val = SIM.parameter('Value',-veh.rB_LE.Value + obj.attachPtVec.Value,'Unit','m');
        end        
        
        function val = get.momentOfInertia(obj)
            Jhub = 1/2*obj.hubMass.Value*(obj.hubDiameter.Value/2)^2;
            Jblade = 1/3*obj.bladeMass.Value*((obj.diameter.Value-obj.hubDiameter.Value)/2)^2;
            val = SIM.parameter('Value',Jhub+Jblade*obj.numBlades.Value,'Unit','kg*m^2');
        end     
        
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

