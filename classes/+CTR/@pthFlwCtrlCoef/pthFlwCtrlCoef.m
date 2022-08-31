classdef pthFlwCtrlCoef < handle
    %PTHFLWCTRL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        % FPID controllers
        tanRoll
        yawMoment
        pitchMoment
        rollMoment
        alphaCtrl
        % Reference Filter
        refFiltTau
        % Saturations
        maxBank
        controlSigMax
        elevCtrlMax
        % SIM.parameters
        winchSpeedIn
        winchSpeedOut
        searchSize
        perpErrorVal
        fcnName
        initPathVar
        rudderGain
        % Setpoint 
        AoAConst
        AoAmin
        Tmax
        TmaxCtrl
        % Discrete time sample rate
        Ts
    end
    properties (Dependent)
        discRefTau
    end
    methods
        function obj = pthFlwCtrlCoef
            %PTHFLWCTRL 
            obj.tanRoll             = CTR.FPID('rad','rad');
            obj.yawMoment           = CTR.FPID('rad','');
            obj.pitchMoment         = CTR.FPID('rad','');
            obj.rollMoment          = CTR.FPID('rad','');
            obj.alphaCtrl           = CTR.FPID('kN*s^2/m^2','rad');
            obj.refFiltTau          = SIM.parameter('Unit','s','Description','Reference filter time constant');
            
            obj.maxBank             = CTR.sat;
            obj.controlSigMax       = CTR.sat;
            obj.elevCtrlMax         = CTR.sat;
            
            obj.searchSize          = SIM.parameter('Unit','','Description','Range of normalized path variable to search','NoScale',true);
            obj.perpErrorVal        = SIM.parameter('Unit','rad','Description','Central angle at which we saturate the desired velocity to the tangent vector');
            obj.fcnName             = SIM.parameter('Unit','','Description','Name of the path shape function you want to use.','NoScale',true);
            obj.initPathVar         = SIM.parameter('Unit','','Description','Initial path variable');
            obj.rudderGain          = SIM.parameter('Value',-1,'Unit','','Description','0 Turns off rudder');
            
            obj.AoAConst            = SIM.parameter('Unit','deg','Description','Constant AoA setpoint');
            obj.AoAmin              = SIM.parameter('Unit','deg','Description','Minimum AoA setpoint');
            obj.Tmax                = SIM.parameter('Unit','kN','Description','Maximum tether tension limit');
            obj.Ts                  = SIM.parameter('Unit','s','Description','Controller time step','NoScale',1==1)';
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
        function setElevatorConst(obj,val,unit)
            obj.elevatorConst.setValue(val,unit);
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
        
        function val = get.discRefTau(obj)
                 gCont = tf(1,[obj.refFiltTau.Value 1]);
                 gDisc = c2d(gCont,obj.Ts.Value,'zoh');
                 [num,dem] = tfdata(gDisc);
                 val = SIM.parameter('Unit','','Description',...
                     'Discrete Time Vel Angle Filter Coefficients','Value',[num{1};dem{1}]);
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

