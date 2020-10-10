classdef SLFAndSpoolCtrl < handle
    %PTHFLWCTRL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        % FPID controllers
        tanRoll
        yawMoment
        rollMoment
        pitchSP
        pitchSPkpSlope
        pitchSPkpInt
        pitchSPkiSlope
        pitchSPkiInt
        yawSP
        yawSPkpSlope
        yawSPkpInt
        yawSPkiSlope
        yawSPkiInt
        elevCmd
        rudderCmd
        % Saturations
        maxBank
        controlSigMax
        pitchAngleMax
        % Lower Level
        searchSize
        initPathVar
        fcnName
        perpErrorVal
        startControl
        elevatorReelInDef
        firstSpoolLap
        rudderGain
        % Spooling
        ctrlVecUpdateFcn
        tetherLengthSetpointFcn
        winchAndElevCmdFcn
        initSpdVec
        initCtrlVec
        intraDrift
        dockedTetherLength
        initTL
        maxTL
        switchFilterDuration
        switchFilterConstant
        nonXCurrentSpoolInGain
        spoolCtrlTimeConstant
        nomSpoolSpeed
        shortLeashLength
        LaRelevationSP
        LaRelevationSPErr
        % Pitch setpoint 
        pitchCtrl
        pitchConst
        pitchTime
        pitchLookup
        yawCtrl
        yawConst
    end
    
    methods
        function obj = SLFAndSpoolCtrl
            %PTHFLWCTRL 
            obj.tanRoll             = CTR.FPID('rad','rad');
            obj.yawMoment           = CTR.FPID('rad','N*m');
            obj.rollMoment          = CTR.FPID('rad','N*m');
            obj.pitchSP             = CTR.FPID('deg','deg');
            obj.pitchSPkpSlope      = SIM.parameter('Unit','','Description','Variable kp slope value','NoScale',true);
            obj.pitchSPkpInt        = SIM.parameter('Unit','','Description','Variable kp y-intercept value','NoScale',true);
            obj.pitchSPkiSlope      = SIM.parameter('Unit','','Description','Variable ki slope value','NoScale',true);
            obj.pitchSPkiInt        = SIM.parameter('Unit','','Description','Variable ki y-intercept value','NoScale',true);
            obj.yawSP               = CTR.FPID('deg','deg');
            obj.yawSPkpSlope        = SIM.parameter('Unit','','Description','Variable kp slope value','NoScale',true);
            obj.yawSPkpInt          = SIM.parameter('Unit','','Description','Variable kp y-intercept value','NoScale',true);
            obj.yawSPkiSlope        = SIM.parameter('Unit','','Description','Variable ki slope value','NoScale',true);
            obj.yawSPkiInt          = SIM.parameter('Unit','','Description','Variable ki y-intercept value','NoScale',true);
            obj.elevCmd             = CTR.FPID('rad','deg');
            obj.rudderCmd           = CTR.FPID('rad','deg');
            
            obj.maxBank             = CTR.sat;
            obj.controlSigMax       = CTR.sat;
            obj.pitchAngleMax       = CTR.sat;
            
            obj.searchSize          = SIM.parameter('Unit','','Description','Range of normalized path variable to search','NoScale',true);
            obj.initPathVar         = SIM.parameter('Unit','','Description','Initial path variable to begin golden section search around');
            obj.perpErrorVal        = SIM.parameter('Unit','rad','Description','Central angle at which we saturate the desired velocity to the tangent vector');
            obj.startControl        = SIM.parameter('Unit','s','Description','Time at which we switch the roll controller on');
            obj.elevatorReelInDef   = SIM.parameter('Unit','deg','Description','Deflection angle of elevator used during spool in');
            obj.firstSpoolLap       = SIM.parameter('Unit','','Description','First Lap to begin spooling');
            obj.rudderGain          = SIM.parameter('Value',1,'Unit','','Description','0 Turns off rudder');
            obj.fcnName             = SIM.parameter('Unit','','Description','Path Style');
            
            obj.ctrlVecUpdateFcn    = SIM.parameter('Unit','','Description','Function to calculate ctrl and speed vectors between laps');
            obj.tetherLengthSetpointFcn    = SIM.parameter('Unit','','Description','Function to calculate ctrl and speed vectors between laps');
            obj.winchAndElevCmdFcn  = SIM.parameter('Unit','','Description','Function to calculate ctrl and speed vectors between laps');
            obj.initCtrlVec         = SIM.parameter('Unit','','Description','initial control Vec parameter; depends on chosen functions');
            obj.initSpdVec          = SIM.parameter('Unit','m/s','Description','initial speed Vec parameter; depends on chosen functions');
            obj.intraDrift          = SIM.parameter('Value',0,'Unit','m','Description','Meters of drift per lap during intracycle');
            obj.dockedTetherLength  = SIM.parameter('Unit','m','Description','Meters of unspooled tether while kite is docked to groundstation');
            
            obj.initTL                  = SIM.parameter('Unit','m','Description','initial/spool-in/pure-intracycle tether length');
            obj.maxTL                   = SIM.parameter('Unit','m','Description','max tether length for multicycle');
            obj.switchFilterDuration    = SIM.parameter('Unit','s','Description','length of time to filter ctrlSurfDef after state switch');
            obj.switchFilterConstant    = SIM.parameter('Unit','s','Description','filter constant to use when filtering ctrlSurfDef after state switch');
            obj.nonXCurrentSpoolInGain  = SIM.parameter('Unit','','Description','Flow speed multiplier to get glide-in winch speed');
            obj.spoolCtrlTimeConstant   = SIM.parameter('Unit','s','Description','Time constant for spooling command');
            obj.nomSpoolSpeed           = SIM.parameter('Unit','m/s','Description','Nominal spooling speed');
            obj.shortLeashLength        = SIM.parameter('Unit','m','Description','Length of the short leash');
            obj.LaRelevationSP          = SIM.parameter('Unit','deg','Description','Reel-in elevation angle setpoint');
            obj.LaRelevationSPErr       = SIM.parameter('Unit','deg','Description','Reel-in elevation angle setpoint error where spooling is allowed');
            
            obj.pitchCtrl               = SIM.parameter('Unit','','Description','Flag to decide pitch setpoint source. 0 = contant; 1 = time-lookup; 2 = LaR');
            obj.pitchConst              = SIM.parameter('Unit','deg','Description','Constant pitch setpoint');
            obj.yawCtrl                 = SIM.parameter('Unit','','Description','Flag to decide yaw setpoint source. 0 = contant; 1 = LaR');
            obj.yawConst                = SIM.parameter('Unit','deg','Description','Constant yaw setpoint');
            obj.pitchTime               = SIM.parameter('Unit','s','Description','Reference time for pitch setpoint lookup table');
            obj.pitchLookup             = SIM.parameter('Unit','deg','Description','Pitch setpoint lookup values');
        end
        
        function setTanRoll(obj,val,units)
            obj.tanRoll.setValue(val,units)
        end

        function setYawMoment(obj,val,units)
            obj.yawMoment.setValue(val,units)
        end

        function setRollMoment(obj,val,units)
            obj.rollMoment.setValue(val,units)
        end

        function setSearchSize(obj,val,units)
            obj.searchSize.setValue(val,units)
        end

        function setPerpErrorVal(obj,val,units)
            obj.perpErrorVal.setValue(val,units)
        end

        function setStartControl(obj,val,units)
            obj.startControl.setValue(val,units)
        end

        function setElevatorReelInDef(obj,val,units)
            obj.elevatorReelInDef.setValue(val,units)
        end
        
        function setFcnName(obj,val,units)
            obj.fcnName.setValue(val,units)
        end

        function setFirstSpoolLap(obj,val,units)
            obj.firstSpoolLap.setValue(val,units)
        end

        function setRudderGain(obj,val,units)
            obj.rudderGain.setValue(val,units)
        end

        function setLaRelevationSP(obj,val,units)
            obj.LaRelevationSP.setValue(val,units)
        end

        function setLaRelevationSPErr(obj,val,units)
            obj.LaRelevationSPErr.setValue(val,units)
        end

        function setCtrlVecUpdateFcn(obj,val,units)
            obj.ctrlVecUpdateFcn.setValue(val,units)
        end

        function setTetherLengthSetpointFcn(obj,val,units)
            obj.tetherLengthSetpointFcn.setValue(val,units)
        end

        function setWinchAndElevCmdFcn(obj,val,units)
            obj.winchAndElevCmdFcn.setValue(val,units)
        end

        function setInitSpdVec(obj,val,units)
            obj.initSpdVec.setValue(val,units)
        end

        function setInitCtrlVec(obj,val,units)
            obj.initCtrlVec.setValue(val,units)
        end

        function setIntraDrift(obj,val,units)
            obj.intraDrift.setValue(val,units)
        end
        
        function setDockedTetherLength(obj,val,units)
            obj.dockedTetherLength.setValue(val,units)
        end

        function setInitTL(obj,val,units)
            obj.initTL.setValue(val,units)
        end

        function setMaxTL(obj,val,units)
            obj.maxTL.setValue(val,units)
        end

        function setSwitchFilterDuration(obj,val,units)
            obj.switchFilterDuration.setValue(val,units)
        end

        function setSwitchFilterConstant(obj,val,units)
            obj.switchFilterConstant.setValue(val,units)
        end

        function setNonXCurrentSpoolInGain(obj,val,units)
            obj.nonXCurrentSpoolInGain.setValue(val,units)
        end
        
        function setSpoolCtrlTimeConstant(obj,val,units)
            obj.spoolCtrlTimeConstant.setValue(val,units)
        end
        
        function setNomSpoolSpeed(obj,val,units)
            obj.nomSpoolSpeed.setValue(val,units)
        end
        
        function setShortLeashLength(obj,val,units)
            obj.shortLeashLength.setValue(val,units)
        end
        
        function setInitPathVar(obj,initPosVecGnd,geomParams,pathCntPosVec) %#ok<INUSD>
            pathVars = linspace(0,1,1000);
            posVecs = eval(sprintf('%s(pathVars,geomParams,pathCntPosVec)',obj.fcnName.Value));
            initPosVecGnd = repmat(initPosVecGnd(:),[1 numel(pathVars)]);
            dist = sqrt(sum((initPosVecGnd- posVecs).^2,1));
            [~,idx] = min(dist);
            obj.initPathVar.setValue(pathVars(idx),'');
        end

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

