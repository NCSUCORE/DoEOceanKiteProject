classdef aeroSurf < handle
    %AEROSURF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        rSurfLE_WingLEBdy
        rootChord
        span
        AR
        TR
        sweep
        dihedral
        incidence
        NACA
        ClMin
        ClMax
        maxCtrlDef
        minCtrlDef
        maxCtrlDefSpeed
        spanUnitVec
        chordUnitVec
        incAlphaUnitVecSurf
        numTraps
        
        CL
        CD
        alpha
        gainCL
        gainCD
    end
    properties (Dependent)
        RSurf2Bdy
        rAeroCent_SurfLE
        outlinePts
    end
    
    methods
        function obj = aeroSurf
            obj.rSurfLE_WingLEBdy   = SIM.parameter('Unit','m','Description','Vector in the body frame from the wing LE (body frame) to the leading-edge, inside corner of the surface');
            obj.rootChord           = SIM.parameter('Unit','m','Description','Root chord');
            obj.span                = SIM.parameter('Unit','m','Description','Surface span, not full wingspan');
            obj.AR                  = SIM.parameter('Description','Aspect ratio','NoScale',true);
            obj.TR                  = SIM.parameter('Value',1,'Description','Taper ratio','NoScale',true);
            obj.sweep               = SIM.parameter('Value',0,'Unit','deg','Description','Sweep angle');
            obj.dihedral            = SIM.parameter('Value',0,'Unit','deg','Description','Dihedral angle');
            obj.incidence           = SIM.parameter('Value',0,'Unit','deg','Description','Flow incidence angle');
            obj.NACA                = SIM.parameter('Description','Wing NACA airfoil','NoScale',true);
            obj.ClMin               = SIM.parameter('Description','Minimum section lift coef','NoScale',true);
            obj.ClMax               = SIM.parameter('Description','Maximum section lift coef','NoScale',true);
            obj.spanUnitVec         = SIM.parameter('Description','Body frame unit vector for the span before dihedral/incidence');
            obj.chordUnitVec        = SIM.parameter('Description','Body frame unit vector for the chord before dihedral/incidence');
            obj.incAlphaUnitVecSurf = SIM.parameter('Description','Unit vector in the surface frame about which the apparent velocity vector is rotated to obtain an increasing alpha');
            obj.maxCtrlDef          = SIM.parameter('Unit','deg');
            obj.minCtrlDef          = SIM.parameter('Unit','deg');
            obj.maxCtrlDefSpeed     = SIM.parameter('Unit','deg/s');
            obj.numTraps            = SIM.parameter('Value',1,'Description','1 for one trapazoid, 2 for 2 trapazoids symmetric about root chord');
                        
            %AVL Params
            obj.CL                = SIM.parameter('NoScale',true);
            obj.CD                = SIM.parameter('NoScale',true);
            obj.alpha             = SIM.parameter('Unit','deg');
            obj.gainCL            = SIM.parameter('Unit','1/deg');
            obj.gainCD            = SIM.parameter('Unit','1/deg');
        end
        
        %% Setters
        function setRSurfLE_WingLEBdy(obj,val,units)
            obj.rSurfLE_WingLEBdy.setValue(val,units)
        end
        
        function setRootChord(obj,val,units)
            obj.rootChord.setValue(val,units)
        end

        function setSpanOrAR(obj,spanOrAR,val,units)
            if strcmpi(spanOrAR,"AR")
                obj.AR.setValue(val,units);
                obj.span.setValue(obj.AR.Value * obj.rootChord.Value,'m');
            elseif strcmpi(spanOrAR,"span")
                obj.span.setValue(val,units);
                obj.AR.setValue(obj.span.Value / obj.rootChord.Value,'')
            else
                error("parameter spanOrAR must contain either 'span' or 'AR'")
            end
        end

        function setTR(obj,val,units)
            obj.TR.setValue(val,units)
        end

        function setSweep(obj,val,units)
            obj.sweep.setValue(val,units)
        end

        function setDihedral(obj,val,units)
            obj.dihedral.setValue(val,units)
        end

        function setIncidence(obj,val,units)
            obj.incidence.setValue(val,units)
        end

        function setNACA(obj,val,units)
            obj.NACA.setValue(val,units)
        end
        
        function setClMin(obj,val,units)
            obj.ClMin.setValue(val,units)
        end

        function setClMax(obj,val,units)
            obj.ClMax.setValue(val,units)
        end

        function setMaxCtrlDef(obj,val,units)
            obj.maxCtrlDef.setValue(val,units)
        end

        function setMinCtrlDef(obj,val,units)
            obj.minCtrlDef.setValue(val,units)
        end

        function setMaxCtrlDefSpeed(obj,val,units)
            obj.maxCtrlDefSpeed.setValue(val,units)
        end

        function setRefArea(obj,val,units)
            obj.refArea.setValue(val,units)
        end

        function setSpanUnitVec(obj,val,units)
            obj.spanUnitVec.setValue(val,units)
        end

        function setChordUnitVec(obj,val,units)
            obj.chordUnitVec.setValue(val,units)
        end
        
        function setIncAlphaUnitVecSurf(obj,val,units)
            obj.incAlphaUnitVecSurf.setValue(val,units)
        end

        function setNumTraps(obj,val,units)
            obj.numTraps.setValue(val,units)
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
            obj.gainCL.setValue(val,units)
        end

        function setGainCD(obj,val,units)
            obj.gainCD.setValue(val,units)
        end

        %% Getters
        function val = get.RSurf2Bdy(obj)
            value = [obj.chordUnitVec.Value(:)...
                     obj.spanUnitVec.Value(:)...
                     cross(obj.chordUnitVec.Value(:)',obj.spanUnitVec.Value(:))'];
            val = SIM.parameter('Value',value,'Description','rotation matrix from the surface coordinates to the body coordinates');
        end
        
        function val = get.rAeroCent_SurfLE(obj)
            if obj.numTraps.Value == 1
                tr=obj.TR.Value;
                MACLength = (2/3)*obj.rootChord.Value*((1+tr+tr^2)/(1+tr));
                yac = (obj.span.Value / 3) * ((1 + 2*tr)/(1+tr));
                xac = (yac * tand(obj.sweep.Value)) + (MACLength*.25);
                zac = yac * sind(obj.dihedral.Value);
                val = SIM.parameter('Value',[xac;yac;zac],'unit','m','Description','vector from the surface origin (leading-edge, inside corner) to the areodynamic center in surface coordinates');
            elseif obj.numTraps.Value == 2
                tr=obj.TR.Value;
                MACLength = (2/3)*obj.rootChord.Value*((1+tr+tr^2)/(1+tr));
                yacSide = (obj.span.Value / 3) * ((1 + 2*tr)/(1+tr));
                xac = (yacSide * tand(obj.sweep.Value)) + (MACLength*.25);
                yac = 0;%From symmetry
                zac = yacSide * sind(obj.dihedral.Value);
                val = SIM.parameter('Value',[xac;yac;zac],'unit','m','Description','vector from the surface origin (leading-edge, inside corner) to the areodynamic center in surface coordinates');
            else
                warning("numTraps must be 1 or 2")
            end
        end
        
        function val = get.outlinePts(obj)
            %Returns the points of points in the body frame, relative to
            %the Wing leading edge. The points go clockwise looking down
            %from the surface positive z axis.
            %For 2 symmetric trapazoids, it starts in the center LE
            lsweep=obj.sweep.Value;
            lspan=obj.span.Value;
            lTR=obj.TR.Value;
            lrc=obj.rootChord.Value;
            ldihedral=obj.dihedral.Value;
            if obj.numTraps.Value == 1
                val=zeros(3,5);
                val(:,2)=[tand(lsweep)*lspan;...
                          lspan;
                          sind(ldihedral)*lspan];
                val(:,3)=[tand(lsweep)*lspan + lTR*lrc;...
                         lspan;
                         sind(ldihedral)*lspan];
                val(:,4)=[lrc;...
                          0;
                          0];
            elseif obj.numTraps.Value == 2
                lhalfspan = lspan / 2;
                val=zeros(3,7);
                val(:,2)=[tand(lsweep)*lhalfspan;...
                          lhalfspan;
                          sind(ldihedral)*lhalfspan];
                val(:,3)=[tand(lsweep)*lhalfspan + lTR*lrc;...
                         lhalfspan;
                         sind(ldihedral)*lhalfspan];
                val(:,4)=[lrc;...
                          0;
                          0];
                val(:,5)=[val(1,3);-val(2,3);val(3,3)];
                val(:,6)=[val(1,2);-val(2,2);val(3,2)];
            else
                warning("numTraps must be 1 or 2")
            end
            val=SIM.parameter('Value',obj.rSurfLE_WingLEBdy.Value + val);
        end
        %% Other Methods
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = properties(obj);
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

