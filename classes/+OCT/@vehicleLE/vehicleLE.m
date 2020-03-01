classdef vehicleLE < dynamicprops
    
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        fluidDensity
        numTethers
        buoyFactor
        fluidCoeffsFileName
        
        numTurbines
        turbDiam
        
        volume
        inertia
        
        Ma6x6
        D6x6

        allMaxCtrlDef
        allMinCtrlDef
        allMaxCtrlDefSpeed
        
        rB_LE
        rCM_LE
        rbridle_LE
        rCentOfBuoy_LE
        
        wingChord
        wingAR
        wingTR
        wingSweep
        wingDihedral
        wingIncidence
        wingNACA

        hStab
        vStab
        portWing
        stbdWing
        fuse
        
        initPosVecGnd
        initVelVecBdy
        initEulAng
        initAngVelVec
    end
    
    properties (Dependent)
        mass
        thrAttchPts
        turbines
        fluidMomentArms
        fluidRefArea
        M6x6
    end
    
    methods
        %% Constructor
        function obj = vehicleLE
            %VEHICLE Construct an instance of this class
            obj.fluidDensity = SIM.parameter('Unit','kg/m^3','Description','Fluid density');
            obj.numTethers  = SIM.parameter('Description','Number of tethers','NoScale',true);
            obj.buoyFactor = SIM.parameter('Description','Buoyancy Factor = (Kite Density)/(Water Density)','NoScale',true);
            obj.fluidCoeffsFileName = SIM.parameter('Description','File that contains fluid dynamics coefficient data','NoScale',true);
            
            %Turbines
            obj.numTurbines = SIM.parameter('Description','Number of turbines','NoScale',true);
            obj.turbDiam = SIM.parameter('Value',0,'Unit','m','Description','Turbine Diameter');
            
            % mass, volume and inertia
            obj.volume         = SIM.parameter('Unit','m^3','Description','volume');
            obj.inertia        = SIM.parameter('Unit','kg*m^2','Description','Inertia Matrix');
            
            %Added Mass Matrices
            obj.Ma6x6          = SIM.parameter('Value',zeros(6),'Unit','','Description','6x6 Added Mass Matrix');
            obj.D6x6           = SIM.parameter('Value',zeros(6),'Unit','','Description','6x6 Damping Matrix');
            
            %Control Surface Deflections
            obj.allMaxCtrlDef     = SIM.parameter('Value',30,'Unit','deg','Description','Largest control surface deflection for all surfaces in the positive direction');
            obj.allMinCtrlDef     = SIM.parameter('Value',-30,'Unit','deg','Description','Largest control surface deflection for all surfaces in the negative direction');
            obj.allMaxCtrlDefSpeed= SIM.parameter('Value',60,'Unit','deg/s','Description','Fastest rate of control surface deflection for all surfaces in either direction');
            
            %Important Point Locations
            obj.rB_LE          = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from the Wing LE to the body frame');
            obj.rCM_LE         = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from the Wing LE to the Center of Mass');
            obj.rbridle_LE     = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from the Wing LE to bridle point');
            obj.rCentOfBuoy_LE = SIM.parameter('Unit','m','Description','Vector going from CM to center of buoyancy');
            
            % Overall Wing Properties (Used to create portWing and stbdWing
            obj.wingChord      = SIM.parameter('Unit','m','Description','Wing root chord');
            obj.wingAR         = SIM.parameter('Description','Wing Aspect ratio','NoScale',true);
            obj.wingTR         = SIM.parameter('Description','Wing Taper ratio','NoScale',true);
            obj.wingSweep      = SIM.parameter('Unit','deg','Description','Wing sweep angle');
            obj.wingDihedral   = SIM.parameter('Unit','deg','Description','Wing dihedral angle');
            obj.wingIncidence  = SIM.parameter('Unit','deg','Description','Wing flow incidence angle');
            obj.wingNACA       = SIM.parameter('Description','Wing NACA airfoil','NoScale',true);
            
            % aerodynamic surfaces
            obj.hStab = OCT.aeroSurfLE;
            obj.hStab.spanUnitVec.setValue([0;1;0],'','NoScale',true);
            obj.hStab.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            obj.hStab.maxCtrlDef.setValue(obj.allMaxCtrlDef.Value,'deg')
            obj.hStab.minCtrlDef.setValue(obj.allMinCtrlDef.Value,'deg')
            obj.hStab.maxCtrlDefSpeed.setValue(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            
            obj.vStab = OCT.aeroSurfLE;
            obj.vStab.spanUnitVec.setValue([0;0;1],'','NoScale',true);
            obj.vStab.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            obj.vStab.maxCtrlDef.setValue(obj.allMaxCtrlDef.Value,'deg')
            obj.vStab.minCtrlDef.setValue(obj.allMinCtrlDef.Value,'deg')
            obj.vStab.maxCtrlDefSpeed.setValue(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            
            obj.portWing = OCT.aeroSurfLE;
            obj.portWing.spanUnitVec.setValue([0;-1;0],'','NoScale',true);
            obj.portWing.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            obj.portWing.setRootChord(obj.wingChord.Value,'m');
            obj.portWing.setSpanOrAR('AR',obj.wingAR.Value,'');
            obj.portWing.setTR(obj.wingTR.Value,'');
            obj.portWing.setSweep(obj.wingSweep.Value,'deg');
            obj.portWing.setDihedral(obj.wingDihedral.Value,'deg');
            obj.portWing.setIncidence(obj.wingIncidence.Value,'deg');
            obj.portWing.setNACA(obj.wingNACA.Value,'');
            obj.portWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.portWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.portWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            
            obj.stbdWing = OCT.aeroSurfLE;
            obj.stbdWing.spanUnitVec.setValue([0;-1;0],'','NoScale',true);
            obj.stbdWing.chordUnitVec.setValue([1;0;0],'','NoScale',true);
            obj.stbdWing.setRootChord(obj.wingChord.Value,'m');
            obj.stbdWing.setSpanOrAR('AR',obj.wingAR.Value,'');
            obj.stbdWing.setTR(obj.wingTR.Value,'');
            obj.stbdWing.setSweep(obj.wingSweep.Value,'deg');
            obj.stbdWing.setDihedral(obj.wingDihedral.Value,'deg');
            obj.stbdWing.setIncidence(obj.wingIncidence.Value,'deg');
            obj.stbdWing.setNACA(obj.wingNACA.Value,'');
            obj.stbdWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.stbdWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.stbdWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            
            % initial conditions
            obj.initPosVecGnd           = SIM.parameter('Unit','m','Description','Initial CM position represented in the inertial frame');
            obj.initVelVecBdy           = SIM.parameter('Unit','m/s','Description','Initial CM velocity represented in the body frame ');
            obj.initEulAng              = SIM.parameter('Unit','rad','Description','Initial Euler angles');
            obj.initAngVelVec           = SIM.parameter('Unit','rad/s','Description','Initial angular velocity vector');
            
            %Legacy Properties

        end
        
        %% setters
        function setFluidDensity(obj,val,units)
            obj.fluidDensity.setValue(val,units)
        end

        function setNumTethers(obj,val,units)
            obj.numTethers.setValue(val,units)
            if obj.numTethers.Value > 1
                warning("The vehicle is being constructed with tether attachment points at hardcoded locations in the OCT.Vehicle.get.thrAttachPts method")
            end
        end

        function setBuoyFactor(obj,val,units)
            obj.buoyFactor.setValue(val,units)
        end

        function setNumTurbines(obj,val,units)
            obj.numTurbines.setValue(val,units)
            if obj.numTurbines.Value ~=  0 && obj.turbDiam.Value ~= 0
                warning("The vehicle is being constructed with non-zero diameter turbines using hardcoded values in the OCT.Vehicle.get.turbines method")
            end
        end

        function setTurbDiam(obj,val,units)
            obj.turbDiam.setValue(val,units)
            if obj.numTurbines.Value ~=  0 && obj.turbDiam.Value ~= 0
                warning("The vehicle is being constructed with non-zero diameter turbines using hardcoded values in the OCT.Vehicle.get.turbines method")
            end
        end

        function setVolume(obj,val,units)
            obj.volume.setValue(val,units)
        end

        function setInertia(obj,val,units)
            obj.inertia.setValue(val,units)
        end

        function setMa6x6(obj,val,units)
            obj.Ma6x6.setValue(val,units)
        end

        function setD6x6(obj,val,units)
            obj.D6x6.setValue(val,units)
        end

        function setAllMaxCtrlDef(obj,val,units)
            obj.allMaxCtrlDef.setValue(val,units)
        end

        function setAllMinCtrlDef(obj,val,units)
            obj.allMinCtrlDef.setValue(val,units)
        end

        function setAllMaxCtrlDefSpeed(obj,val,units)
            obj.allMaxCtrlDefSpeed.setValue(val,units)
        end

        function setRB_LE(obj,val,units)
            obj.rB_LE.setValue(val,units)
        end

        function setRCM_LE(obj,val,units)
            obj.rCM_LE.setValue(val,units)
        end

        function setRbridle_LE(obj,val,units)
            obj.rbridle_LE.setValue(val,units)
        end

        function setRCentOfBuoy_LE(obj,val,units)
            obj.rCentOfBuoy_LE.setValue(val,units)
        end

        function setWingChord(obj,val,units)
            obj.wingChord.setValue(val,units)
            updateWings
        end

        function setWingAR(obj,val,units)
            obj.wingAR.setValue(val,units)
            updateWings
        end

        function setWingTR(obj,val,units)
            obj.wingTR.setValue(val,units)
            updateWings
        end

        function setWingSweep(obj,val,units)
            obj.wingSweep.setValue(val,units)
            updateWings
        end

        function setWingDihedral(obj,val,units)
            obj.wingDihedral.setValue(val,units)
            updateWings
        end

        function setWingIncidence(obj,val,units)
            obj.wingIncidence.setValue(val,units)
            updateWings
        end

        function setWingNACA(obj,val,units)
            obj.wingNACA.setValue(val,units)
            updateWings
        end

        function setFluidCoeffsFileName(obj,val,units)
            if ~endsWith(val,'.mat')
                val = [val '.mat'] ;
            end
            obj.fluidCoeffsFileName.setValue(val,units)
        end

        function setHStab(obj,val,units)
            obj.hStab.setValue(val,units)
        end

        function setVStab(obj,val,units)
            obj.vStab.setValue(val,units)
        end

        function setInitPosVecGnd(obj,val,units)
            obj.initPosVecGnd.setValue(val,units)
        end

        function setInitVelVecBdy(obj,val,units)
            obj.initVelVecBdy.setValue(val,units)
        end

        function setInitEulAng(obj,val,units)
            obj.initEulAng.setValue(val,units)
        end

        function setInitAngVelVec(obj,val,units)
            obj.initAngVelVec.setValue(val,units)
        end
        %% getters
       
        % mass
        function val = get.mass(obj)
            val = SIM.parameter('Value',obj.fluidDensity.Value*obj.volume.Value/...
                obj.buoyFactor.Value,...
                'Unit','kg','Description','Vehicle mass');
        end
                            
        %Fluid Moment Arms
        function val = get.fluidMomentArms(obj)
            arms=zeros(3,4);
            arms(:,1)=obj.rB_LE.Value + obj.portWing.rSurfLE_WingLEBdy.Value + (obj.portWing.RSurf2Bdy.Value * obj.portWing.rAeroCent_SurfLE);
            arms(:,2)=obj.rB_LE.Value + obj.stbdWing.rSurfLE_WingLEBdy.Value + (obj.stbdWing.RSurf2Bdy.Value * obj.stbdWing.rAeroCent_SurfLE);
            arms(:,3)=obj.rB_LE.Value + obj.hStab.rSurfLE_WingLEBdy.Value + (obj.hStab.RSurf2Bdy.Value * obj.hStab.rAeroCent_SurfLE);
            arms(:,4)=obj.rB_LE.Value + obj.vStab.rSurfLE_WingLEBdy.Value + (obj.vStab.RSurf2Bdy.Value * obj.vStab.rAeroCent_SurfLE);
            val = SIM.parameter('Value',arms,'Unit','m');
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
                    port_thr = obj.surfaceOutlines.port_wing.Value(:,2)-...
                        1.2*[obj.wingChord.Value;0;0];
                    %                        + [obj.wingChord.Value*obj.wingTR.Value/2;0;0];
                    aft_thr = obj.RwingLE_cm.Value + ...
                        [min(obj.RhsLE_wingLE.Value(1),obj.Rvs_wingLE.Value(1));0;0];...
%                         + [max(obj.hsChord.Value,obj.vsChord.Value);0;0] ...
%                         -[obj.hsChord];
                    stbd_thr = port_thr.*[1;-1;1];

                    val(1).setPosVec(port_thr,'m');
                    val(2).setPosVec(aft_thr,'m');
                    val(3).setPosVec(stbd_thr,'m');
                otherwise
                    error('No get method programmed for %d tether attachment points',obj.numTethers.Value);
            end
        end
        
        % turbines
        function val = get.turbines(obj)
            for ii = 1:obj.numTurbines.Value
                val(ii,1) = OCT.turb;
                val(ii,1).diameter.setValue(obj.turbDiam.Value,'m');
                val(ii,1).axisUnitVec.setValue([1;0;0],'');
                val(ii,1).powerCoeff.setValue(0.5,'');
                val(ii,1).dragCoeff.setValue(1.28,'');
                % http://www-mdp.eng.cam.ac.uk/web/library/enginfo/aerothermal_dvd_only/aero/fprops/introvisc/node11.html
            end
            switch obj.numTurbines.Value
                case 2
                    port_turb = obj.surfaceOutlines.top_vs.Value(:,1) + [0;-15e-3;9.14e-3];
                    stbd_turb = obj.surfaceOutlines.top_vs.Value(:,1) + [0;15e-3;9.14e-3];
                    val(1).attachPtVec.setValue(port_turb,'m');
                    val(2).attachPtVec.setValue(stbd_turb,'m');
                otherwise
                    fprintf('get method not programmed for %d turbines',obj.numTurbines.Value) 
            end            
        end
                
        % aerodynamic reference area
        function val = get.fluidRefArea(obj)
            Sref = obj.wingAR.Value*obj.wingChord.Value^2;
            val = SIM.parameter('Value',Sref,'Unit','m^2',...
                'Description','Reference area for aerodynamic calculations');
        end
        
        function val = get.M6x6(obj)
            S=@(v) [0 -v(3) v(2);v(3) 0 -v(1);-v(2) v(1) 0];
            M=zeros(6,6);
            M(1,1)=obj.mass.Value;
            M(2,2)=obj.mass.Value;
            M(3,3)=obj.mass.Value;
            M(1:3,4:6)=-obj.mass.Value*S(-obj.RwingLE_cm.Value);
            M(4:6,1:3)=obj.mass.Value*S(-obj.RwingLE_cm.Value);
            M(4:6,4:6)=obj.inertia.Value;
            val = SIM.parameter('Value',M,'Unit','','Description',...
                '6x6 Mass-Inertia Matrix with origin at Wing LE Mid-Span');
        end
           
        %% other methods
        % Function to scale the object
        function obj = scale(obj,lengthScaleFactor,densityScaleFactor)
            props = findAttrValue(obj,'SetAccess','private');
            for ii = 1:numel(props)
                obj.(props{ii}).scale(lengthScaleFactor,densityScaleFactor);
            end
        end
        
        %Sets initial conditions on the path at the specified pathVariable
        function setICsOnPath(obj,initPathVar,pathFunc,geomParams,pathCntrPt,speed) %#ok<INUSL>
            % Sets initial conditions of the vehicle to be on the path
            [initPos,initVel] = eval(sprintf('%s(initPathVar,geomParams,pathCntrPt)',pathFunc));
            obj.setInitPosVecGnd(initPos,'m');
            obj.setInitVelVecBdy([-speed 0 0],'m/s');
            % Initial body z points radially out
            bdyZ = (initPos(:)-pathCntrPt(:))./sqrt(sum((initPos(:)-pathCntrPt(:)).^2));
            % Initial body x points backwards (opposite velocity(
            bdyX = -initVel;
            % Initial body y is calculated from the cross product of z & x
            bdyY = cross(bdyZ,bdyX);
            % Calculate euler angles from the rotation matrix
            obj.setInitEulAng(flip(rotm2eul([bdyX(:)'; bdyY(:)'; bdyZ(:)']')),'rad')
            % Initial angular velocity is zero
            obj.setInitAngVelVec([0 0 0],'rad/s');
        end
        
        %Update individual wing values
        %Called by setters on wing properties
        function updateWings(obj)
            obj.portWing.setRSurfLE_WingLEBdy([0;0;0],'m');
            obj.portWing.setSpanUnitVec([0;-1;0],'','NoScale',true);
            obj.portWing.setChordUnitVec([1;0;0],'','NoScale',true);
            obj.portWing.setRootChord(obj.wingChord.Value,'m');
            obj.portWing.setSpanOrAR('AR',obj.wingAR.Value,'');
            obj.portWing.setTR(obj.wingTR.Value,'');
            obj.portWing.setSweep(obj.wingSweep.Value,'deg');
            obj.portWing.setDihedral(obj.wingDihedral.Value,'deg');
            obj.portWing.setIncidence(obj.wingIncidence.Value,'deg');
            obj.portWing.setNACA(obj.wingNACA.Value,'');
            obj.portWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.portWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.portWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            
            obj.stbdWing.setRSurfLE_WingLEBdy([0;0;0],'m');
            obj.stbdWing.setSpanUnitVec([0;-1;0],'','NoScale',true);
            obj.stbdWing.setChordUnitVec([1;0;0],'','NoScale',true);
            obj.stbdWing.setRootChord(obj.wingChord.Value,'m');
            obj.stbdWing.setSpanOrAR('AR',obj.wingAR.Value,'');
            obj.stbdWing.setTR(obj.wingTR.Value,'');
            obj.stbdWing.setSweep(obj.wingSweep.Value,'deg');
            obj.stbdWing.setDihedral(obj.wingDihedral.Value,'deg');
            obj.stbdWing.setIncidence(obj.wingIncidence.Value,'deg');
            obj.stbdWing.setNACA(obj.wingNACA.Value,'');
            obj.stbdWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.stbdWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.stbdWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
        end
        
        % fluid dynamic coefficient data
        function calcFluidDynamicCoefffs(obj)
            fileLoc = which(obj.fluidCoeffsFileName.Value);
                                  
            if ~isfile(fileLoc)
                fprintf([' The file containing the fluid dynamic coefficient data file does not exist.\n',...
                    ' Would you like to run AVL and create data file ''%s'' ?\n'],obj.fluidCoeffsFileName.Value);
                str = input('(Y/N): \n','s');
                if isempty(str)
                    str = 'Y';
                end
                if strcmpi(str,'Y')
                    runAVL(obj)
                else
                    warning('Simulation won''t run without valid aero coefficient values')
                end
            else 
                load(fileLoc,'aeroStruct');
            end
                
            obj.portWing.CL.setValue(aeroStruct(1).CL,'');
            obj.portWing.CD.setValue(aeroStruct(1).CD,'');
            obj.portWing.alpha.setValue(aeroStruct(1).alpha,'deg');
            obj.portWing.GainCL.setValue(aeroStruct(1).GainCL,'1/deg');
            obj.portWing.GainCD.setValue(aeroStruct(1).GainCD,'1/deg');

            obj.stbdWing.CL.setValue(aeroStruct(2).CL,'');
            obj.stbdWing.CD.setValue(aeroStruct(2).CD,'');
            obj.stbdWing.alpha.setValue(aeroStruct(2).alpha,'deg');
            obj.stbdWing.GainCL.setValue(aeroStruct(2).GainCL,'1/deg');
            obj.stbdWing.GainCD.setValue(aeroStruct(2).GainCD,'1/deg');

            obj.hStab.CL.setValue(aeroStruct(3).CL,'');
            obj.hStab.CD.setValue(aeroStruct(3).CD,'');
            obj.hStab.alpha.setValue(aeroStruct(3).alpha,'deg');
            obj.hStab.GainCL.setValue(aeroStruct(3).GainCL,'1/deg');
            obj.hStab.GainCD.setValue(aeroStruct(3).GainCD,'1/deg');

            obj.vStab.CL.setValue(aeroStruct(4).CL,'');
            obj.vStab.CD.setValue(aeroStruct(4).CD,'');
            obj.vStab.alpha.setValue(aeroStruct(4).alpha,'deg');
            obj.vStab.GainCL.setValue(aeroStruct(4).GainCL,'1/deg');
            obj.vStab.GainCD.setValue(aeroStruct(4).GainCD,'1/deg');
        end
        
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
                h.centOfMass = plot3(0+p.Results.Position(1),0+p.Results.Position(2),0+p.Results.Position(3),'r*','DisplayName','Center of Mass');
                % Coordinate origin
                h.origin = plot3(0,0,0,'kx','DisplayName','Body Frame Origin');
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
            hWingCL_ax = gca;
            
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
            hWingCD_ax = gca;
            
            linkaxes([ax1,ax5],'x');
            
            % right wing
            ax2 = subplot(2,4,2);
            plot(obj.stbdWing.alpha.Value,obj.stbdWing.CL.Value);
            
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Starboard Wing')
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
            hhStabCL_ax = gca;
            
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Horizontal stabilizer')
            grid on
            hold on
            
            ax7 = subplot(2,4,7);
            plot(obj.hStab.alpha.Value,obj.hStab.CD.Value);
            hhStabCD_ax = gca;
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            linkaxes([ax3,ax7],'x');
            
            % VS
            ax4 = subplot(2,4,4);
            plot(obj.vStab.alpha.Value,obj.vStab.CL.Value);
            hvStabCL_ax = gca;
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Vertical stabilizer')
            grid on
            hold on
            
            ax8 = subplot(2,4,8);
            plot(obj.vStab.alpha.Value,obj.vStab.CD.Value);
            hvStabCD_ax = gca;
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            linkaxes([ax4,ax8],'x');
            
            axis([ax1 ax2 ax3 ax4],[-20 20 ...
                min([hWingCL_ax.YLim(1),hhStabCL_ax.YLim(1),hvStabCL_ax.YLim(1)])...
                max([hWingCL_ax.YLim(2),hhStabCL_ax.YLim(2),hvStabCL_ax.YLim(2)])]);
            axis([ax5 ax6 ax7 ax8],[-20 20 ...
                min([hWingCD_ax.YLim(1),hhStabCD_ax.YLim(1),hvStabCD_ax.YLim(1)])...
                max([hWingCD_ax.YLim(2),hhStabCD_ax.YLim(2),hvStabCD_ax.YLim(2)])]);
            
        end
        
        %Get a struct of parameters of the desired class
        [output,varargout] = struct(obj,className);
        
        %returns a cell array of properties of the desired class
        output = getPropsByClass(obj,className);
               
        % Functions to animate the vehicle
        val = animateSim(obj,tsc,timeStep,varargin)
        val = animateBody(obj,tsc,timeStep,varargin)
    end % methods
end