classdef steadyCoef < handle
    %PTHFLWCTRL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        % FPID controllers
        tanRoll
        yawMoment
        rollMoment
        pitchSP
        pitchMoment
        % Saturations
        pitchAngleMax
        controlSigMax
        % SIM.parameters
        ctrlAllocMat
        fcnName
        initPathVar
        firstSpoolLap
        rudderGain
        Ts
    end
    
    methods
        function obj = steadyCoef
            %SLFCTRL 
            obj.tanRoll             = CTR.FPID('rad','rad');
            obj.yawMoment           = CTR.FPID('rad','');
            obj.rollMoment          = CTR.FPID('rad','');
            obj.pitchMoment         = CTR.FPID('rad','');
            obj.pitchSP             = CTR.FPID('m','rad');
            obj.pitchAngleMax       = CTR.sat;
            obj.controlSigMax       = CTR.sat;
            
            obj.ctrlAllocMat        = SIM.parameter('Unit','(deg)/(m^3)','Description','Control allocation matrix for control surfaces');
            obj.fcnName             = SIM.parameter('Unit','','Description','Name of the path shape function you want to use.','NoScale',true);
            obj.rudderGain          = SIM.parameter('Value',-1,'Unit','','Description','0 Turns off rudder');
            obj.initPathVar         = SIM.parameter('Unit','','Description','Initial Path Variable');
            obj.Ts                  = SIM.parameter('Unit','s','Description','Discrete Time Sample Timestep','NoScale',true);
        end
        
        function setCtrlAllocMat(obj,val,unit)
            obj.ctrlAllocMat.setValue(val,unit);
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

