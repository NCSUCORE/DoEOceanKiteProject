classdef umWinch < handle
    %WINCH Simple model of winch dynamics, velocity is rate limited,
    %filtered and saturated.  Output is tether length.  Also includes power
    %consumption/production estimate. 
    
    properties (SetAccess = private)
        initLength
        maxSpeed
        timeConst
        maxAccel
        
        rectifierEfficiency
        inverterEfficiency
        statorResistanceGen
        rotorMagneticFluxGen
        frictionCoefficiantGen
        numPolePairsGen
        statorResistanceMot
        rotorMagneticFluxMot
        frictionCoefficiantMot
        numPolePairsMot
        
        drumRadius
        drumInertia
        
        
        initReleaseRate
        
        gearRatio
        numOfGearPairs
        
    end
    
    methods
        function obj = umWinch
            obj.initLength                  = SIM.parameter('Unit','m');
            obj.maxSpeed                    = SIM.parameter('Unit','m/s');
            obj.timeConst                   = SIM.parameter('Unit','s');
            obj.maxAccel                    = SIM.parameter('Unit','m/s^2');
            obj.rectifierEfficiency         = SIM.parameter('Unit','');
            obj.inverterEfficiency          = SIM.parameter('Unit','');
            obj.statorResistanceGen         = SIM.parameter('Unit','');
            obj.rotorMagneticFluxGen        = SIM.parameter('Unit','');
            obj.frictionCoefficiantGen      = SIM.parameter('Unit','');
            obj.numPolePairsGen             = SIM.parameter('Unit','');
            obj.statorResistanceMot         = SIM.parameter('Unit','');
            obj.rotorMagneticFluxMot        = SIM.parameter('Unit','');
            obj.frictionCoefficiantMot      = SIM.parameter('Unit','');
            obj.numPolePairsMot             = SIM.parameter('Unit','');
            
            obj.drumRadius                  = SIM.parameter('Unit','m');
            obj.drumInertia                 = SIM.parameter('Unit','kg*m^2');
            obj.initReleaseRate             = SIM.parameter('Unit','m/s');
            
            obj.gearRatio                   = SIM.parameter('Unit','');
            obj.numOfGearPairs              = SIM.parameter('Unit','');
        end
        
        function obj = setInitLength(obj,val,units)
            obj.initLength.setValue(val,units)
        end
        function obj = setMaxSpeed(obj,val,units)
            obj.maxSpeed.setValue(val,units)
        end
        function obj = setTimeConst(obj,val,units)
            obj.timeConst.setValue(val,units)
        end
        function obj = setMaxAccel(obj,val,units)
            obj.maxAccel.setValue(val,units)
        end
        
        function obj = setRectifierEfficiency(obj,val,units)
            obj.rectifierEfficiency.setValue(val,units)
        end
        
        function obj = setInverterEfficiency(obj,val,units)
            obj.inverterEfficiency.setValue(val,units)
        end
        
        function obj = setStatorResistanceGen(obj,val,units)
            obj.statorResistanceGen.setValue(val,units)
        end
        
        function obj = setRotorMagneticFluxGen(obj,val,units)
            obj.rotorMagneticFluxGen.setValue(val,units)
        end
        
        function obj = setFrictionCoefficiantGen(obj,val,units)
            obj.frictionCoefficiantGen.setValue(val,units)
        end
        
        function obj = setNumPolePairsGen(obj,val,units)
            obj.numPolePairsGen.setValue(val,units)
        end
        
        function obj = setStatorResistanceMot(obj,val,units)
            obj.statorResistanceMot.setValue(val,units)
        end
        
        function obj = setRotorMagneticFluxMot(obj,val,units)
            obj.rotorMagneticFluxMot.setValue(val,units)
        end
        
        function obj = setFrictionCoefficiantMot(obj,val,units)
            obj.frictionCoefficiantMot.setValue(val,units)
        end
        
        function obj = setNumPolePairsMot(obj,val,units)
            obj.numPolePairsMot.setValue(val,units)
        end
        
        function obj = setDrumRadius(obj,val,units)
            obj.drumRadius.setValue(val,units);
        end
        
        function obj = setDrumInertia(obj,val,units)
            obj.drumInertia.setValue(val,units);
        end
        
        function obj = setInitReleaseRate(obj,val,units)
            obj.initReleaseRate.setValue(val,units);
        end
            
        function obj = setGearRatio(obj,val,units)
            obj.gearRatio.setValue(val,units);
        end
        function obj = setNumOfGearPairs(obj,val,units)
            obj.numOfGearPairs.setValue(val,units);
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