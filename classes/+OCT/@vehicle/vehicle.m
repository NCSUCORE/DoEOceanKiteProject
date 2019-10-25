classdef vehicle < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        fluidDensity
        numTethers
        numTurbines
        buoyFactor
        
        Ixx
        Iyy
        Izz
        Ixy
        Ixz
        Iyz
        addedMISwitch
        % center of buoyancy
        centOfBuoy
        % bridle location
        Rbridle_cm
        % aero properties
        % data file name
        fluidCoeffsFileName
        % wing
        RwingLE_cm
        wingChord
        wingAR
        wingTR
        wingSweep
        wingDihedral
        wingIncidence
        wingNACA
        wingClMax
        wingClMin
        % H-stab
        RhsLE_wingLE
        hsChord
        hsAR
        hsTR
        hsSweep
        hsDihedral
        hsIncidence
        hsNACA
        hsClMax
        hsClMin
        % V-stab
        Rvs_wingLE
        vsChord
        vsSpan
        vsTR
        vsSweep
        vsNACA
        vsClMax
        vsClMin
        % aerodynamimc surfaces
        portWing
        stbdWing
        hStab
        vStab
        % fuselage
        fuseDiameter
        fuseRCmToNose
        fuseSideDragCoeff
        fuseEndDragCoeff
        % intial conditions
        initPosVecGnd
        initVelVecBdy
        initEulAng
        initAngVelVec
    end
    
    properties (Dependent)
        volume
        mass
        inertia
        addedMass
        addedInertia
        surfaceOutlines
        thrAttchPts
        turbines
        fuse
        fluidMomentArms
        fluidRefArea
    end
    
    methods
        %% Constructor
        function obj = vehicle
            %VEHICLE Construct an instance of this class
            obj.fluidDensity = SIM.parameter('Unit','kg/m^3','Description','Fluid density');
            obj.numTethers  = SIM.parameter('Description','Number of tethers','NoScale',true);
            obj.numTurbines = SIM.parameter('Description','Number of turbines','NoScale',true);
            obj.buoyFactor = SIM.parameter('Description','Buoyancy Factor','NoScale',true);
            % mass, volume and inertia
%             obj.volume         = SIM.parameter('Unit','m^3','Description','volume');
            obj.Ixx            = SIM.parameter('Unit','kg*m^2','Description','Ixx');
            obj.Iyy            = SIM.parameter('Unit','kg*m^2','Description','Iyy');
            obj.Izz            = SIM.parameter('Unit','kg*m^2','Description','Izz');
            obj.Ixy            = SIM.parameter('Unit','kg*m^2','Description','Ixy');
            obj.Ixz            = SIM.parameter('Unit','kg*m^2','Description','Ixz');
            obj.Iyz            = SIM.parameter('Unit','kg*m^2','Description','Iyz');
            obj.addedMISwitch  = SIM.parameter('Value',1,'Unit','','Description','False turns off added mass and inertia');
            % some vectors
            obj.Rbridle_cm    = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from CM to bridle point');
            obj.centOfBuoy        = SIM.parameter('Unit','m','Description','Vector going from CM to center of buoyancy');
            % fluid coeffs file name
            obj.fluidCoeffsFileName = SIM.parameter('Description','File that contains fluid dynamics coefficient data','NoScale',true);
            % defining aerodynamic surfaces
            obj.RwingLE_cm    = SIM.parameter('Unit','m','Description','Vector going from CM to wing leading edge');
            obj.wingChord     = SIM.parameter('Unit','m','Description','Wing root chord');
            obj.wingAR        = SIM.parameter('Description','Wing Aspect ratio','NoScale',true);
            obj.wingTR        = SIM.parameter('Description','Wing Taper ratio','NoScale',true);
            obj.wingSweep     = SIM.parameter('Unit','deg','Description','Wing sweep angle');
            obj.wingDihedral  = SIM.parameter('Unit','deg','Description','Wing dihedral angle');
            obj.wingIncidence = SIM.parameter('Unit','deg','Description','Wing flow incidence angle');
            obj.wingNACA      = SIM.parameter('Description','Wing NACA airfoil','NoScale',true);
            obj.wingClMax     = SIM.parameter('Description','Wing airfoil maximum lift coefficient','NoScale',true);
            obj.wingClMin     = SIM.parameter('Description','Wing airfoil minimum lift coefficient','NoScale',true);
            % H-stab
            obj.RhsLE_wingLE  = SIM.parameter('Unit','m','Description','Vector going from wing leading edge to H-stab leading edge');
            obj.hsChord     = SIM.parameter('Unit','m','Description','H-stab root chord');
            obj.hsAR        = SIM.parameter('Description','H-stab Aspect ratio','NoScale',true);
            obj.hsTR        = SIM.parameter('Description','H-stab Taper ratio','NoScale',true);
            obj.hsSweep     = SIM.parameter('Unit','deg','Description','H-stab sweep angle');
            obj.hsDihedral  = SIM.parameter('Unit','deg','Description','H-stab dihedral angle');
            obj.hsIncidence = SIM.parameter('Unit','deg','Description','H-stab flow incidence angle');
            obj.hsNACA      = SIM.parameter('Description','H-stab NACA airfoil','NoScale',true);
            obj.hsClMax     = SIM.parameter('Description','H-stab airfoil maximum lift coefficient','NoScale',true);
            obj.hsClMin     = SIM.parameter('Description','H-stab airfoil minimum lift coefficient','NoScale',true);
            % V-stab
            obj.Rvs_wingLE    = SIM.parameter('Unit','m','Description','Vector going from wing leading edge to V-stab leading edge');
            obj.vsChord     = SIM.parameter('Unit','m','Description','V-stab root chord');
            obj.vsSpan      = SIM.parameter('Unit','m','Description','V-stab span');
            obj.vsTR        = SIM.parameter('Description','V-stab Taper ratio','NoScale',true);
            obj.vsSweep     = SIM.parameter('Unit','deg','Description','V-stab sweep angle');
            obj.vsNACA      = SIM.parameter('Description','V-stab NACA airfoil','NoScale',true);
            obj.vsClMax     = SIM.parameter('Description','V-stab airfoil maximum lift coefficient','NoScale',true);
            obj.vsClMin     = SIM.parameter('Description','V-stab airfoil minimum lift coefficient','NoScale',true);
            % aerodynamic surfaces
            obj.portWing = OCT.aeroSurf;
            obj.portWing.spanUnitVec.setValue([0;1;0],'','NoScale',true);
            obj.portWing.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            
            obj.stbdWing = OCT.aeroSurf;
            obj.stbdWing.spanUnitVec.setValue([0;1;0],'','NoScale',true);
            obj.stbdWing.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            
            obj.hStab = OCT.aeroSurf;
            obj.hStab.spanUnitVec.setValue([0;1;0],'','NoScale',true);
            obj.hStab.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            
            obj.vStab = OCT.aeroSurf;
            obj.vStab.spanUnitVec.setValue([0;0;1],'','NoScale',true);
            obj.vStab.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            
            obj.fuseDiameter             = SIM.parameter('Unit','m');
            obj.fuseRCmToNose            = SIM.parameter('Unit','m','Description','Vector from the kite CM to the front of the fuselage');
            obj.fuseSideDragCoeff        = SIM.parameter('Description','Drag Coeff if at 90 degrees angle of attack','NoScale',true);
            obj.fuseEndDragCoeff         = SIM.parameter('Description','Drag Coeff if at 0 degrees angle of attack','NoScale',true);
            
            % initial conditions
            obj.initPosVecGnd           = SIM.parameter('Unit','m','Description','Initial CM position represented in the inertial frame');
            obj.initVelVecBdy           = SIM.parameter('Unit','m/s','Description','Initial CM velocity represented in the body frame ');
            obj.initEulAng              = SIM.parameter('Unit','rad','Description','Initial Euler angles');
            obj.initAngVelVec           = SIM.parameter('Unit','rad/s','Description','Initial angular velocity vector');
        end
        
        %% setters
        function setFluidDensity(obj,val,units)
            obj.fluidDensity.setValue(val,units)
        end
        
        function setNumTethers(obj,val,units)
            obj.numTethers.setValue(val,units);
        end
        
        function setNumTurbines(obj,val,units)
            obj.numTurbines.setValue(val,units);
        end
        
        function setBuoyFactor(obj,val,units)
            obj.buoyFactor.setValue(val,units);
        end
        
%         function setVolume(obj,val,units)
%             obj.volume.setValue(val,units);
%         end
        
        function setIxx(obj,val,units)
            obj.Ixx.setValue(val,units);
        end
        
        function setIyy(obj,val,units)
            obj.Iyy.setValue(val,units);
        end
        
        function setIzz(obj,val,units)
            obj.Izz.setValue(val,units);
        end
        
        function setIxy(obj,val,units)
            obj.Ixy.setValue(val,units);
        end
        
        function setIxz(obj,val,units)
            obj.Ixz.setValue(val,units);
        end
        
        function setIyz(obj,val,units)
            obj.Iyz.setValue(val,units);
        end
        
        function setAddedMISwitch(obj,val,units)
            obj.addedMISwitch.setValue(val,units);
        end
        
        function setCentOfBuoy(obj,val,units)
            obj.centOfBuoy.setValue(reshape(val,3,1),units);
        end
        
        function setRbridle_cm(obj,val,units)
            obj.Rbridle_cm.setValue(val,units);
        end
        
        function setFluidCoeffsFileName(obj,val,units)
            if ~endsWith(val,'.mat')
                val = [val '.mat'] ;
            end
            obj.fluidCoeffsFileName.setValue(val,units);
        end
        
        % wing
        function setRwingLE_cm(obj,val,units)
            obj.RwingLE_cm.setValue(reshape(val,3,1),units);
        end
        
        function setWingChord(obj,val,units)
            obj.wingChord.setValue(val,units);
        end
        
        function setWingAR(obj,val,units)
            obj.wingAR.setValue(val,units);
        end
        
        function setWingTR(obj,val,units)
            obj.wingTR.setValue(val,units);
        end
        
        function setWingSweep(obj,val,units)
            obj.wingSweep.setValue(val,units);
        end
        
        function setWingDihedral(obj,val,units)
            obj.wingDihedral.setValue(val,units);
        end
        
        function setWingIncidence(obj,val,units)
            obj.wingIncidence.setValue(val,units);
        end
        
        function setWingNACA(obj,val,units)
            obj.wingNACA.setValue(val,units);
        end
        
        function setWingClMax(obj,val,units)
            obj.wingClMax.setValue(val,units);
        end
        
        function setWingClMin(obj,val,units)
            obj.wingClMin.setValue(val,units);
        end
        % H-stab
        function setRhsLE_wingLE(obj,val,units)
            obj.RhsLE_wingLE.setValue(reshape(val,3,1),units);
        end
        
        function setHsChord(obj,val,units)
            obj.hsChord.setValue(val,units);
        end
        
        function setHsAR(obj,val,units)
            obj.hsAR.setValue(val,units);
        end
        
        function setHsTR(obj,val,units)
            obj.hsTR.setValue(val,units);
        end
        
        function setHsSweep(obj,val,units)
            obj.hsSweep.setValue(val,units);
        end
        
        function setHsDihedral(obj,val,units)
            obj.hsDihedral.setValue(val,units);
        end
        
        function setHsIncidence(obj,val,units)
            obj.hsIncidence.setValue(val,units);
        end
        
        function setHsNACA(obj,val,units)
            obj.hsNACA.setValue(val,units);
        end
        
        function setHsClMaxl(obj,val,units)
            obj.hsClMax.setValue(val,units);
        end
        
        function setHsClMin(obj,val,units)
            obj.hsClMin.setValue(val,units);
        end
        
        % V-stab
        function setRvs_wingLE(obj,val,units)
            obj.Rvs_wingLE.setValue(reshape(val,3,1),units);
        end
        
        function setVsChord(obj,val,units)
            obj.vsChord.setValue(val,units);
        end
        
        function setVsSpan(obj,val,units)
            obj.vsSpan.setValue(val,units);
        end
        
        function setVsTR(obj,val,units)
            obj.vsTR.setValue(val,units);
        end
        
        function setVsSweep(obj,val,units)
            obj.vsSweep.setValue(val,units);
        end
        
        function setVsNACA(obj,val,units)
            obj.vsNACA.setValue(val,units);
        end
        
        function setVsClMax(obj,val,units)
            obj.vsClMax.setValue(val,units);
        end
        
        function setVsClMin(obj,val,units)
            obj.vsClMin.setValue(val,units);
        end
        % fuselage
        function setFuseDiameter(obj,val,units)
            obj.fuseDiameter.setValue(val,units);
        end
        
        function setFuseRCmToNose(obj,val,units)
            obj.fuseRCmToNose.setValue(val,units);
        end
        
        function setFuseSideDragCoeff(obj,val,units)
            obj.fuseSideDragCoeff.setValue(val,units);
        end
        
        function setFuseEndDragCoeff(obj,val,units)
            obj.fuseEndDragCoeff.setValue(val,units);
        end
        
        % initial conditions
        function setInitPosVecGnd(obj,val,units)
            obj.initPosVecGnd.setValue(val(:),units);
        end
        
        function setInitVelVecBdy(obj,val,units)
            obj.initVelVecBdy.setValue(val(:),units);
        end
        
        function setInitEulAng(obj,val,units)
            obj.initEulAng.setValue(val(:),units);
        end
        
        function setInitAngVelVec(obj,val,units)
            obj.initAngVelVec.setValue(val(:),units);
        end
        
        function setICsOnPath(obj,initPathPos,pathFunc,geomParams,speed)
            % Sets initial conditions of the vehicle to be on the path
            [initPos,initVel] = eval(sprintf('%s(initPathPos,geomParams)',pathFunc));
            obj.setInitPosVecGnd(initPos,'m');
            obj.setInitVelVecBdy([-speed 0 0],'m/s');
            % Initial body z points radially out
            bdyZ = initPos./sqrt(sum(initPos.^2));
            % Initial body x points backwards (opposite velocity(
            bdyX = -initVel;
            % Initial body y is calculated from the cross product of z & x
            bdyY = cross(bdyZ,bdyX);
            % Calculate euler angles from the rotation matrix
            obj.setInitEulAng(flip(rotm2eul([bdyX(:)'; bdyY(:)'; bdyZ(:)']')),'rad')
            % Initial angular velocity is zero
            obj.setInitAngVelVec([0 0 0],'rad/s');
        end
        
        %% getters
        % mass
        function val = get.mass(obj)
            
            val = SIM.parameter('Value',obj.fluidDensity.Value*obj.volume.Value/...
                obj.buoyFactor.Value,...
                'Unit','kg','Description','Vehicle mass');
        end
        % volume
        function val = get.volume(obj)
            % Read in geometry from .dat files stored in
            % +OCT/@vehicle/airfoilGeometryFiles
            basePath = fileparts(which('OCTProject.prj'));
            airfoilPath = fullfile(basePath,'classes','+OCT','@vehicle','airfoilGeometryFiles');

            wingShapeData = dlmread([airfoilPath filesep sprintf('NACA%s',obj.wingNACA.Value) '.dat'],' ',1,0);
            wingShapeData = wingShapeData(:,[1 6]); % dlm read reads in a bunch of zeros, get rid of them
            wingShapeData(end,:) = wingShapeData(1,:); % close the cross sectional profile
            
            hStabShapeData = dlmread([airfoilPath filesep sprintf('NACA%s',obj.hsNACA.Value) '.dat'],' ',1,0);
            hStabShapeData = hStabShapeData(:,[1 6]); % dlm read reads in a bunch of zeros, get rid of them
            hStabShapeData(end,:) = hStabShapeData(1,:); % close the cross sectional profile
            
            vStabShapeData = dlmread([airfoilPath filesep sprintf('NACA%s',obj.vsNACA.Value) '.dat'],' ',1,0);
            vStabShapeData = vStabShapeData(:,[1 6]); % dlm read reads in a bunch of zeros, get rid of them
            vStabShapeData(end,:) = vStabShapeData(1,:); % close the cross sectional profile
            surfOutlines = obj.surfaceOutlines;
            % All raw geometry data is scaled to 1 m chord, scale up to get
            % correct dimensions
            pWingRootChord = norm(surfOutlines.port_wing.Value(:,1)...
                -surfOutlines.port_wing.Value(:,4));
            pWingTipChord = norm(surfOutlines.port_wing.Value(:,2)...
                -surfOutlines.port_wing.Value(:,3));
            
            sWingRootChord = norm(surfOutlines.stbd_wing.Value(:,1)...
                -surfOutlines.stbd_wing.Value(:,4));
            sWingTipChord = norm(surfOutlines.stbd_wing.Value(:,2)...
                -surfOutlines.stbd_wing.Value(:,3));
            
            pHsRootChord = norm(surfOutlines.port_hs.Value(:,1)...
                -surfOutlines.port_hs.Value(:,4));
            pHsTipChord = norm(surfOutlines.port_hs.Value(:,2)...
                -surfOutlines.port_hs.Value(:,3));
            
            sHsRootChord = norm(surfOutlines.stbd_hs.Value(:,1)...
                -surfOutlines.stbd_hs.Value(:,4));
            sHsTipChord = norm(surfOutlines.stbd_hs.Value(:,2)...
                -surfOutlines.stbd_hs.Value(:,3));
            
            vsRootChord = norm(surfOutlines.top_vs.Value(:,1)...
                -surfOutlines.top_vs.Value(:,4));
            vsTipChord = norm(surfOutlines.top_vs.Value(:,2)...
                -surfOutlines.top_vs.Value(:,3));

            pWingShapeRoot  = wingShapeData*pWingRootChord;
            pWingShapeTip   = wingShapeData*pWingTipChord;
            sWingShapeRoot  = wingShapeData*sWingRootChord;
            sWingShapeTip   = wingShapeData*sWingTipChord;
            sHsShapeRoot    = hStabShapeData*sHsRootChord;
            sHsShapeTip     = hStabShapeData*sHsTipChord;
            pHsShapeRoot    = hStabShapeData*pHsRootChord;
            pHsShapeTip     = hStabShapeData*pHsTipChord;
            vsShapeRoot     = vStabShapeData*vsRootChord;
            vsShapeTip      = vStabShapeData*vsTipChord;
            
            % In general, it's really hard to get the volume defined by a
            % set of points in 3D.  (see monte carlo integration methods)
            % Instead, I'll use the following method.
            % For the wing and stabilizer, assume the airfoil profiles are
            % oriented in the x-z plane, and the vertical stabilizer
            % profiles are in the x-y plane, then the volume of each fluid
            % dynamic surface would be given by:
            % V = L*(A1 + A2)/2
            % Where L is the separation distance in y for the wing and
            % horizontal stabilizer, and in z for the vertical stabilizer,
            % and A1 and A2 are the area of the profile at the tips.
            pWingAreaRoot   = polyarea(pWingShapeRoot(:,1),pWingShapeRoot(:,2));
			pWingAreaTip    = polyarea(pWingShapeTip(:,1),pWingShapeTip(:,2));
			sWingAreaRoot   = polyarea(sWingShapeRoot(:,1),sWingShapeRoot(:,2));
			sWingAreaTip    = polyarea(sWingShapeTip(:,1),sWingShapeTip(:,2));
			sHsAreaRoot     = polyarea(sHsShapeRoot(:,1),sHsShapeRoot(:,2));
			sHsAreaTip      = polyarea(sHsShapeTip(:,1),sHsShapeTip(:,2));
			pHsAreaRoot     = polyarea(pHsShapeRoot(:,1),pHsShapeRoot(:,2));
			pHsAreaTip      = polyarea(pHsShapeTip(:,1),pHsShapeTip(:,2));
			vsAreaRoot      = polyarea(vsShapeRoot(:,1),vsShapeRoot(:,2));
			vsAreaTip       = polyarea(vsShapeTip(:,1),vsShapeTip(:,2));
            
            pWingSepDist = abs(surfOutlines.port_wing.Value(2,2)-surfOutlines.port_wing.Value(2,1));
            sWingSepDist = abs(surfOutlines.stbd_wing.Value(2,2)-surfOutlines.stbd_wing.Value(2,1));
            pHsSepDist   = abs(surfOutlines.port_hs.Value(2,2)-surfOutlines.port_hs.Value(2,1));
            sHsSepDist   = abs(surfOutlines.stbd_hs.Value(2,2)-surfOutlines.stbd_hs.Value(2,1));
            vsSepDist    = abs(surfOutlines.top_vs.Value(3,2)-surfOutlines.top_vs.Value(3,1));
            
            pWingVol = pWingSepDist*(pWingAreaRoot+pWingAreaTip)/2;
            sWingVol = sWingSepDist*(sWingAreaRoot+sWingAreaTip)/2;
            sHsVol   = sHsSepDist*(sHsAreaRoot+sHsAreaTip)/2;
            pHsVol   = pHsSepDist*(pHsAreaRoot+pHsAreaTip)/2;
            vsVol    = vsSepDist*(vsAreaRoot+vsAreaTip)/2;
            
            % Volume of fluid dynamic surfaces + volume of fuselage
            fluidSurfVol = pWingVol + sWingVol + sHsVol + pHsVol + vsVol + obj.fuse.volume.Value;
            
            val = SIM.parameter('Value',fluidSurfVol,'Unit','m^3');
            
        end
        
        % inertia
        function val = get.inertia(obj)
            val = SIM.parameter('Value',[obj.Ixx.Value -abs(obj.Ixy.Value) -abs(obj.Ixz.Value);...
                -abs(obj.Ixy.Value) obj.Iyy.Value -abs(obj.Iyz.Value);...
                -abs(obj.Ixz.Value) -abs(obj.Iyz.Value) obj.Izz.Value],'Unit','kg*m^2',....
                'Description','Moment of inertia matrix');
        end
        
        % added mass
        function val = get.addedMass(obj)
            % dummy variables
            density = obj.fluidDensity.Value;
            chord = obj.wingChord.Value;
            span = chord*obj.wingAR.Value;
            HS_chord = obj.hsChord.Value;
            HS_span = HS_chord*obj.hsAR.Value;
            VS_chord = obj.vsChord.Value;
            VS_span = obj.vsSpan.Value;
            
            % calculate
            m_added_x = pi*density*(span*(0.15*chord/2)^2 + ...
                HS_span*(0.15*HS_chord/2)^2 + VS_span*(0.15*VS_chord/2)^2);
            m_added_y = pi*density*(1.98*span*(chord/2)^2 + ...
                1.98*HS_span*(HS_chord/2)^2 + VS_span*(VS_chord/2)^2);
            m_added_z = pi*density*(span*(chord/2)^2 + ...
                HS_span*(HS_chord/2)^2 + 1.98*VS_span*(VS_chord/2)^2);
            
            % store
            if obj.addedMISwitch.Value
                val = SIM.parameter('Value',[m_added_x 0 0;0 m_added_y 0; 0 0 m_added_z],...
                    'Unit','kg','Description','Added mass of the system in the body frame');
            else
                val = SIM.parameter('Value',zeros(3),...
                    'Unit','kg','Description','Added mass of the system in the body frame');
            end
        end
        
        % added inertia
        function val = get.addedInertia(obj)
            if obj.addedMISwitch.Value
                %This is where to put added inertia when its added to the
                %model
                val = SIM.parameter('Value',zeros(3,3),...
                    'Unit','kg*m^2','Description','Added inertia of the system in the body frame');
            else
                val = SIM.parameter('Value',zeros(3,3),...
                    'Unit','kg*m^2','Description','Added inertia of the system in the body frame');
            end
        end
        
        % surface outlines
        function val = get.surfaceOutlines(obj)
            % dummy variables
            R_wle = obj.RwingLE_cm.Value;
            
            w_cr = obj.wingChord.Value;
            w_s = w_cr*obj.wingAR.Value;
            w_ct = w_cr*obj.wingTR.Value;
            w_sweep = obj.wingSweep.Value;
            w_di = obj.wingDihedral.Value;
            
            R_hsle = obj.RhsLE_wingLE.Value;
            hs_cr = obj.hsChord.Value;
            hs_s = hs_cr*obj.hsAR.Value;
            hs_ct = hs_cr*obj.hsTR.Value;
            hs_sweep = obj.hsSweep.Value;
            hs_di = obj.hsDihedral.Value;
            
            R_vsle = obj.Rvs_wingLE.Value;
            vs_cr = obj.vsChord.Value;
            vs_s = obj.vsSpan.Value;
            vs_ct = vs_cr*obj.vsTR.Value;
            vs_sweep = obj.vsSweep.Value;
            
            port_wing =  repmat(R_wle',5,1) +  [0, 0, 0;...
                w_s*tand(w_sweep)/2, -w_s/2, tand(w_di)*w_s/2;...
                (w_s*tand(w_sweep)/2)+w_ct, -w_s/2, tand(w_di)*w_s/2;...
                w_cr, 0, 0;...
                0, 0, 0];
            
            stbd_wing = port_wing.*[ones(5,1),-1*ones(5,1),ones(5,1)];
            
            port_hs = repmat(R_wle',5,1) + repmat(R_hsle',5,1) + [0, 0, 0;...
                hs_s*tand(hs_sweep)/2, -hs_s/2, tand(hs_di)*hs_s/2;...
                (hs_s*tand(hs_sweep)/2)+hs_ct,   -hs_s/2, 0;...
                hs_cr, 0, 0;...
                0, 0, 0];
            
            stbd_hs = port_hs.*[ones(5,1),-1*ones(5,1),ones(5,1)];
            
            top_vs = repmat(R_wle',5,1) + repmat(R_vsle',5,1) + [0, 0, 0;...
                vs_s*tand(vs_sweep), 0, vs_s;...
                (vs_s*tand(vs_sweep))+vs_ct, 0, vs_s;...
                vs_cr, 0, 0;...
                0, 0, 0];
            
            fuselage = [R_wle';(R_wle+R_vsle)'];
            
            val.port_wing = SIM.parameter('Value',port_wing','Unit','m',...
                'Description','Port wing surface co-ordinates');
            
            val.stbd_wing = SIM.parameter('Value',stbd_wing','Unit','m',...
                'Description','Starboard wing surface co-ordinates');
            
            val.port_hs = SIM.parameter('Value',port_hs','Unit','m',...
                'Description','Port H-stab surface co-ordinates');
            
            val.stbd_hs = SIM.parameter('Value',stbd_hs','Unit','m',...
                'Description','Starboard H-stab surface co-ordinates');
            
            val.top_vs = SIM.parameter('Value',top_vs','Unit','m',...
                'Description','V-stab surface co-ordinates');
            
            val.fuselage = SIM.parameter('Value',fuselage','Unit','m',...
                'Description','Fuselage line co-ordinates');
            
        end
        
        % Tether attachment points
        function val = get.thrAttchPts(obj)
            
            for ii = 1:obj.numTethers.Value
                val(ii,1) = OCT.thrAttch;
            end
            
            switch obj.numTethers.Value
                case 1
                    
                    val(1).posVec.setValue(obj.Rbridle_cm.Value,'m');
                    
                    %                     val(1).setVelVec(obj.initVelVecGnd.Value(:)+...
                    %                         rotation_sequence(obj.initEulAng.Value)*cross(obj.initAngVelVec.Value,val(1).posVec.Value),'m/s');
                    
                    
                case 3
                    port_thr = obj.surfaceOutlines.port_wing.Value(:,2);
                    %                        + [obj.wingChord.Value*obj.wingTR.Value/2;0;0];
                    
                    aft_thr = obj.RwingLE_cm.Value + ...
                        [max(obj.RhsLE_wingLE.Value(1),obj.Rvs_wingLE.Value(1));0;0]...
                        + [max(obj.hsChord.Value,obj.vsChord.Value);0;0];
                    
                    stbd_thr = port_thr.*[1;-1;1];
                    
                    
                    val(1).setPosVec(port_thr,'m');
                    val(2).setPosVec(aft_thr,'m');
                    val(3).setPosVec(stbd_thr,'m');
                    
                    %                     val(1).setVelVec(obj.initVelVecGnd.Value(:)+...
                    %                         rotation_sequence(obj.initEulAng.Value)*cross(obj.initAngVelVec.Value,val(1).posVec.Value),'m/s');
                    %
                    %                     val(2).setVelVec(obj.initVelVecGnd.Value(:)+...
                    %                         rotation_sequence(obj.initEulAng.Value)*cross(obj.initAngVelVec.Value,val(2).posVec.Value),'m/s');
                    %
                    %                     val(3).setVelVec(obj.initVelVecGnd.Value(:)+...
                    %                         rotation_sequence(obj.initEulAng.Value)*cross(obj.initAngVelVec.Value,val(3).posVec.Value),'m/s');
                    %
                otherwise
                    error('No get method programmed for %d tether attachment points',obj.numTethers.Value);
            end
            
        end
        
        % turbines
        function val = get.turbines(obj)
            
            for ii = 1:obj.numTurbines.Value
                val(ii,1) = OCT.turb;
                val(ii,1).diameter.setValue(0,'m');
                val(ii,1).axisUnitVec.setValue([1;0;0],'');
                val(ii,1).powerCoeff.setValue(0.5,'');
                val(ii,1).dragCoeff.setValue(0.5,'');
            end
            
            switch obj.numTurbines.Value
                case 2
                    port_wing = obj.surfaceOutlines.port_wing.Value(:,2);
                    stbd_wing = port_wing.*[1;-1;1];
                otherwise
                    fprintf('get method not programmed for %d turbines',obj.numTurbines.Value)
                    
            end
            
            val(1).attachPtVec.setValue(port_wing,'m');
            val(2).attachPtVec.setValue(stbd_wing,'m');
            
        end
        
        %fuselage
        function val = get.fuse(obj)
            val = OCT.fuselage;
            val.setDiameter(obj.fuseDiameter.Value,'m');
            val.setRCmToNose(obj.fuseRCmToNose.Value,'m');
            val.setSideDragCoeff(obj.fuseSideDragCoeff.Value,'');
            val.setEndDragCoeff(obj.fuseEndDragCoeff.Value,'');
            %Calculated
            val.setRCmToEnd(obj.RhsLE_wingLE.Value + obj.RwingLE_cm.Value,'m');
        end
        % aerodynamic forces moment arms
        function val = get.fluidMomentArms(obj)
            portWingArm = obj.surfaceOutlines.port_wing.Value(:,2).*[0;0.5;0.5] +...
                obj.RwingLE_cm.Value + [obj.wingChord.Value*obj.wingAR.Value*tand(obj.wingSweep.Value)/4;0;0] + ...
                [obj.wingChord.Value*(obj.wingTR.Value+1)/8;0;0];
            
            stbdWingArm = portWingArm.*[1;-1;1];
            
            hsArm = obj.surfaceOutlines.port_hs.Value(:,1) + ...
                [obj.hsChord.Value/4;0;0];
            
            vsArm = obj.surfaceOutlines.top_vs.Value(:,2).*[0;0;0.5] + ...
                obj.surfaceOutlines.top_vs.Value(:,1) + [obj.vsSpan.Value*tand(obj.vsSweep.Value)/2;0;0] + ...
                [obj.vsChord.Value*(obj.vsTR.Value+1)/8;0;0];
            
            
            val = SIM.parameter('Value',[portWingArm,stbdWingArm,hsArm,vsArm],'Unit','m',...
                'Description','Fluid dynamic surface moment arms');
            
            
        end
        
        % aerodynamic reference area
        function val = get.fluidRefArea(obj)
            Sref = obj.wingAR.Value*obj.wingChord.Value^2;
            
            val = SIM.parameter('Value',Sref,'Unit','m^2',...
                'Description','Reference area for aerodynamic calculations');
        end
        
        
        %% other methods
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            
            props = findAttrValue(obj,'SetAccess','private');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end % end scale
        
        % fluid dynamic coefficient data
        function calcFluidDynamicCoefffs(obj)
            fileLoc = which(obj.fluidCoeffsFileName.Value);
            
            presFolder = pwd;
            
            minDef = -30;
            maxDef = 30;
            
            sNames = {'portWing','stbdWing','hStab','vStab'};
            
            testEmpty = NaN(9,4);
            
            for ii = 1:4
                testEmpty(1,ii) = isempty(obj.(sNames{ii}).aeroCentPosVec.Value);
                testEmpty(2,ii) = isempty(obj.(sNames{ii}).refArea.Value);
                testEmpty(3,ii) = isempty(obj.(sNames{ii}).CL.Value);
                testEmpty(4,ii) = isempty(obj.(sNames{ii}).CD.Value);
                testEmpty(5,ii) = isempty(obj.(sNames{ii}).alpha.Value);
                testEmpty(6,ii) = isempty(obj.(sNames{ii}).GainCL.Value);
                testEmpty(7,ii) = isempty(obj.(sNames{ii}).GainCD.Value);
                testEmpty(8,ii) = isempty(obj.(sNames{ii}).MaxCtrlDeflDn.Value);
                testEmpty(9,ii) = isempty(obj.(sNames{ii}).MaxCtrlDeflUp.Value);
            end
            
            if isfile(fileLoc)
                load(fileLoc,'aeroStruct');
                
                obj.portWing.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,1),'m');
                obj.portWing.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                obj.portWing.CL.setValue(aeroStruct(1).CL,'');
                obj.portWing.CD.setValue(aeroStruct(1).CD,'');
                obj.portWing.alpha.setValue(aeroStruct(1).alpha,'deg');
                obj.portWing.GainCL.setValue(aeroStruct(1).GainCL,'1/deg');
                obj.portWing.GainCD.setValue(aeroStruct(1).GainCD,'1/deg');
                obj.portWing.MaxCtrlDeflDn.setValue(minDef,'deg');
                obj.portWing.MaxCtrlDeflUp.setValue(maxDef,'deg');
                
                obj.stbdWing.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,2),'m');
                obj.stbdWing.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                obj.stbdWing.CL.setValue(aeroStruct(2).CL,'');
                obj.stbdWing.CD.setValue(aeroStruct(2).CD,'');
                obj.stbdWing.alpha.setValue(aeroStruct(2).alpha,'deg');
                obj.stbdWing.GainCL.setValue(aeroStruct(2).GainCL,'1/deg');
                obj.stbdWing.GainCD.setValue(aeroStruct(2).GainCD,'1/deg');
                obj.stbdWing.MaxCtrlDeflDn.setValue(minDef,'deg');
                obj.stbdWing.MaxCtrlDeflUp.setValue(maxDef,'deg');
                
                obj.hStab.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,3),'m');
                obj.hStab.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                obj.hStab.CL.setValue(aeroStruct(3).CL,'');
                obj.hStab.CD.setValue(aeroStruct(3).CD,'');
                obj.hStab.alpha.setValue(aeroStruct(3).alpha,'deg');
                obj.hStab.GainCL.setValue(aeroStruct(3).GainCL,'1/deg');
                obj.hStab.GainCD.setValue(aeroStruct(3).GainCD,'1/deg');
                obj.hStab.MaxCtrlDeflDn.setValue(minDef,'deg');
                obj.hStab.MaxCtrlDeflUp.setValue(maxDef,'deg');
                
                
                obj.vStab.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,4),'m');
                obj.vStab.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                obj.vStab.CL.setValue(aeroStruct(4).CL,'');
                obj.vStab.CD.setValue(aeroStruct(4).CD,'');
                obj.vStab.alpha.setValue(aeroStruct(4).alpha,'deg');
                obj.vStab.GainCL.setValue(aeroStruct(4).GainCL,'1/deg');
                obj.vStab.GainCD.setValue(aeroStruct(4).GainCD,'1/deg');
                obj.vStab.MaxCtrlDeflDn.setValue(minDef,'deg');
                obj.vStab.MaxCtrlDeflUp.setValue(maxDef,'deg');
                
            elseif any(testEmpty,'all')~=1
                
            else
                fprintf([' The file containing the fluid dynamic coefficient data file does not exist.\n',...
                    ' Would you like to run AVL and create data file ''%s'' ?\n'],obj.fluidCoeffsFileName.Value);
                str = input('(Y/N): \n','s');
                if isempty(str)
                    str = 'y';
                end
                
                if strcmpi(str,'Y')
                    avlCreateInputFilePart_v2(obj)
                    
                    %% wing
                    alp_max = 55;
                    alp_min = -55;
                    n_steps = 71;
                    % set run cases
                    alphas   = linspace(alp_min,alp_max,n_steps);
                    ailerons = 0;
                    
                    % run AVL for right wing
                    avlProcessPart_v2(obj,'wing',alphas,ailerons,'Parallel',true);
                    load('resultFile','results');
                    
                    [CLWingTab,CDWingTab] = avlPartitionedLookupTable(results);
                    
                    % get wing aileron gains
                    n_case = 10;
                    alphas = 0;
                    ailerons = linspace(-5,5,n_case);
                    
                    avlProcessPart_v2(obj,'wing',alphas,ailerons,'Parallel',true);
                    load('resultFile','results');
                    
                    CL_w = NaN(1,n_case);
                    CD_w = NaN(1,n_case);
                    for ii = 1:n_case
                        CL_w(ii) = results{1}(ii).FT.CLtot;
                        CD_w(ii) = results{1}(ii).FT.CDtot;
                    end
                    
                    CL_kWing = polyfit(ailerons,CL_w,2);
                    CL_kWing(end) = 0;
                    CD_kWing = polyfit(ailerons,CD_w,2);
                    CD_kWing(end) = 0;
                    
                    % port wing data
                    CdOffset = 0.01;
                    aeroStruct(1).CL = reshape(CLWingTab.Table.Value,[],1);
                    aeroStruct(1).CD = reshape(CDWingTab.Table.Value,[],1) + CdOffset;
                    aeroStruct(1).alpha = reshape(CDWingTab.Breakpoints.Value,[],1);
                    aeroStruct(1).GainCL = reshape(CL_kWing,1,[]);
                    aeroStruct(1).GainCD =  reshape(CD_kWing,1,[]);
                    
                    % stbd wing data
                    aeroStruct(2).CL = aeroStruct(1).CL;
                    aeroStruct(2).CD = aeroStruct(1).CD;
                    aeroStruct(2).alpha = aeroStruct(1).alpha;
                    aeroStruct(2).GainCL = aeroStruct(1).GainCL;
                    aeroStruct(2).GainCD =  aeroStruct(1).GainCD;
                    
                    %% horizontal stabilizers
                    % set run cases
                    alphas   = linspace(alp_min,alp_max,n_steps);
                    ailerons = 0;
                    
                    % run AVL for HS
                    avlProcessPart_v2(obj,'H_stab',alphas,ailerons,'Parallel',true);
                    load('resultFile','results');
                    
                    [CLHSTab,CDHSTab] = avlPartitionedLookupTable(results);
                    
                    % get HS aileron gains
                    alphas = 0;
                    ailerons = linspace(-5,5,n_case);
                    
                    avlProcessPart_v2(obj,'H_stab',alphas,ailerons,'Parallel',true);
                    load('resultFile','results');
                    
                    CL_hs = NaN(1,n_case);
                    CD_hs = NaN(1,n_case);
                    
                    for ii = 1:n_case
                        CL_hs(ii) = results{1}(ii).FT.CLtot;
                        CD_hs(ii) = results{1}(ii).FT.CDtot;
                    end
                    
                    CL_kHS = polyfit(ailerons,CL_hs,2);
                    CL_kHS(end) = 0;
                    CD_kHS = polyfit(ailerons,CD_hs,2);
                    CD_kHS(end) = 0;
                    
                    % HS data
                    aeroStruct(3).CL = reshape(CLHSTab.Table.Value,[],1);
                    aeroStruct(3).CD = reshape(CDHSTab.Table.Value,[],1) + CdOffset;
                    aeroStruct(3).alpha = reshape(CDHSTab.Breakpoints.Value,[],1);
                    aeroStruct(3).GainCL = reshape(CL_kHS,1,[]);
                    aeroStruct(3).GainCD =  reshape(CD_kHS,1,[]);
                    
                    %% vertical stabilizer
                    % set run cases
                    alphas   = linspace(alp_min,alp_max,n_steps);
                    ailerons = 0;
                    
                    % run AVL for VS
                    avlProcessPart_v2(obj,'V_stab',alphas,ailerons,'Parallel',true);
                    load('resultFile','results');
                    
                    [CLVSTab,CDVSTab] = avlPartitionedLookupTable(results);
                    
                    % get VS aileron gains
                    alphas = 0;
                    ailerons = linspace(-5,5,n_case);
                    
                    avlProcessPart_v2(obj,'V_stab',alphas,ailerons,'Parallel',true);
                    load('resultFile','results');
                    
                    CL_vs = NaN(1,n_case);
                    CD_vs = NaN(1,n_case);
                    for ii = 1:n_case
                        CL_vs(ii) = results{1}(ii).FT.CLtot;
                        CD_vs(ii) = results{1}(ii).FT.CDtot;
                    end
                    
                    CL_kVS = polyfit(ailerons,CL_vs,2);
                    CL_kVS(end) = 0;
                    CD_kVS = polyfit(ailerons,CD_vs,2);
                    CD_kVS(end) = 0;
                    
                    aeroStruct(4).CL = reshape(CLVSTab.Table.Value,[],1);
                    aeroStruct(4).CD = reshape(CDVSTab.Table.Value,[],1) + CdOffset;
                    aeroStruct(4).alpha = reshape(CDVSTab.Breakpoints.Value,[],1);
                    aeroStruct(4).GainCL = reshape(CL_kVS,1,[]);
                    aeroStruct(4).GainCD =  reshape(CD_kVS,1,[]);
                    
                    aeroStruct = reshape(aeroStruct,1,[]);
                    
                    save(obj.fluidCoeffsFileName.Value,'aeroStruct');
                    
                    
                    obj.portWing.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,1),'m');
                    obj.portWing.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                    obj.portWing.CL.setValue(aeroStruct(1).CL,'');
                    obj.portWing.CD.setValue(aeroStruct(1).CD,'');
                    obj.portWing.alpha.setValue(aeroStruct(1).alpha,'deg');
                    obj.portWing.GainCL.setValue(aeroStruct(1).GainCL,'1/deg');
                    obj.portWing.GainCD.setValue(aeroStruct(1).GainCD,'1/deg');
                    obj.portWing.MaxCtrlDeflDn.setValue(minDef,'deg');
                    obj.portWing.MaxCtrlDeflUp.setValue(maxDef,'deg');
                    
                    obj.stbdWing.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,2),'m');
                    obj.stbdWing.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                    obj.stbdWing.CL.setValue(aeroStruct(2).CL,'');
                    obj.stbdWing.CD.setValue(aeroStruct(2).CD,'');
                    obj.stbdWing.alpha.setValue(aeroStruct(2).alpha,'deg');
                    obj.stbdWing.GainCL.setValue(aeroStruct(2).GainCL,'1/deg');
                    obj.stbdWing.GainCD.setValue(aeroStruct(2).GainCD,'1/deg');
                    obj.stbdWing.MaxCtrlDeflDn.setValue(minDef,'deg');
                    obj.stbdWing.MaxCtrlDeflUp.setValue(maxDef,'deg');
                    
                    obj.hStab.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,3),'m');
                    obj.hStab.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                    obj.hStab.CL.setValue(aeroStruct(3).CL,'');
                    obj.hStab.CD.setValue(aeroStruct(3).CD,'');
                    obj.hStab.alpha.setValue(aeroStruct(3).alpha,'deg');
                    obj.hStab.GainCL.setValue(aeroStruct(3).GainCL,'1/deg');
                    obj.hStab.GainCD.setValue(aeroStruct(3).GainCD,'1/deg');
                    obj.hStab.MaxCtrlDeflDn.setValue(minDef,'deg');
                    obj.hStab.MaxCtrlDeflUp.setValue(maxDef,'deg');
                    
                    
                    obj.vStab.aeroCentPosVec.setValue(obj.fluidMomentArms.Value(:,4),'m');
                    obj.vStab.refArea.setValue(obj.fluidRefArea.Value,'m^2');
                    obj.vStab.CL.setValue(aeroStruct(4).CL,'');
                    obj.vStab.CD.setValue(aeroStruct(4).CD,'');
                    obj.vStab.alpha.setValue(aeroStruct(4).alpha,'deg');
                    obj.vStab.GainCL.setValue(aeroStruct(4).GainCL,'1/deg');
                    obj.vStab.GainCD.setValue(aeroStruct(4).GainCD,'1/deg');
                    obj.vStab.MaxCtrlDeflDn.setValue(minDef,'deg');
                    obj.vStab.MaxCtrlDeflUp.setValue(maxDef,'deg');
                    
                    delete('wing');
                    delete('H_stab');
                    delete('V_stab');
                    
                    %
                    filepath = fileparts(which('avl.exe'));
                    
                    delete(fullfile(filepath,strcat('resultFile','.mat')));
                    
                    fprintf('''%s'' created in:\n %s\n',...
                        obj.fluidCoeffsFileName.Value,fileparts(which(obj.fluidCoeffsFileName.Value)));
                    
                    cd(presFolder);
                    
                elseif strcmpi(str,'N')
                    warning('Simulation won''t run without valid aero coefficient values')
                    
                else
                    error('Invalid input')
                end
                
            end
            
        end
        
        [output,varargout] = struct(obj,className);
        output = getPropsByClass(obj,className);
        
        
        % plotting functions
        function h = plot(obj,varargin)
            
            p = inputParser;
            addParameter(p,'FigHandle',[],@(x) isa(x,'matlab.ui.Figure'));
            addParameter(p,'EulerAngles',[0 0 0],@isnumeric)
            addParameter(p,'Position',[0 0 0]',@isnumeric)
            addParameter(p,'Basic',false,@islogical) % Only plots aero surfaces if true
            parse(p,varargin{:})
            
            R = rotation_sequence(p.Results.EulerAngles);
            
            if isempty(p.Results.FigHandle)
                h.fig = figure;
                h.fig.Name ='Design';
            else
                h.fig = p.Results.FigHandle;
            end
            
            fs = fieldnames(obj.surfaceOutlines);
            % Aero surfaces (and fuselage)
            for ii = 1:6
                pts = R*obj.surfaceOutlines.(fs{ii}).Value;
                h.surf{ii} = plot3(...
                    pts(1,:)+p.Results.Position(1),...
                    pts(2,:)+p.Results.Position(2),...
                    pts(3,:)+p.Results.Position(3),...
                    'LineWidth',1.2,'Color','k','LineStyle','-',...
                    'DisplayName','Fluid Dynamic Surfaces');
                hold on
            end
            
            if ~p.Results.Basic
                % Tether attachment points
                for ii = 1:obj.numTethers.Value
                    pts = R*obj.thrAttchPts(ii).posVec.Value;
                    h.thrAttchPts{ii} = plot3(...
                        pts(1)+p.Results.Position(1),...
                        pts(2)+p.Results.Position(2),...
                        pts(3)+p.Results.Position(3),...
                        'r+','DisplayName','Tether Attachment Point');
                end
                % Turbines
                for ii = 1:obj.numTurbines.Value
                    pts = R*obj.turbines(ii).attachPtVec.Value;
                    h.turb{ii} = plot3(...
                        pts(1)+p.Results.Position(1),...
                        pts(2)+p.Results.Position(2),...
                        pts(3)+p.Results.Position(3),...
                        'm+','DisplayName','Turbine Attachment Point');
                end
                
                for ii = 1:4
                    pts = R*obj.fluidMomentArms.Value(:,ii);
                    h.momArms{ii} = plot3(...
                        pts(1)+p.Results.Position(1),...
                        pts(2)+p.Results.Position(2),...
                        pts(3)+p.Results.Position(3),...
                        'b+','DisplayName','Fluid Dynamic Center');
                    
                end
                % Center of mass
                h.centOfMass = plot3(0+p.Results.Position(1),0+p.Results.Position(2),0+p.Results.Position(3),'r*');
                % Coordinate origin
                h.origin = plot3(0,0,0,'kx');
                legend([h.surf{1} h.thrAttchPts{1} h.turb{1} h.momArms{2} h.centOfMass h.origin])
            end
            grid on
            axis equal
            xlabel('X (m)')
            ylabel('Y (m)')
            zlabel('Z (m)')
            view(-45,30)
            
            set(gca,'DataAspectRatio',[1 1 1])
        end
        
        function plotCoeffPolars(obj)
            fh = findobj( 'Type', 'Figure', 'Name', 'Partitioned Aero Coeffs');
            
            if isempty(fh)
                fh = figure;
                fh.Position =[102 92 3*560 2*420];
                fh.Name ='Partitioned Aero Coeffs';
            else
                figure(fh);
            end
            
            % left wing
            ax1 = subplot(2,4,1);
            plot(obj.portWing.alpha.Value,obj.portWing.CL.Value);
            hCL_ax = gca;
            
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Port Wing')
            grid on
            hold on
            
            ax5 = subplot(2,4,5);
            plot(obj.portWing.alpha.Value,obj.portWing.CD.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            hCD_ax = gca;
            
            linkaxes([ax1,ax5],'x');
            
            % right wing
            ax2 = subplot(2,4,2);
            plot(obj.stbdWing.alpha.Value,obj.stbdWing.CL.Value);
            
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Stbd Wing')
            grid on
            hold on
            
            ax6 = subplot(2,4,6);
            plot(obj.stbdWing.alpha.Value,obj.stbdWing.CD.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            linkaxes([ax2,ax6],'x');
            
            % HS
            ax3 = subplot(2,4,3);
            plot(obj.hStab.alpha.Value,obj.hStab.CL.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('H-stab')
            grid on
            hold on
            
            ax7 = subplot(2,4,7);
            plot(obj.hStab.alpha.Value,obj.hStab.CD.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            linkaxes([ax3,ax7],'x');
            
            % VS
            ax4 = subplot(2,4,4);
            plot(obj.vStab.alpha.Value,obj.vStab.CL.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('V-stab')
            grid on
            hold on
            
            ax8 = subplot(2,4,8);
            plot(obj.vStab.alpha.Value,obj.vStab.CD.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            linkaxes([ax4,ax8],'x');
            
            axis([ax1 ax2 ax3 ax4],[-inf inf hCL_ax.YLim(1) hCL_ax.YLim(2)]);
            axis([ax5 ax6 ax7 ax8],[-inf inf hCD_ax.YLim(1) hCD_ax.YLim(2)]);
            
        end
        
        % Function to animate the vehicle
        
        val = animateSim(obj,tsc,timeStep,varargin)
        val = animateBody(obj,tsc,timeStep,varargin)
    
        function writeFile(hobj,fn)
            % writes the vehicle to file
            % fn = filename
            
            % try to open file
            fid = fopen(fn,'w');
            if fid < 0
                error('Unable to open file');
            end
            p = properties(hobj);
            for blamo = 1:1:length(p)
                currentprop = p{blamo};
                if isa(hobj.(currentprop),'SIM.parameter')
                    % wite to file
                    fstr = '%f,';
                    fstr = repmat(fstr,1,numel(hobj.(currentprop).Value));
                    if isempty(hobj.(currentprop).Unit)
                        unit = '''''';
                    else
                        unit = hobj.(currentprop).Unit;
                    end
                    fprintf(fid,['%s,' fstr '%s,%s\n'],currentprop,hobj.(currentprop).Value,unit,hobj.(currentprop).Description);
                elseif isa(hobj.(currentprop),'OCT.fuselage')
                    pfuse = properties(hobj.(currentprop));
                        for slamo = 1:1:length(pfuse)
                            fuseprop = pfuse{slamo};
                            % wite to file
                            fstr = '%f,';
                            fstr = repmat(fstr,1,numel(hobj.(currentprop).(fuseprop).Value));
                            if isempty(hobj.(currentprop).(fuseprop).Unit)
                                unit = '''''';
                            else
                                unit = hobj.(currentprop).(fuseprop).Unit;
                            end
                            fprintf(fid,['fuselage%s,' fstr '%s,%s\n'],fuseprop,hobj.(currentprop).(fuseprop).Value,unit,hobj.(currentprop).(fuseprop).Description);
                        end
                end % if is parameter
            end % for props    
            fclose(fid);
        end % writeFile
    
    end % methods
 
end