classdef fltAndSpoolCtrl < handle
    %PTHFLWCTRL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        % FPID controllers
        tanRoll
        yawMoment
        rollMoment
        % Saturations
        maxBank
        controlSigMax
        % Lower Level
        searchSize
        initPathVar
        fcnName
        perpErrorVal
        startControl
        elevatorReelInDef
        firstSpoolLap
        rudderGain
        
        %Spooling
        ctrlVecUpdateFcn
        tetherLengthSetpointFcn
        winchAndElevCmdFcn
        initSpdVec
        initCtrlVec
        intraDrift
        
        %Multicycle
        initTL
        maxTL
        nonXCurrentElevator
        nonXCurrentElevation
        switchFilterDuration
        switchFilterConstant
        beginXCurrentFlowGain
        beginNonXCurrentFlowGain
        nonXCurrentSpoolInGain
    end
    
    methods
        function obj = fltAndSpoolCtrl
            %PTHFLWCTRL 
            obj.tanRoll             = CTR.FPID('rad','rad');
            obj.yawMoment           = CTR.FPID('rad','N*m');
            obj.rollMoment          = CTR.FPID('rad','N*m');
            
            obj.maxBank             = CTR.sat;
            obj.controlSigMax       = CTR.sat;
            
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
            
            obj.initTL                  = SIM.parameter('Unit','m','Description','initial/spool-in/pure-intracycle tether length');
            obj.maxTL                   = SIM.parameter('Unit','m','Description','max tether length for multicycle');
            obj.nonXCurrentElevator     = CTR.FPID('rad','rad');
            obj.nonXCurrentElevation    = SIM.parameter('Unit','deg','Description','elevation setpoint during non cross current');
            obj.switchFilterDuration    = SIM.parameter('Unit','s','Description','length of time to filter ctrlSurfDef after state switch');
            obj.switchFilterConstant    = SIM.parameter('Unit','s','Description','filter constant to use when filtering ctrlSurfDef after state switch');
            obj.beginXCurrentFlowGain   = SIM.parameter('Unit','','Description','gain to multiply flowSpeed by to set threshold to enter Cross-Current');
            obj.beginNonXCurrentFlowGain= SIM.parameter('Unit','','Description','gain to multiply flowSpeed by to set threshold to enter Non-Cross-Current');
            obj.nonXCurrentSpoolInGain  = SIM.parameter('Unit','','Description','Flow speed multiplier to get glide-in winch speed');
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

        function setInitTL(obj,val,units)
            obj.initTL.setValue(val,units)
        end

        function setMaxTL(obj,val,units)
            obj.maxTL.setValue(val,units)
        end

        function setNonXCurrentElevator(obj,val,units)
            obj.nonXCurrentElevator.setValue(val,units)
        end

        function setNonXCurrentElevation(obj,val,units)
            obj.nonXCurrentElevation.setValue(val,units)
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

        function setBeginXCurrentFlowGain(obj,val,units)
            obj.beginXCurrentFlowGain.setValue(val,units)
        end

        function setBeginNonXCurrentFlowGain(obj,val,units)
            obj.beginNonXCurrentFlowGain.setValue(val,units)
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

