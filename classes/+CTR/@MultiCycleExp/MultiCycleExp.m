classdef MultiCycleExp < handle
    %PTHFLWCTRL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        % FPID controllers
        tanRoll
        yawMoment
        rollMoment
        rollMomentPhase1
        % seperate set of pid gains so PID and PFC can run simultaneously
         rollCtrl
         yawCtrl
        % Saturations
        maxBank
        controlSigMax
        % SIM.parameters
        winchSpeedIn
        winchSpeedOut
        ctrlAllocMat
        searchSize
        traditionalBool
        bScale
        perpErrorVal
        startControl
        outRanges
        elevatorReelInDef
       
        fcnName
        initPathVar
        firstSpoolLap
        rudderGain
        
        %phase 1 constants
        elvDeflLaunch
        elvDeflStrt
        initTL
        sIM
        
        %phase 2 constants
        phase2Elevator %-6
        
        %phase 3 constants
        controllerEnable % 0 = Periodic ctrl, 1 = PFC
        vSat
        ccElevator
        tWait
         % period setpoint params
         period
         rollAmp

         rollPhase
         yawAmp
         yawPhase
         
         % transition gains
         gain4to1
         gain2to3
         maxTL
         elvPeak
         time23
         time41
         
         % las scaling
         vAppGain
         
         %ilc 
         ilcTrig
         initBasisParams
         learningGain
         forgettingFactor
         trustRegion
         whiteNoise
         enableVec
    end
    
    properties (Dependent)
        frequency           
    end
    methods
        function obj = MultiCycleExp
            %PTHFLWCTRL 
            obj.tanRoll             = CTR.FPID('rad','rad');
            obj.yawMoment           = CTR.FPID('rad','N*m');
            obj.rollMoment          = CTR.FPID('rad','N*m');
            obj.rollMomentPhase1    = CTR.FPID('rad','N*m');
            obj.yawCtrl             = CTR.FPID('rad','N*m');
            obj.rollCtrl            = CTR.FPID('rad','N*m');
            
            obj.maxBank             = CTR.sat;
            obj.controlSigMax       = CTR.sat;
            
            obj.winchSpeedIn        = SIM.parameter('Unit','m/s','Description','Max tether spool in speed.');
            obj.winchSpeedOut       = SIM.parameter('Unit','m/s','Description','Max tether spool out speed.');
            obj.ctrlAllocMat        = SIM.parameter('Unit','(deg)/(m^3)','Description','Control allocation matrix for control surfaces');
            obj.searchSize          = SIM.parameter('Unit','','Description','Range of normalized path variable to search','NoScale',true);
            obj.traditionalBool     = SIM.parameter('Unit','','Description','Switch for inter vs intra cycle spooling.  Should be phased out in favor of variant subsystem','NoScale',true);
            
            obj.perpErrorVal        = SIM.parameter('Unit','rad','Description','Central angle at which we saturate the desired velocity to the tangent vector');
            obj.startControl        = SIM.parameter('Unit','s','Description','Time at which we switch the roll controller on');
            obj.outRanges           = SIM.parameter('Unit','','Description','Upper/lower limits of path variable for spooling');
            obj.elevatorReelInDef   = SIM.parameter('Unit','deg','Description','Deflection angle of elevator used during spool in');
            
            obj.fcnName             = SIM.parameter('Unit','','Description','Name of the path shape function you want to use.','NoScale',true);
            obj.initPathVar         = SIM.parameter('Unit','','Description','Initial path variable');
            obj.firstSpoolLap       = SIM.parameter('Unit','','Description','First Lap to begin spooling');
            obj.rudderGain          = SIM.parameter('Value',1,'Unit','','Description','0 Turns off rudder');
            
            obj.elvDeflLaunch       = SIM.parameter('Unit','deg','Description','elv defl at launch');
            obj.elvDeflStrt         = SIM.parameter('Unit','deg','Description','elv defl at start');
            obj.initTL              = SIM.parameter('Unit','m','Description','starting and min tether length');
            obj.sIM                 = SIM.parameter('Unit','','Description','');
            obj.phase2Elevator      = SIM.parameter('Unit','deg','Description','phase 2 elevator');
            obj.controllerEnable    = SIM.parameter('Unit','','Description','switch between PFC and periodic setpoint ctrl');
            obj.vSat                = SIM.parameter('Unit','','Description','sat on spool out gain');
            obj.ccElevator          = SIM.parameter('Unit','deg','Description','crosscurrent elevator');
            obj.rollAmp             = SIM.parameter('Unit','deg','Description','roll sp amp');
            obj.tWait               = SIM.parameter('Unit','s','Description','time to wait before spooling');
            obj.period              = SIM.parameter('Unit','s','Description','Setpoint period');
            obj.bScale              = SIM.parameter('Unit','(N*s^2)/(deg*m)');
            obj.rollPhase           = SIM.parameter('Unit','rad','Description','roll sp phase');
            obj.yawAmp              = SIM.parameter('Unit','deg','Description','yaw sp amp');
            obj.yawPhase            = SIM.parameter('Unit','rad','Description','yaw sp phase');
            obj.gain4to1            = SIM.parameter('Unit','','Description','transition gain from phase 4 to 1');
            obj.gain2to3            = SIM.parameter('Unit','','Description','transition gain from phase 2 to 3');
            obj.maxTL               = SIM.parameter('Unit','m','Description','max and ending tether length');
            obj.elvPeak             = SIM.parameter('Unit','deg','Description','peak elevation during phase 1');
            obj.time23              = SIM.parameter('Unit','s','Description','time to transition between phase 2 and 3');
            obj.time41              = SIM.parameter('Unit','s','Description','time to transition between phase 4 and 1');
            obj.vAppGain            = SIM.parameter('Unit','','Value',1,'Description','gain on vAppSqr for LAS estimation');
            obj.ilcTrig             = SIM.parameter('Unit','','Description','turn ilc on or off. Off = 0, on = 1');
            obj.initBasisParams     = SIM.parameter('Unit','','Description','basis parameters');
            obj.learningGain        = SIM.parameter('Unit','','Description','learning gain ilc');
            obj.forgettingFactor    = SIM.parameter('Unit','','Description','forgetting factor');
            obj.trustRegion         = SIM.parameter('Unit','','Description','trust region');
            obj.whiteNoise          = SIM.parameter('Unit','','Description','perturbabtion');
            obj.enableVec           = SIM.parameter('Unit','','Description','which basis params are active');
           
        end
        
        function val = get.frequency(obj)
            freq = 2*pi/obj.period.Value;
            val = SIM.parameter('Unit','','Description','frequency of sinewave sp','Value',freq);
        end
        function setWinchSpeedIn(obj,val,unit)
            obj.winchSpeedIn.setValue(val,unit);
        end
        function setWinchSpeedOut(obj,val,unit)
            obj.winchSpeedOut.setValue(val,unit);
        end
        function setCtrlAllocMat(obj,val,unit)
            obj.ctrlAllocMat.setValue(val,unit);
        end
        function setSearchSize(obj,val,unit)
            obj.searchSize.setValue(val,unit);
        end
        function setFirstSpoolLap(obj,val,units)
            obj.firstSpoolLap.setValue(val,units)
        end
        function setTraditionalBool(obj,val,unit)
            obj.traditionalBool.setValue(val,unit);
        end
        function setMinR(obj,val,unit)
            obj.minR.setValue(val,unit);
        end
        function setPerpErrorVal(obj,val,unit)
            obj.perpErrorVal.setValue(val,unit);
        end
        function setStartControl(obj,val,unit)
            obj.startControl.setValue(val,unit);
        end
        function setOutRanges(obj,val,unit)
            obj.outRanges.setValue(val,unit);
        end
        function setElevatorReelInDef(obj,val,unit)
            obj.elevatorReelInDef.setValue(val,unit);
        end
        function setMaxR(obj,val,unit)
            obj.maxR.setValue(val,unit) ;
        end
        function setFcnName(obj,val,unit)
            obj.fcnName.setValue(val,unit);
        end
        
        function setInitPathVar(obj,initPosVecGnd,geomParams,pathCntPosVec)
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


