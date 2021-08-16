classdef MantaFullCycle < handle
    %   MantaFullCycle: Class definition for the Manta Ray full-cycle controller 
    
    properties (SetAccess = private)
        % State machine 
        nonXCurrentSpoolInGain
        maxTL
        % FPID controllers
        SplRoll
        SplYaw
        SplPitch
        SplPitchSP
        SplPitchSPkpSlope
        SplPitchSPkpInt
        SplPitchSPkiSlope
        SplPitchSPkiInt
        SplRollSP
        SplRollSPkpSlope
        SplRollSPkpInt
        SplRollSPkiSlope
        SplRollSPkiInt
        SplPID
        % Saturations
        maxBank
        controlSigMax
        SplPitchMax
        PitchMomMax
        thrLengthMax
        Tmax
        % Path Following 
        searchSize
        initPathVar 
        fcnName
        perpErrorVal
        startControl
        rudderGain
        % Spooling
        winchSpeedIn
        winchSpeedOut
        firstSpoolLap
        nomSpoolSpeed
        shortLeashLength
        LaRelevationSP
        LaRelevationSPErr
        % Setpoint method ctrl 
        elevatorConst
        pitchCtrl
        pitchConst
        yawCtrl
        yawConst
        AoACtrl
        AoASP
        AoAConst
        optAltitude
    end
    
    methods
        function obj = MantaFullCycle
            % State machine 
            obj.nonXCurrentSpoolInGain = SIM.parameter('Unit','','Description','Gain used in switching logic','NoScale',true);
            obj.maxTL                  = SIM.parameter('Unit','m','Description','Maximum tether length');
            % FPID controllers
            obj.SplRoll             = CTR.FPID('rad','deg');
            obj.SplYaw              = CTR.FPID('rad','deg');
            obj.SplPitch            = CTR.FPID('rad','deg');
            obj.SplPitchSP          = CTR.FPID('deg','deg');
            obj.SplPitchSPkpSlope   = SIM.parameter('Unit','','Description','Variable pitch kp slope value','NoScale',true);
            obj.SplPitchSPkpInt     = SIM.parameter('Unit','','Description','Variable pitch kp y-intercept value','NoScale',true);
            obj.SplPitchSPkiSlope   = SIM.parameter('Unit','','Description','Variable pitch ki slope value','NoScale',true);
            obj.SplPitchSPkiInt     = SIM.parameter('Unit','','Description','Variable pitch ki y-intercept value','NoScale',true);
            obj.SplRollSP           = CTR.FPID('deg','deg');
            obj.SplRollSPkpSlope    = SIM.parameter('Unit','','Description','Variable roll kp slope value','NoScale',true);
            obj.SplRollSPkpInt      = SIM.parameter('Unit','','Description','Variable roll kp y-intercept value','NoScale',true);
            obj.SplRollSPkiSlope    = SIM.parameter('Unit','','Description','Variable roll ki slope value','NoScale',true);
            obj.SplRollSPkiInt      = SIM.parameter('Unit','','Description','Variable roll ki y-intercept value','NoScale',true);
            obj.SplPID              = CTR.FPID('m','m/s');
            % Saturations
            obj.maxBank             = CTR.sat;
            obj.controlSigMax       = CTR.sat;
            obj.SplPitchMax         = CTR.sat;
            obj.PitchMomMax         = CTR.sat;
            obj.thrLengthMax        = CTR.sat;
            obj.Tmax                = SIM.parameter('Unit','kN','Description','Maximum tether tension limit');
            % Path Following 
            obj.searchSize          = SIM.parameter('Unit','','Description','Range of normalized path variable to search','NoScale',true);
            obj.initPathVar         = SIM.parameter('Unit','','Description','Initial path variable to begin golden section search around');
            obj.fcnName             = SIM.parameter('Unit','','Description','Path Style');
            obj.perpErrorVal        = SIM.parameter('Unit','rad','Description','Central angle at which we saturate the desired velocity to the tangent vector');
            obj.startControl        = SIM.parameter('Unit','s','Description','Time at which we switch the roll controller on');
            obj.rudderGain          = SIM.parameter('Value',1,'Unit','','Description','0 Turns off rudder');
            % Spooling
            obj.winchSpeedIn        = SIM.parameter('Unit','m/s','Description','Max tether spool in speed.');
            obj.winchSpeedOut       = SIM.parameter('Unit','m/s','Description','Max tether spool out speed.');
            obj.firstSpoolLap       = SIM.parameter('Unit','','Description','First Lap to begin spooling');
            obj.nomSpoolSpeed       = SIM.parameter('Unit','m/s','Description','Nominal spooling speed');
            obj.shortLeashLength    = SIM.parameter('Unit','m','Description','Length of the short leash');
            obj.LaRelevationSP      = SIM.parameter('Unit','deg','Description','Reel-in elevation angle setpoint');
            obj.LaRelevationSPErr   = SIM.parameter('Unit','deg','Description','Reel-in elevation angle setpoint error where spooling is allowed');
            % Setpoint method ctrl 
            obj.elevatorConst       = SIM.parameter('Unit','deg','Description','Deflection angle of elevator used during spool in');
            obj.AoACtrl             = SIM.parameter('Unit','','Description','Flag to decide AoA control. 0 = none; 1 = On');
            obj.AoASP               = SIM.parameter('Unit','','Description','Flag to decide AoA control. 0 = constant; 1 = time-lookup');
            obj.AoAConst            = SIM.parameter('Unit','deg','Description','Constant AoA setpoint');
            obj.pitchCtrl           = SIM.parameter('Unit','','Description','Flag to decide pitch setpoint source. 0 = contant; 1 = time-lookup; 2 = LaR');
            obj.pitchConst          = SIM.parameter('Unit','deg','Description','Constant pitch setpoint');
            obj.yawCtrl             = SIM.parameter('Unit','','Description','Flag to decide yaw setpoint source. 0 = contant; 1 = LaR');
            obj.yawConst            = SIM.parameter('Unit','deg','Description','Constant yaw setpoint');
            obj.optAltitude         = SIM.parameter('Unit','m','Description','Mean operating altitude');
        end
        %%  Setters
        function setSearchSize(obj,val,units)
            obj.searchSize.setValue(val,units)
        end
        
        function setInitPathVar(obj,initPosVecGnd,geomParams,pathCntPosVec) %#ok<INUSD>
            pathVars = linspace(0,1,1000);
            posVecs = eval(sprintf('%s(pathVars,geomParams,pathCntPosVec)',obj.fcnName.Value));
            initPosVecGnd = repmat(initPosVecGnd(:),[1 numel(pathVars)]);
            dist = sqrt(sum((initPosVecGnd- posVecs).^2,1));
            [~,idx] = min(dist);
            obj.initPathVar.setValue(pathVars(idx),'');
        end

        function setFcnName(obj,val,units)
            obj.fcnName.setValue(val,units)
        end
        
        function setPerpErrorVal(obj,val,units)
            obj.perpErrorVal.setValue(val,units)
        end

        function setStartControl(obj,val,units)
            obj.startControl.setValue(val,units)
        end
        
        function setRudderGain(obj,val,units)
            obj.rudderGain.setValue(val,units)
        end
        
        function setWinchSpeedIn(obj,val,unit)
            obj.winchSpeedIn.setValue(val,unit);
        end
        
        function setWinchSpeedOut(obj,val,unit)
            obj.winchSpeedOut.setValue(val,unit);
        end
        
        function setFirstSpoolLap(obj,val,units)
            obj.firstSpoolLap.setValue(val,units)
        end
        
        function setNomSpoolSpeed(obj,val,units)
            obj.nomSpoolSpeed.setValue(val,units)
        end
        
        function setShortLeashLength(obj,val,units)
            obj.shortLeashLength.setValue(val,units)
        end

        function setLaRelevationSP(obj,val,units)
            obj.LaRelevationSP.setValue(val,units)
        end

        function setLaRelevationSPErr(obj,val,units)
            obj.LaRelevationSPErr.setValue(val,units)
        end

        function setPitchCtrl(obj,val,units)
            obj.pitchCtrl.setValue(val,units)
        end

        function setPitchConst(obj,val,units)
            obj.pitchConst.setValue(val,units)
        end

        function setYawCtrl(obj,val,units)
            obj.yawCtrl.setValue(val,units)
        end

        function setYawConst(obj,val,units)
            obj.yawConst.setValue(val,units)
        end
        
        %%  Scaling
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)

            props = getPropsByClass(obj,'CTR.sat');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
            props = getPropsByClass(obj,'SIM.parameter');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
            props = getPropsByClass(obj,'CTR.FPID');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
            props = getPropsByClass(obj,'CTR.PID');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end % end scale
        
        val = getPropsByClass(obj,className)
        
        
    end
end

