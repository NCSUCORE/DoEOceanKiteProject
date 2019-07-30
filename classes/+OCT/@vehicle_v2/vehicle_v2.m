classdef vehicle_v2 < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        fluidDensity
        numTethers
        numTurbines
        buoyFactor
        volume
        Ixx
        Iyy
        Izz
        Ixy
        Ixz
        Iyz
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
        % intial conditions
        initPosVecGnd
        initVelVecGnd
        initEulAngBdy
        initAngVelVecBdy
    end
    
    properties (Dependent)
        mass
        inertia
        addedMass
        addedInertia
        surfaceOutlines
        thrAttchPts
        turbines
        fluidMomentArms
        fluidRefArea
    end
    
    methods
        %% Constructor
        function obj = vehicle_v2
            %VEHICLE Construct an instance of this class
            obj.fluidDensity = SIM.parameter('Unit','kg/m^3','Description','Fluid density');
            obj.numTethers  = SIM.parameter('Description','Number of tethers');
            obj.numTurbines = SIM.parameter('Description','Number of turbines');
            obj.buoyFactor = SIM.parameter('Description','Buoyancy Factor');
            % mass, volume and inertia
            obj.volume         = SIM.parameter('Unit','m^3','Description','volume');
            obj.Ixx            = SIM.parameter('Unit','kg*m^2','Description','Ixx');
            obj.Iyy            = SIM.parameter('Unit','kg*m^2','Description','Iyy');
            obj.Izz            = SIM.parameter('Unit','kg*m^2','Description','Izz');
            obj.Ixy            = SIM.parameter('Unit','kg*m^2','Description','Ixy');
            obj.Ixz            = SIM.parameter('Unit','kg*m^2','Description','Ixz');
            obj.Iyz            = SIM.parameter('Unit','kg*m^2','Description','Iyz');
            % some vectors
            obj.Rbridle_cm    = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from CM to bridle point');
            obj.centOfBuoy        = SIM.parameter('Unit','m','Description','Vector going from CM to center of buoyancy');
            % fluid coeffs file name
            obj.fluidCoeffsFileName = SIM.parameter('Description','File that contains fluid dynamics coefficient data');
            % defining aerodynamic surfaces
            obj.RwingLE_cm    = SIM.parameter('Unit','m','Description','Vector going from CM to wing leading edge');
            obj.wingChord     = SIM.parameter('Unit','m','Description','Wing root chord');
            obj.wingAR        = SIM.parameter('Description','Wing Aspect ratio');
            obj.wingTR        = SIM.parameter('Description','Wing Taper ratio');
            obj.wingSweep     = SIM.parameter('Unit','deg','Description','Wing sweep angle');
            obj.wingDihedral  = SIM.parameter('Unit','deg','Description','Wing dihedral angle');
            obj.wingIncidence = SIM.parameter('Unit','deg','Description','Wing flow incidence angle');
            obj.wingNACA      = SIM.parameter('Description','Wing NACA airfoil');
            obj.wingClMax     = SIM.parameter('Description','Wing airfoil maximum lift coefficient');
            obj.wingClMin     = SIM.parameter('Description','Wing airfoil minimum lift coefficient');
            % H-stab
            obj.RhsLE_wingLE  = SIM.parameter('Unit','m','Description','Vector going from wing leading edge to H-stab leading edge');
            obj.hsChord     = SIM.parameter('Unit','m','Description','H-stab root chord');
            obj.hsAR        = SIM.parameter('Description','H-stab Aspect ratio');
            obj.hsTR        = SIM.parameter('Description','H-stab Taper ratio');
            obj.hsSweep     = SIM.parameter('Unit','deg','Description','H-stab sweep angle');
            obj.hsDihedral  = SIM.parameter('Unit','deg','Description','H-stab dihedral angle');
            obj.hsIncidence = SIM.parameter('Unit','deg','Description','H-stab flow incidence angle');
            obj.hsNACA      = SIM.parameter('Description','H-stab NACA airfoil');
            obj.hsClMax     = SIM.parameter('Description','H-stab airfoil maximum lift coefficient');
            obj.hsClMin     = SIM.parameter('Description','H-stab airfoil minimum lift coefficient');
            % V-stab
            obj.Rvs_wingLE    = SIM.parameter('Unit','m','Description','Vector going from wing leading edge to V-stab leading edge');
            obj.vsChord     = SIM.parameter('Unit','m','Description','V-stab root chord');
            obj.vsSpan      = SIM.parameter('Unit','m','Description','V-stab span');
            obj.vsTR        = SIM.parameter('Description','V-stab Taper ratio');
            obj.vsSweep     = SIM.parameter('Unit','deg','Description','V-stab sweep angle');
            obj.vsNACA      = SIM.parameter('Description','V-stab NACA airfoil');
            obj.vsClMax     = SIM.parameter('Description','V-stab airfoil maximum lift coefficient');
            obj.vsClMin     = SIM.parameter('Description','V-stab airfoil minimum lift coefficient');
            % aerodynamic surfaces
            obj.portWing = OCT.aeroSurf;
            obj.portWing.spanUnitVec.setValue([0;1;0],'');
            obj.portWing.chordUnitVec.setValue([1;0;0],'');

            obj.stbdWing = OCT.aeroSurf;
            obj.stbdWing.spanUnitVec.setValue([0;1;0],'');
            obj.stbdWing.chordUnitVec.setValue([1;0;0],'');
            
            obj.hStab = OCT.aeroSurf;
            obj.hStab.spanUnitVec.setValue([0;1;0],'');
            obj.hStab.chordUnitVec.setValue([1;0;0],'');
            
            obj.vStab = OCT.aeroSurf;
            obj.vStab.spanUnitVec.setValue([0;0;1],'');
            obj.vStab.chordUnitVec.setValue([1;0;0],'');
            % initial conditions
            obj.initPosVecGnd = SIM.parameter('Unit','m','Description','Initial CM position represented in the inertial frame');
            obj.initVelVecGnd = SIM.parameter('Unit','m/s','Description','Initial CM velocity represented in the inertial frame');
            obj.initEulAngBdy         = SIM.parameter('Unit','rad','Description','Initial Euler angles');
            obj.initAngVelVecBdy        = SIM.parameter('Unit','rad/s','Description','Initial angular velocities');
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
        
        function setVolume(obj,val,units)
            obj.volume.setValue(val,units);
        end
        
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
        
        % initial conditions
        function setInitialCmPos(obj,val,units)
            obj.initPosVecGnd.setValue(reshape(val,3,1),units);
        end             

        function setInitialCmVel(obj,val,units)
            obj.initVelVecGnd.setValue(reshape(val,3,1),units);
        end
        
        function setInitialEuler(obj,val,units)
            obj.initEulAngBdy.setValue(reshape(val,3,1),units);
        end
        
        function setInitialAngVel(obj,val,units)
            obj.initAngVelVecBdy.setValue(reshape(val,3,1),units);
        end
        
        %% getters
        % mass
        function val = get.mass(obj)
            val = SIM.parameter('Value',obj.fluidDensity.Value*obj.volume.Value/...
                obj.buoyFactor.Value,...
                'Unit','kg','Description','Vehicle mass');
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
            val = SIM.parameter('Value',[m_added_x 0 0;0 m_added_y 0; 0 0 m_added_z],...
                'Unit','kg','Description','Added mass of the system in the body frame');
            
        end
        
        % added inertia
        function val = get.addedInertia(obj)
            val = SIM.parameter('Value',zeros(3,3),...
                'Unit','kg*m^2','Description','Added inertia of the system in the body frame'); 
        end
        
        
        
        % Tether attachment points
        function val = get.thrAttchPts(obj)
            
            for ii = 1:obj.numTethers.Value
                val(ii,1) = OCT.thrAttch;
            end
            
            switch obj.numTethers.Value
                case 1
                    
                    val(1).posVec.setValue(obj.Rbridle_cm.Value,'m');
                    
                case 3
                    port_thr = obj.surfaceOutlines.port_wing.Value(:,2);
                    %                        + [obj.wingChord.Value*obj.wingTR.Value/2;0;0];
                    
                    aft_thr = obj.RwingLE_cm.Value + ...
                        [max(obj.RhsLE_wingLE.Value(1),obj.Rvs_wingLE.Value(1));0;0]...
                        + [max(obj.hsChord.Value,obj.vsChord.Value);0;0];
                    
                    stbd_thr = port_thr.*[1;-1;1];

                    
                    val(1).posVec.setValue(port_thr,'m');
                    val(2).posVec.setValue(aft_thr,'m');
                    val(3).posVec.setValue(stbd_thr,'m');
                    
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

    end
    
    
    
    
end