classdef aeroSurf < handle
    %AEROSURF Summary of this class goes here
    %   Detailed explanation goes here
    properties (SetAccess = private)
        meanChord
        tipChord
        rootChord
        taperRatio
        
        incidenceAngle
        sweepAngle
        dihedralAngle
        
        spanUnitVec
        span
        
        chordUnitVec
        chord
        
        cornerPoint
        
        refArea
        aeroCentPosVec
        
        cornerPoints
        
        CL
        CD
        alpha
        GainCL
        GainCD
        MaxCtrlDeflDn
        MaxCtrlDeflUp
        
    end
    
    methods
        function obj = aeroSurf
            obj.rootChord       = SIM.parameter('Unit','m');
            obj.tipChord        = SIM.parameter('Unit','m');
            obj.meanChord       = SIM.parameter('Unit','m','Description','Mean of root and tip chords');
            obj.taperRatio      = SIM.parameter('Unit','');
            
            obj.incidenceAngle  = SIM.parameter('Unit','deg');
            obj.sweepAngle      = SIM.parameter('Unit','deg');
            obj.dihedralAngle   = SIM.parameter('Unit','deg');
            
            obj.spanUnitVec     = SIM.parameter('Unit','');
            obj.span            = SIM.parameter('Unit','m');
            
            obj.chordUnitVec    = SIM.parameter('Unit','');
            obj.chord           = SIM.parameter('Unit','m');
            
            obj.cornerPoint      = SIM.parameter('Unit','m');
            
            obj.refArea         = SIM.parameter('Unit','m^2');
            obj.aeroCentPosVec  = SIM.parameter('Unit','m');
            
            obj.cornerPoints    = SIM.parameter('Unit','m');
            
            obj.CL              = SIM.parameter('Unit','');
            obj.CD              = SIM.parameter('Unit','');
            obj.alpha           = SIM.parameter('Unit','deg');
            obj.GainCL          = SIM.parameter('Unit','1/deg');
            obj.GainCD          = SIM.parameter('Unit','1/deg');
            obj.MaxCtrlDeflDn   = SIM.parameter('Unit','deg');
            obj.MaxCtrlDeflUp   = SIM.parameter('Unit','deg');
        end
        %% Setters
        function setTaperRatio(obj,val)
            if val>1
                warning('Taper ratio > 1: tip chord > root chord')
            end
            obj.taperRatio.setValue(val,'');
            obj.tipChord.setValue(obj.taperRatio.Value*obj.rootChord.Value,'m');
            obj.meanChord.setValue((obj.tipChord.Value+obj.rootChord.Value)/2,'m')
        end
        
        function setTipChord(obj,val,units)
            obj.tipChord.setValue(val,units);
            obj.taperRatio.setValue(obj.tipChord.Value/obj.rootChord.Value,'');
            obj.meanChord.setValue((obj.tipChord.Value+obj.rootChord.Value)/2,'m')
        end
        
        function setRootChord(obj,val,units)
            obj.rootChord.setValue(val,units);
            obj.taperRatio.setValue(obj.tipChord.Value/obj.rootChord.Value,'');
            obj.meanChord.setValue((obj.tipChord.Value+obj.rootChord.Value)/2,'m')
        end
        function setMeanChord(obj,val,units)
            obj.meanChord.setValue(val,units);
            obj.tipChord.setValue(val,'m');
            obj.rootChord.setValue(val,'m');
            obj.taperRatio.setValue(1,'');
        end
        function setIncidenceAngle(obj,val,units)
            obj.incidenceAngle.setValue(val,units)
        end
        function setSweepAngle(obj,val,units)
            obj.sweepAngle.setValue(val,units)
        end
        function setDihedralAngle(obj,val,units)
            obj.dihedralAngle.setValue(val,units)
        end
        function setSpanUnitVec(obj,val,units)
            obj.spanUnitVec.setValue(val,units)
        end
        function setSpan(obj,val,units)
            obj.span.setValue(val,units)
        end
        function setChordUnitVec(obj,val,units)
            obj.chordUnitVec.setValue(val,units)
        end
        function setCornerPoint(obj,val,units)
            obj.cornerPoint.setValue(val,units)
        end
        function setChord(obj,val,units)
            obj.chord.setValue(val,units)
        end
        function setRefArea(obj,val,units)
            obj.refArea.setValue(val,units)
        end
        function setAeroCentPosVec(obj,val,units)
            obj.aeroCentPosVec.setValue(val,units)
        end
        function setCL(obj,val,units)
            obj.CL.setValue(val,units)
        end
        function setCD(obj,val,units)
            obj.incidenceAngle.setValue(val,units)
        end
        function setAlpha(obj,val,units)
            obj.alpha.setValue(val,units)
        end
        function setGainCL(obj,val,units)
            obj.GainCL.setValue(val,units)
        end
        function setGainCD(obj,val,units)
            obj.GainCD.setValue(val,units)
        end
        function setMaxCtrlDeflDn(obj,val,units)
            obj.MaxCtrlDeflDn.setValue(val,units)
        end
        function setMaxCtrlDeflUp(obj,val,units)
            obj.MaxCtrlDeflUp.setValue(val,units)
        end
        
        %% Getters
        
        function paramVal = get.cornerPoints(obj)
            val = zeros(3,4);
            val(:,1) = obj.cornerPoint.Value(:);
            val(:,2) = val(:,1) + obj.spanUnitVec.Value(:)*obj.span.Value; % Pick point straight out
            val(1,2) = val(1,2) + obj.span.Value*tand(obj.sweepAngle.Value); % Shift back by sweep amount
            val(3,2) = val(3,2) + obj.span.Value*tand(obj.dihedralAngle.Value); % Shift up by dihedral angle
            val(:,3) = val(:,2) + obj.tipChord.Value(:)*rotation_sequence([0 obj.incidenceAngle.Value 0]*pi/180)*obj.chordUnitVec.Value(:);
            val(:,4) = val(:,1) + obj.rootChord.Value(:)*rotation_sequence([0 obj.incidenceAngle.Value 0]*pi/180)*obj.chordUnitVec.Value(:);
            
            paramVal = SIM.parameter('Value',val,'Unit','m');
            
        end
        
        function paramVal = get.aeroCentPosVec(obj)
            val = obj.cornerPoints.Value;
            center = mean(val,2);
            halfLeadingEdge = mean(val(:,1:2),2);
            obj.aeroCentPosVec.setValue((center+halfLeadingEdge)/2,'m');
            paramVal = obj.aeroCentPosVec;
        end
        
        %% Function to scale the object down
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(factor);
            end
        end
        
        function h = plot(obj,varargin)

            
            p = inputParser;
            addParameter(p,'FigHandle',[],@(x) isa(x,'matlab.ui.Figure'));
            addParameter(p,'EulerAngles',[0 0 0],@isnumeric);
            addParameter(p,'Position',[0 0 0],@isnumeric);
            parse(p,varargin{:})

            if isempty(p.Results.FigHandle)
                h.fig = figure('Position',[ 1          41        1920         963],...
                        'Units','pixels');
            else
                h.fig = p.Results.FigHandle;
            end
            
            
            points = obj.cornerPoints.Value;
            points(:,end+1) = points(:,1);
            
            points = rotation_sequence(p.Results.EulerAngles)*points;
            points = points + repmat(p.Results.Position(:),[1 5]);
            
            h.surface = fill3(points(1,:),points(2,:),points(3,:),0.75*[1 1 1],'LineStyle','-');
            set(gca,'NextPlot','add');
            aeroCentPos = rotation_sequence(p.Results.EulerAngles)*obj.aeroCentPosVec.Value(:);
            aeroCentPos = aeroCentPos + p.Results.Position(:);
            h.aeroCenter = scatter3(aeroCentPos(1),aeroCentPos(2),aeroCentPos(3),...
                'CData',[0.9 0 0],'MarkerFaceColor','r','Marker','*','SizeData',72,...
                'LineWidth',1.5);
        end
    end
    
    
end

