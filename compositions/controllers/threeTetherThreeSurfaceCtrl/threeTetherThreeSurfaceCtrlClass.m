classdef threeTetherThreeSurfaceCtrlClass < handle
    properties
        elevonPitchKp
        elevonPitchKi
        elevonPitchKd
        elevonPitchTau
        
        elevonRollKp
        elevonRollKi
        elevonRollKd
        elevonRollTau
        
        tetherAltitudeKp
        tetherAltitudeKi
        tetherAltitudeKd
        tetherAltitudeTau
        
        tetherPitchKp
        tetherPitchKi
        tetherPitchKd
        tetherPitchTau
        
        tetherRollKp
        tetherRollKi
        tetherRollKd
        tetherRollTau
        
        setPitchDeg
        setAltM
        setRollDeg
    end
    
    methods
        % Constructor function
        function obj = threeTetherThreeSurfaceCtrlClass
            obj.elevonPitchKp   = simulinkProperty(10   ,'Unit','');
            obj.elevonPitchKi   = simulinkProperty(0    ,'Unit','1/s');
            obj.elevonPitchKd   = simulinkProperty(30   ,'Unit','s');
            obj.elevonPitchTau  = simulinkProperty(0.05 ,'Unit','s');
            
            obj.elevonRollKp   = simulinkProperty(4  ,'Unit','');
            obj.elevonRollKi   = simulinkProperty(0  ,'Unit','1/s');
            obj.elevonRollKd   = simulinkProperty(8  ,'Unit','s');
            obj.elevonRollTau  = simulinkProperty(0.2,'Unit','s');
             
            obj.tetherAltitudeKp   = simulinkProperty(0.5   ,'Unit','1/s');
            obj.tetherAltitudeKi   = simulinkProperty(0     ,'Unit','1/s^2');
            obj.tetherAltitudeKd   = simulinkProperty(0.25  ,'Unit','');
            obj.tetherAltitudeTau  = simulinkProperty(1/0.0314,'Unit','s');
            
            obj.tetherPitchKp   = simulinkProperty(0.7500,'Unit','m/s');
            obj.tetherPitchKi   = simulinkProperty(0     ,'Unit','m/s^2');
            obj.tetherPitchKd   = simulinkProperty(1.875 ,'Unit','m');
            obj.tetherPitchTau  = simulinkProperty(1/1.2566,'Unit','s');
            
            obj.tetherRollKp   = simulinkProperty(0.1875,'Unit','m/s');
            obj.tetherRollKi   = simulinkProperty(0     ,'Unit','m/s^2');
            obj.tetherRollKd   = simulinkProperty(0.375 ,'Unit','m');
            obj.tetherRollTau  = simulinkProperty(1/1.2566,'Unit','s');
            
            obj.setPitchDeg = simulinkProperty(7  ,'Unit','deg');
            obj.setAltM     = simulinkProperty(200,'Unit','m');
            obj.setRollDeg  = simulinkProperty(0  ,'Unit','deg');

        end
        
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            scaleObj(obj,lengthScaleFactor,densityScaleFactor)
        end
    end
end
