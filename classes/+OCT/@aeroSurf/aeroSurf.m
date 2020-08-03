classdef aeroSurf < handle
    %AEROSURF Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        rSurfLE_WingLEBdy
        rootChord
        halfSpan
        TR
        sweep
        dihedral
        incidence
        Airfoil
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
        AR
        planformArea
        RSurf2Bdy
        rAeroCent_SurfLE
        rTipLE
        outlinePtsBdy
        MACLength
    end
    
    methods
        function obj = aeroSurf
            obj.rSurfLE_WingLEBdy   = SIM.parameter('Unit','m','Description','Vector in the body frame from the wing LE (body frame) to the leading-edge, inside corner of the surface');
            obj.rootChord           = SIM.parameter('Unit','m','Description','Root chord');
            obj.halfSpan            = SIM.parameter('Unit','m','Description','Distance between the root chord and tip chord (not full wingspan for 2 traps)');
            obj.TR                  = SIM.parameter('Description','Taper ratio','NoScale',true);
            obj.sweep               = SIM.parameter('Value',0,'Unit','deg','Description','Sweep angle');
            obj.dihedral            = SIM.parameter('Value',0,'Unit','deg','Description','Dihedral angle');
            obj.incidence           = SIM.parameter('Value',0,'Unit','deg','Description','Flow incidence angle');
            obj.Airfoil                = SIM.parameter('Description','airfoil','NoScale',true);
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

        function setHalfSpan(obj,val,units)
            obj.halfSpan.setValue(val,units);
        end
        
        function setHalfSpanGivenAR(obj,AR,~)
            %For 1 Trap, give AR using half Span
            %For 2 Traps, give AR using full Span
            if isempty(obj.TR.Value) || isempty(obj.rootChord.Value)
                warning('Taper Ratio and root chord must be set before defining Span given an Aspect Ratio.')
            end
            %span = AR * meanChord = AR * .5*(rootChord + tipChord)
            if obj.numTraps.Value == 1
                obj.halfSpan.setValue(AR*.5*(obj.rootChord.Value + obj.TR.Value*obj.rootChord.Value),'m');
            elseif obj.numTraps.Value == 2
                obj.halfSpan.setValue(.5* AR*.5*(obj.rootChord.Value + obj.TR.Value*obj.rootChord.Value),'m');
            else
                error("numTraps must be 1 or 2")
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

        function setAirfoil(obj,val,units)
            obj.Airfoil.setValue(val,units)
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
        function val = get.AR(obj)
            if obj.numTraps.Value == 1
                aspect = obj.halfSpan.Value^2 / obj.planformArea.Value;
            elseif obj.numTraps.Value == 2
                aspect = (2*obj.halfSpan.Value)^2 / obj.planformArea.Value;
            else
                error("numTraps must be 1 or 2")
            end
            val = SIM.parameter('Value',aspect,'Description','halfSpan^2/Area for 1 Trap and fullSpan^2/Area for 2 Traps');
        end
        
        function val = get.planformArea(obj)
            if obj.numTraps.Value == 1
                area = obj.halfSpan.Value * .5 * (obj.rootChord.Value + obj.TR.Value*obj.rootChord.Value);
            elseif obj.numTraps.Value == 2
                area = 2 * obj.halfSpan.Value * .5 * (obj.rootChord.Value + obj.TR.Value*obj.rootChord.Value);
            else
                error("numTraps must be 1 or 2")
            end
            val = SIM.parameter('Value',area,'Description','Planform area of entire surface 1 or 2 traps');
        end
        
        function val = get.RSurf2Bdy(obj)
            value = [obj.chordUnitVec.Value(:)...
                     obj.spanUnitVec.Value(:)...
                     cross(obj.chordUnitVec.Value(:)',obj.spanUnitVec.Value(:))'];
            val = SIM.parameter('Value',value,'Description','rotation matrix from the surface coordinates to the body coordinates');
        end
        
        function val = get.MACLength(obj)
            tr=obj.TR.Value;
            MAC = (2/3)*obj.rootChord.Value*((1+tr+tr^2)/(1+tr));
            val = SIM.parameter('Unit','m','Value',MAC,'Description','length of the Mean Aerodynamic Chord');
        end
        
        function val = get.rAeroCent_SurfLE(obj) %CHECK SPAN FOR 2 TRAPS
            if obj.numTraps.Value == 1
                tr=obj.TR.Value;
                yac = (obj.halfSpan.Value / 3) * ((1 + 2*tr)/(1+tr));
                xac = (yac * tand(obj.sweep.Value)) + (obj.MACLength.Value*.25);
                zac = yac * sind(obj.dihedral.Value);
                val = SIM.parameter('Value',[xac;yac;zac],'unit','m','Description','vector from the surface origin (leading-edge, inside corner) to the areodynamic center in surface coordinates');
            elseif obj.numTraps.Value == 2
                tr=obj.TR.Value;
                yacSide = (obj.halfSpan.Value / 3) * ((1 + 2*tr)/(1+tr));
                xac = (yacSide * tand(obj.sweep.Value)) + (obj.MACLength.Value*.25);
                yac = 0;%From symmetry
                zac = yacSide * sind(obj.dihedral.Value);
                val = SIM.parameter('Value',[xac;yac;zac],'unit','m','Description','vector from the surface origin (leading-edge, inside corner) to the areodynamic center in surface coordinates');
            else
                error("numTraps must be 1 or 2")
            end
        end
        
        function val = get.rTipLE(obj) %CHECK SPAN FOR 2 TRAPS
            if obj.numTraps.Value == 1
                yac = obj.halfSpan.Value;
                xac = .25*obj.outlinePtsBdy.Value(1,3)+.75*obj.outlinePtsBdy.Value(1,2)-obj.outlinePtsBdy.Value(1,1);
                zac = yac * sind(obj.dihedral.Value);
                val = SIM.parameter('Value',[xac;yac;zac],'unit','m','Description','vector from the surface origin (leading-edge, inside corner) to the tip areodynamic center in surface coordinates');
            elseif obj.numTraps.Value == 2
                yacSide = (obj.halfSpan.Value);
                xac = .25*obj.outlinePtsBdy.Value(1,3)+.75*obj.outlinePtsBdy.Value(1,2)-obj.outlinePtsBdy.Value(1,1);
                yac = 0;%From symmetry
                zac = yacSide * sind(obj.dihedral.Value);
                val = SIM.parameter('Value',[xac;yac;zac],'unit','m','Description','vector from the surface origin (leading-edge, inside corner) to the tip areodynamic center in surface coordinates');
            else
                error("numTraps must be 1 or 2")
            end
        end
        
        function val = get.outlinePtsBdy(obj) %CHECK SPAN FOR 2 TRAPS
            %Returns the points of points in the body frame, relative to
            %the Wing leading edge. The points go clockwise looking down
            %from the surface positive z axis.
            %For 2 symmetric trapazoids, it starts in the center LE
            tempSweep=obj.sweep.Value;
            tempHalfSpan=obj.halfSpan.Value;
            tempTR=obj.TR.Value;
            tempRC=obj.rootChord.Value;
            tempDihedral=obj.dihedral.Value;
            if obj.numTraps.Value == 1
                val=zeros(3,5);
                val(:,2)=[tand(tempSweep)*tempHalfSpan;...
                          tempHalfSpan;
                          sind(tempDihedral)*tempHalfSpan];
                val(:,3)=[tand(tempSweep)*tempHalfSpan + tempTR*tempRC;...
                         tempHalfSpan;
                         sind(tempDihedral)*tempHalfSpan];
                val(:,4)=[tempRC;...
                          0;
                          0];
            elseif obj.numTraps.Value == 2
                val=zeros(3,7);
                val(:,2)=[tand(tempSweep)*tempHalfSpan;...
                          tempHalfSpan;
                          sind(tempDihedral)*tempHalfSpan];
                val(:,3)=[tand(tempSweep)*tempHalfSpan + tempTR*tempRC;...
                         tempHalfSpan;
                         sind(tempDihedral)*tempHalfSpan];
                val(:,4)=[tempRC;...
                          0;
                          0];
                val(:,5)=[val(1,3);-val(2,3);val(3,3)];
                val(:,6)=[val(1,2);-val(2,2);val(3,2)];
            else
                error("numTraps must be 1 or 2")
            end
            val=SIM.parameter('Value',obj.rSurfLE_WingLEBdy.Value + obj.RSurf2Bdy.Value*val);
        end
        %% Other Methods
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','private');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
    end
end

