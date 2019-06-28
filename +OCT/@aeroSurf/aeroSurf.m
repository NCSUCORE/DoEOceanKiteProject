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
        aspectRatio
        cornerPoint
        aeroRefPoint
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
        numChordwise
        numSpanwise
        airfoil
        ClMin
        ClMax
    end
    
    methods
        function obj = aeroSurf
            obj.rootChord       = SIM.parameter('Unit','m','Description','Root chord of aerodynamic surface');
            obj.tipChord        = SIM.parameter('Unit','m','Description','Tip chord of aerodynamic surface');
            obj.meanChord       = SIM.parameter('Unit','m','Description','Mean of root and tip chords');
            obj.taperRatio      = SIM.parameter('Unit','');
            obj.incidenceAngle  = SIM.parameter('Unit','deg');
            obj.sweepAngle      = SIM.parameter('Unit','deg');
            obj.dihedralAngle   = SIM.parameter('Unit','deg');
            obj.spanUnitVec     = SIM.parameter('Unit','');
            obj.span            = SIM.parameter('Unit','m');
            obj.chordUnitVec    = SIM.parameter('Unit','');
            obj.aspectRatio     = SIM.parameter('Unit','');
            obj.cornerPoint     = SIM.parameter('Unit','m');
            obj.aeroRefPoint    = SIM.parameter('Unit','m');
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
            obj.numChordwise    = SIM.parameter('Value',20,'Unit','','NoScale',true);
            obj.numSpanwise     = SIM.parameter('Value',5,'Unit','','NoScale',true);
            obj.ClMin           = SIM.parameter('Unit','','NoScale',true);
            obj.ClMax           = SIM.parameter('Unit','','NoScale',true);
            
            obj.airfoil = '';
            
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
        function setCornerPoint(obj,val,units)
            obj.cornerPoint.setValue(val,units)
        end
        function setAeroRefPoint(obj,val,units)
            obj.aeroRefPoint.setValue(val,units)
        end
        function setChordUnitVec(obj,val,units)
            obj.chordUnitVec.setValue(val,units)
        end
        function setAspectRatio(obj,val,units)
            obj.aspectRatio.setValue(val,units);
            obj.tipChord.setValue(obj.rootChord.value/val,'m');
            obj.meanChord.setValue((obj.tipChord.Value+obj.rootChord.Value)/2,'m');
            obj.taperRatio.setValue(obj.tipChord.Value/obj.rootChord.Value,'');
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
            obj.CD.setValue(val,units)
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
        function setClMin(obj,val,units)
            obj.ClMin.setValue(val,units)
        end
        function setClMax(obj,val,units)
            obj.ClMax.setValue(val,units)
        end
        function setAirfoil(obj,val)
            string = regexp(val,'\d{4}');
            if isempty(string) || string~=1
                error('String must be 4 digit NACA airfoil code')
            end
            obj.airfoil = val;
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
        
        function val = get.refArea(obj)
            corners = obj.cornerPoints.Value;
            % calculate the area via cross product
            area1 = 0.5*norm(cross(corners(:,2)-corners(:,1),corners(:,4)-corners(:,1)));
            area2 = 0.5*norm(cross(corners(:,2)-corners(:,3),corners(:,4)-corners(:,3)));
            val = SIM.parameter('Value',area1+area2,'Unit','m^2');
        end
        
        function paramVal = get.aeroCentPosVec(obj)
            val = obj.cornerPoints.Value;
            center = mean(val,2);
            halfLeadingEdge = mean(val(:,1:2),2);
            obj.aeroCentPosVec.setValue((center+halfLeadingEdge)/2,'m');
            paramVal = obj.aeroCentPosVec;
        end
        
        function paramVal = get.aspectRatio(obj)
            paramVal = SIM.parameter('Value',obj.span.Value/obj.meanChord.Value,'Unit','');
        end
        
        %% Function to scale the object down
        function obj = scale(obj,factor)
            props = properties(obj);
            for ii = 1:numel(props)
                if ismethod(obj.(props{ii}),'scale')
                    obj.(props{ii}).scale(factor);
                end
            end
        end
        
        %% Function to plot things
        function h = plotGeometry(obj,varargin)
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
        
        %% Method to run AVL on this surface
        function AVL(obj,varargin)
            p = inputParser;
            addParameter(p,'alpha',obj.alpha.Value,@isnumeric);
            addParameter(p,'Parallel',true,@islogical);
            parse(p,varargin{:})
            obj.alpha.setValue(p.Results.alpha,'deg');
            origPath = pwd;
            addpath(origPath);
            cd(fileparts(which('avl.exe')));
            
            [liftCoeffs,dragCoeffs,lifCtrlSurfGain,dragCtrlSurfGain] = avlPartitioned(obj);
            
            obj.setCL(liftCoeffs,'');
            obj.setCD(dragCoeffs,'');
            obj.setGainCL(lifCtrlSurfGain,'1/deg');
            obj.setGainCD(dragCtrlSurfGain,'1/deg');
            cd(origPath);
            rmpath(origPath);
        end
        
        
        %% Function to plot polars for this surface
        function plotPolars(obj)
            figure('Position',[ 1          41        1920         963],...
                'Units','pixels');
            subplot(2,3,1)
            plot(obj.alpha.Value,obj.CL.Value,'LineWidth',1.5,'Color','k',...
                'LineStyle','-')
            grid on
            xlabel('$\alpha$')
            ylabel('$C_L$')
            
            subplot(2,3,2)
            plot(obj.alpha.Value,obj.CD.Value,'LineWidth',1.5,'Color','k',...
                'LineStyle','-')
            grid on
            xlabel('$\alpha$')
            ylabel('$C_D$')
            
            subplot(2,3,3)
            plot(obj.alpha.Value,obj.CL.Value./obj.CD.Value,'LineWidth',1.5,'Color','k',...
                'LineStyle','-')
            grid on
            xlabel('$\alpha$')
            ylabel('$C_L/C_D$')
            
            subplot(2,3,4)
            plot(obj.alpha.Value,polyval(obj.GainCL.Value,obj.alpha.Value),...
                'LineWidth',1.5,'Color','k',...
                'LineStyle','-')
            grid on
            xlabel('$\delta_{ctrl surf}$')
            ylabel('$C_L$')
            
            subplot(2,3,5)
            plot(obj.alpha.Value,polyval(obj.GainCD.Value,obj.alpha.Value),...
                'LineWidth',1.5,'Color','k',...
                'LineStyle','-')
            grid on
            xlabel('$\delta_{ctrl surf}$')
            ylabel('$C_D$')
            
            set(findall(gcf,'Type','axes'),'FontSize',16)
        end
    end
    
    
end

