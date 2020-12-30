classdef vehicleM < dynamicprops
    %VEHICLE Summary of this class goes here
    %   Detailed explanation goes here
    properties (SetAccess = private)
        fluidDensity
        numTethers
        buoyFactor
        fluidCoeffsFileName
        flowGradientDist
        oldFluidMomentArms
        
        numTurbines
        
        volume
        inertia_CM
        
        Ma6x6_LEUL
        Ma6x6_LEUR
        Ma6x6_LELL
        Ma6x6_LELR
        D6x6_LE

        allMaxCtrlDef
        allMinCtrlDef
        allMaxCtrlDefSpeed
        
        rB_LE
        rCM_LE
        rBridle_LE
        rCentOfBuoy_LE
        
        wingRootChord
        wingAR
        wingTR
        wingSweep
        wingDihedral
        wingIncidence
        wingAirfoil
        wingClMin
        wingClMax

        hStab
        vStab
        portWing
        stbdWing
        fuse
        
        initPosVecGnd
        initVelVecBdy
        initEulAng
        initAngVelVec
        
        hydroChracterization
        
        optAlpha
    end
    
    properties (Dependent)
        mass
        thrAttchPts_B %Used for moment arms
        
        fluidMomentArms
        fuseMomentArm
        buoyMomentArm
        turbMomentArms
        rCM_B
        wingTipPositions
        
        fluidRefArea
        M6x6_B
        Ma6x6_LE
        
        staticMargin
        
        contactPoints
    end
    
    methods
        %% Constructor
        function obj = vehicleM
            %VEHICLE Construct an instance of this class
            obj.fluidDensity        = SIM.parameter('Unit','kg/m^3','Description','Fluid density, used to calculate mass');
            obj.numTethers          = SIM.parameter('Description','Number of tethers','NoScale',true);
            obj.buoyFactor          = SIM.parameter('Description','Buoyancy Factor = (Kite Density)/(Water Density)','NoScale',true);
            obj.fluidCoeffsFileName = SIM.parameter('Description','File that contains fluid dynamics coefficient data','NoScale',true);
            obj.flowGradientDist    = SIM.parameter('Value',0.08,'Unit','m','Description','Distance to space points used for estimating gradient of the flow field');
            obj.oldFluidMomentArms  = SIM.parameter('Value',0,'Description','Turns on the old (incorrect) calculation for fluid moment arms');
            
            %Turbines
            obj.numTurbines = SIM.parameter('Description','Number of turbines','NoScale',true);
            
            % mass, volume and inertia
            obj.volume         = SIM.parameter('Unit','m^3','Description','volume');
            obj.inertia_CM     = SIM.parameter('Unit','kg*m^2','Description','Inertia Matrix');
            
            %Added Mass Matrices
            obj.Ma6x6_LEUL        = SIM.parameter('Value',zeros(3),'Unit','kg','Description','Upper left quadrant 6x6 Added Mass Matrix');
            obj.Ma6x6_LEUR        = SIM.parameter('Value',zeros(3),'Unit','kg*m','Description','Upper right quadrant 6x6 Added Mass Matrix');
            obj.Ma6x6_LELL        = SIM.parameter('Value',zeros(3),'Unit','kg*m','Description','Lower left quadrant 6x6 Added Mass Matrix');
            obj.Ma6x6_LELR        = SIM.parameter('Value',zeros(3),'Unit','kg*m^2','Description','Lower right quadrant 6x6 Added Mass Matrix');
            obj.D6x6_LE           = SIM.parameter('Value',zeros(6),'Unit','','Description','6x6 Damping Matrix');
            
            %Control Surface Deflections
            obj.allMaxCtrlDef     = SIM.parameter('Value',30,'Unit','deg','Description','Largest control surface deflection for all surfaces in the positive direction');
            obj.allMinCtrlDef     = SIM.parameter('Value',-30,'Unit','deg','Description','Largest control surface deflection for all surfaces in the negative direction');
            obj.allMaxCtrlDefSpeed= SIM.parameter('Value',60,'Unit','deg/s','Description','Fastest rate of control surface deflection for all surfaces in either direction');
            
            %Important Point Locations
            obj.rB_LE          = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from the Wing LE to the body frame');
            obj.rCM_LE         = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from the Wing LE to the Center of Mass');
            obj.rBridle_LE     = SIM.parameter('Value',[0;0;0],'Unit','m','Description','Vector going from the Wing LE to bridle point');
            obj.rCentOfBuoy_LE = SIM.parameter('Unit','m','Description','Vector going from CM to center of buoyancy');
            
            % Overall Wing Properties (Used to create portWing and stbdWing
            obj.wingRootChord  = SIM.parameter('Unit','m','Description','Wing root chord');
            obj.wingAR         = SIM.parameter('Description','Wing Aspect ratio','NoScale',true);
            obj.wingTR         = SIM.parameter('Description','Wing Taper ratio','NoScale',true);
            obj.wingSweep      = SIM.parameter('Unit','deg','Description','Wing sweep angle');
            obj.wingDihedral   = SIM.parameter('Unit','deg','Description','Wing dihedral angle');
            obj.wingIncidence  = SIM.parameter('Unit','deg','Description','Wing flow incidence angle');
            obj.wingAirfoil    = SIM.parameter('Description','Wing airfoil','NoScale',true);
            obj.wingClMin      = SIM.parameter('Description','minimum section Lift Coef','NoScale',true);
            obj.wingClMax      = SIM.parameter('Description','maximum section Lift Coef','NoScale',true);
            
            % aerodynamic surfaces
            obj.hStab = OCT.aeroSurf;
            obj.hStab.setSpanUnitVec([0;1;0],'');
            obj.hStab.setChordUnitVec([1;0;0],'');
            obj.hStab.setIncAlphaUnitVecSurf([0;-1;0],'');
            obj.hStab.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.hStab.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.hStab.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            
            obj.vStab = OCT.aeroSurf;
            obj.vStab.setSpanUnitVec([0;0;1],'');
            obj.vStab.setChordUnitVec([1;0;0],'');
            obj.vStab.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.vStab.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.vStab.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            obj.vStab.setIncAlphaUnitVecSurf([0;-1;0],'');
            
            obj.portWing = OCT.aeroSurf;          
            obj.stbdWing = OCT.aeroSurf;
            obj.updateWings;
            
            obj.fuse = OCT.fuselage;
%             obj.turb = OCT.turb;
            
%             obj.updateTurb;
            
            % initial conditions 
            obj.initPosVecGnd           = SIM.parameter('Unit','m','Description','Initial CM position represented in the inertial frame');
            obj.initVelVecBdy           = SIM.parameter('Unit','m/s','Description','Initial CM velocity represented in the body frame ');
            obj.initEulAng              = SIM.parameter('Unit','rad','Description','Initial Euler angles');
            obj.initAngVelVec           = SIM.parameter('Unit','rad/s','Description','Initial angular velocity vector');
            

            obj.hydroChracterization    = SIM.parameter('Value',1,'Unit','','Description','1 = AVL; 2 = XFoil; 3 = XFlr');
            obj.optAlpha                = SIM.parameter('Unit','deg','Description','Optimal constant angle of attack');
            %Legacy Properties

        end
        
        %% setters
        function obj = build(obj,varargin)
            defTurbName = {};
            for ii = 1:obj.numTurbines.Value
                defTurbName{ii} = sprintf('turb%d',ii);
            end
            
            p = inputParser;
            addParameter(p,'TurbNames',defTurbName,@(x) all(cellfun(@(x) isa(x,'char'),x)))
            addParameter(p,'TurbClass','turb',@(x) any(strcmp(x,{'turb'})))
            parse(p,varargin{:})
            
            % Create tturbines
            for ii = 1:obj.numTurbines.Value
                obj.addprop(p.Results.TurbNames{ii});
                obj.(p.Results.TurbNames{ii}) = eval(sprintf('OCT.%s',p.Results.TurbClass));
            end
        end
        function setFluidDensity(obj,val,units)
            obj.fluidDensity.setValue(val,units);
        end

        function setNumTethers(obj,val,units)
            obj.numTethers.setValue(val,units);
            if obj.numTethers.Value > 1
                warning("The vehicle is being constructed with tether attachment points at hardcoded locations in the OCT.Vehicle.get.thrAttachPts method")
            end
        end

        function setBuoyFactor(obj,val,units)
            obj.buoyFactor.setValue(val,units);
        end
        
        function setFluidCoeffsFileName(obj,val,units)
            if ~endsWith(val,'.mat')
                val = [val '.mat'] ;
            end
            obj.fluidCoeffsFileName.setValue(val,units);
        end
                
        function setFlowGradientDist(obj,val,units)
            obj.flowGradientDist.setValue(val,units);
        end
        
        function setHydroCharacterization(obj,val,units)
            obj.hydroChracterization.setValue(val,units);
        end
        
        function setOptAlpha(obj,val,units)
            obj.optAlpha.setValue(val,units);
        end

        function setNumTurbines(obj,val,units)
            obj.numTurbines.setValue(val,units);
        end

        function setOldFluidMomentArms(obj,val,units)
            obj.oldFluidMomentArms.setValue(val,units);
        end
        
        function setVolume(obj,val,units)
            obj.volume.setValue(val,units);
        end

        function setInertia_CM(obj,val,units)
            obj.inertia_CM.setValue(val,units);
        end

        function setMa6x6_LE(obj,val,units)
            if isempty(units)
                obj.Ma6x6_LEUL.setValue(val(1:3,1:3),'kg');
                obj.Ma6x6_LEUR.setValue(val(1:3,4:6),'kg*m');
                obj.Ma6x6_LELL.setValue(val(4:6,1:3),'kg*m');
                obj.Ma6x6_LELR.setValue(val(4:6,4:6),'kg*m^2');
            else
                error('Units for Ma6x6_LE should be '''', the setter will define the partial matrix units')
            end
        end

        function setD6x6_LE(obj,val,units)
            obj.D6x6_LE.setValue(val,units);
        end

        function setAllMaxCtrlDef(obj,val,units)
            obj.allMaxCtrlDef.setValue(val,units);
        end

        function setAllMinCtrlDef(obj,val,units)
            obj.allMinCtrlDef.setValue(val,units);
        end

        function setAllMaxCtrlDefSpeed(obj,val,units)
            obj.allMaxCtrlDefSpeed.setValue(val,units);
        end

        function setRB_LE(obj,val,units)
            obj.rB_LE.setValue(val(:),units);
        end

        function setRCM_LE(obj,val,units)
            obj.rCM_LE.setValue(val(:),units);
        end

        function setRBridle_LE(obj,val,units)
            obj.rBridle_LE.setValue(val(:),units);
        end

        function setRCentOfBuoy_LE(obj,val,units)
            obj.rCentOfBuoy_LE.setValue(val(:),units);
        end

        function setWingRootChord(obj,val,units)
            obj.wingRootChord.setValue(val,units);
            obj.updateWings
        end

        function setWingAR(obj,val,units)
            obj.wingAR.setValue(val,units);
            obj.updateWings
        end

        function setWingTR(obj,val,units)
            obj.wingTR.setValue(val,units);
            obj.updateWings
        end

        function setWingSweep(obj,val,units)
            obj.wingSweep.setValue(val,units);
            obj.updateWings
        end

        function setWingDihedral(obj,val,units)
            obj.wingDihedral.setValue(val,units);
            obj.updateWings
        end

        function setWingIncidence(obj,val,units)
            obj.wingIncidence.setValue(val,units);
            obj.updateWings
        end

        function setWingAirfoil(obj,val,units)
            obj.wingAirfoil.setValue(val,units);
            obj.updateWings
        end
        
        function setWingClMin(obj,val,units)
            obj.wingClMin.setValue(val,units);
            obj.updateWings
        end

        function setWingClMax(obj,val,units)
            obj.wingClMax.setValue(val,units);
            obj.updateWings
        end

        function setHStab(obj,val,units)
            obj.hStab.setValue(val,units);
        end

        function setVStab(obj,val,units)
            obj.vStab.setValue(val,units);
        end

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
        
        %% getters
       
        % mass
        function val = get.mass(obj)
            val = SIM.parameter('Value',obj.fluidDensity.Value*obj.volume.Value/...
                obj.buoyFactor.Value,...
                'Unit','kg','Description','Vehicle mass');
        end
                            
        %Moment Arms
        function val = get.fluidMomentArms(obj)
            arms=zeros(3,4);
            if obj.oldFluidMomentArms.Value
                hspan = obj.wingRootChord.Value * obj.wingAR.Value * .5;
                arms(:,1)=-obj.rB_LE.Value + [hspan*tand(obj.wingSweep.Value)/2 + obj.wingRootChord.Value*(1+obj.wingTR.Value)/8;
                                              -hspan/2;
                                              hspan*tand(obj.wingDihedral.Value)/2];
                arms(:,2)=arms(:,1).*[1;-1;1];
                arms(:,3)=-obj.rB_LE.Value + obj.hStab.rSurfLE_WingLEBdy.Value + [obj.hStab.rootChord.Value/4;0;0];
                arms(:,4)=-obj.rB_LE.Value + obj.vStab.rSurfLE_WingLEBdy.Value + ...
                    [obj.vStab.halfSpan.Value*tand(obj.vStab.sweep.Value)/2 + obj.vStab.rootChord.Value * (1+obj.vStab.TR.Value)/8;0;obj.vStab.halfSpan.Value*.5];
            else
                %Updated Calculations    
                arms(:,1)=-obj.rB_LE.Value + obj.portWing.rSurfLE_WingLEBdy.Value + (obj.portWing.RSurf2Bdy.Value * obj.portWing.rAeroCent_SurfLE.Value);
                arms(:,2)=-obj.rB_LE.Value + obj.stbdWing.rSurfLE_WingLEBdy.Value + (obj.stbdWing.RSurf2Bdy.Value * obj.stbdWing.rAeroCent_SurfLE.Value);
                arms(:,3)=-obj.rB_LE.Value + obj.hStab.rSurfLE_WingLEBdy.Value + (obj.hStab.RSurf2Bdy.Value * obj.hStab.rAeroCent_SurfLE.Value);
                arms(:,4)=-obj.rB_LE.Value + obj.vStab.rSurfLE_WingLEBdy.Value + (obj.vStab.RSurf2Bdy.Value * obj.vStab.rAeroCent_SurfLE.Value);
            end
            val = SIM.parameter('Value',arms,'Unit','m');
        end
        function val = get.fuseMomentArm(obj)
            val = SIM.parameter('Value',-obj.rB_LE.Value + obj.fuse.rAeroCent_LE.Value,'Unit','m');
        end
        function val = get.buoyMomentArm(obj)
            val = SIM.parameter('Value',-obj.rB_LE.Value + obj.rCentOfBuoy_LE.Value,'Unit','m');
        end
        function val = get.turbMomentArms(obj)
            N = obj.numTurbines.Value;
            if N == 1
                arms = -obj.rB_LE.Value + obj.turb1.attachPtVec.Value;
            else
                arms(:,1) = -obj.rB_LE.Value + obj.turb1.attachPtVec.Value;
                arms(:,2) = -obj.rB_LE.Value + obj.turb2.attachPtVec.Value;
            end
            val = SIM.parameter('Value',arms,'Unit','m');
        end
        function val = get.wingTipPositions(obj)
            arms=zeros(3,4);
            arms(:,1)=-obj.rB_LE.Value + obj.portWing.rSurfLE_WingLEBdy.Value + (obj.portWing.RSurf2Bdy.Value * obj.portWing.rTipLE.Value);
            arms(:,2)=-obj.rB_LE.Value + obj.stbdWing.rSurfLE_WingLEBdy.Value + (obj.stbdWing.RSurf2Bdy.Value * obj.stbdWing.rTipLE.Value);
            arms(:,3)=-obj.rB_LE.Value + obj.hStab.rSurfLE_WingLEBdy.Value + (obj.hStab.RSurf2Bdy.Value * obj.hStab.rTipLE.Value);
            arms(:,4)=-obj.rB_LE.Value + obj.vStab.rSurfLE_WingLEBdy.Value + (obj.vStab.RSurf2Bdy.Value * obj.vStab.rTipLE.Value);
            val = SIM.parameter('Value',arms,'Unit','m');
        end
        function val = get.rCM_B(obj)
            val = SIM.parameter('Value',-obj.rB_LE.Value + obj.rCM_LE.Value,'Unit','m');
        end
        
        % Tether attachment points
        function val = get.thrAttchPts_B(obj)
            
            for ii = 1:obj.numTethers.Value
                val(ii,1) = OCT.thrAttch;
            end
            switch obj.numTethers.Value
                case 1
                    val(1).setPosVec(-obj.rB_LE.Value + obj.rBridle_LE.Value,'m');              
                case 3
                    port_thr = -obj.rB_LE.Value +  obj.portWing.outlinePtsBdy.Value(:,2)-...%outside leading edge
                        1.2*[obj.wingRootChord.Value;0;0];
                    %                        + [obj.wingRootChord.Value*obj.wingTR.Value/2;0;0];
                    aft_thr = -obj.rB_LE.Value + -obj.rCM_LE.Value + ...
                        [min(obj.hStab.rSurfLE_WingLEBdy.Value(1),obj.vStab.rSurfLE_WingLEBdy.Value(1));0;0];...
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
                
        % aerodynamic reference area
        function val = get.fluidRefArea(obj)
            Sref = 2 * obj.portWing.planformArea.Value;
            val = SIM.parameter('Value',Sref,'Unit','m^2',...
                'Description','Reference area for aerodynamic calculations');
        end
        
        function val = get.M6x6_B(obj)
            S=@(v) [0 -v(3) v(2);v(3) 0 -v(1);-v(2) v(1) 0];
            M=zeros(6,6);
            M(1,1)=obj.mass.Value;
            M(2,2)=obj.mass.Value;
            M(3,3)=obj.mass.Value;
            M(1:3,4:6)=-obj.mass.Value*S(obj.rCM_B.Value);
            M(4:6,1:3)=obj.mass.Value*S(obj.rCM_B.Value);
            x=obj.rCM_B.Value(1);
            y=obj.rCM_B.Value(2);
            z=obj.rCM_B.Value(3);
            M(4:6,4:6)=obj.inertia_CM.Value+ (obj.mass.Value * ...
                        [y^2 + z^2, -x*y     , -x*z;...
                         -x*y     , x^2 + z^2, -y*z;...
                         -x*z     , -y*z     , x^2 + y^2]);
            val = SIM.parameter('Value',M,'Unit','','Description',...
                '6x6 Mass-Inertia Matrix with origin at Wing LE Mid-Span');
        end
        
        function val = get.Ma6x6_LE(obj)
            mat = [obj.Ma6x6_LEUL.Value obj.Ma6x6_LEUR.Value;obj.Ma6x6_LELL.Value obj.Ma6x6_LELR.Value;];
            val = SIM.parameter('Value',mat,'Unit','','Description','6x6 Added Mass Matrix. Created from scaled quadrant matrices');
        end
        
        function val = get.staticMargin(obj)
            h0 = obj.portWing.rAeroCent_SurfLE.Value(1)/obj.portWing.MACLength.Value;
            eta_s = .6; %standard  http://ciurpita.tripod.com/rc/notes/neutralPt.html
            hStabArea = 2*(obj.hStab.halfSpan.Value * .5 * (1+obj.hStab.TR.Value)*obj.hStab.rootChord.Value);
            wingArea = 2*(obj.portWing.halfSpan.Value * .5 * (1+obj.portWing.TR.Value)*obj.portWing.rootChord.Value);
            cla_wing = (obj.portWing.CL.Value(ceil(end/2)+1)-obj.portWing.CL.Value(ceil(end/2)-1))/(obj.portWing.alpha.Value(ceil(end/2)+1)-obj.portWing.alpha.Value(ceil(end/2)-1));
            cla_hs = (obj.hStab.CL.Value(ceil(end/2)+1)-obj.hStab.CL.Value(ceil(end/2)-1))/(obj.hStab.alpha.Value(ceil(end/2)+1)-obj.hStab.alpha.Value(ceil(end/2)-1));
            V_s = (hStabArea * (obj.hStab.rSurfLE_WingLEBdy.Value(1) - obj.portWing.rootChord.Value))/(wingArea * obj.portWing.MACLength.Value);
            depsilon_dalpha = .5;
            hn = h0 + eta_s*V_s*(cla_hs/cla_wing)*(1-depsilon_dalpha);
            margin = hn - (obj.rCM_LE.Value(1) / obj.portWing.MACLength.Value);
            val = SIM.parameter('Unit','m','Value',margin,'Description','Static Margin of Stability');
        end
        
        function val = get.contactPoints(obj)
            % Calculate location of points at the edges of the body where
            % we will calculate forces and moments from contact with ground
            ptsMat=[...
                obj.portWing.outlinePtsBdy.Value(:,2)... % Port wing tip LE point
                obj.stbdWing.outlinePtsBdy.Value(:,2)... % Starboard wing tip LE point
                obj.hStab.outlinePtsBdy.Value(:,[3 5])... % H stabilizer TE tip points
                obj.fuse.rNose_LE.Value-[0 0 obj.fuse.diameter.Value/2]'...% Fuselage nose - diameter/2 (in body z)
                obj.fuse.rEnd_LE.Value-[0 0 obj.fuse.diameter.Value/2]'];% Fuselage tail - diameter/2 (in body z)
            val = SIM.parameter('Unit','m','Value',ptsMat,'Description','Points where contact forces are modeled');
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
            obj.portWing.setSpanUnitVec([0;-1;0],'');
            obj.portWing.setChordUnitVec([1;0;0],'');
            obj.portWing.setRootChord(obj.wingRootChord.Value,'m');
            obj.portWing.setTR(obj.wingTR.Value,'');
            if ~isempty(obj.wingTR) && ~isempty(obj.wingTR.Value)
                obj.portWing.setHalfSpanGivenAR(obj.wingAR.Value/2,'');
            end
            obj.portWing.setSweep(obj.wingSweep.Value,'deg');
            %Negative because in the wing frame, the dihedral and incidence
            %are flipped if they match the stbd wing
                obj.portWing.setDihedral(-obj.wingDihedral.Value,'deg');
                obj.portWing.setIncidence(-obj.wingIncidence.Value,'deg');
            obj.portWing.setAirfoil(obj.wingAirfoil.Value,'');
            obj.portWing.setClMin(obj.wingClMin.Value,'');
            obj.portWing.setClMax(obj.wingClMax.Value,'');
            obj.portWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.portWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.portWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            %Positive Y (all other surfs are -Y) because the port wing span
            %vector is in the negative body Y direction, but alpha still
            %increases as apparent velocity rotates about the negative body Y axis.
                obj.portWing.setIncAlphaUnitVecSurf([0;1;0],'');
            
            obj.stbdWing.setRSurfLE_WingLEBdy([0;0;0],'m');
            obj.stbdWing.setSpanUnitVec([0;1;0],'');
            obj.stbdWing.setChordUnitVec([1;0;0],'');
            obj.stbdWing.setRootChord(obj.wingRootChord.Value,'m');
            obj.stbdWing.setTR(obj.wingTR.Value,'');
            if ~isempty(obj.wingTR) && ~isempty(obj.wingTR.Value)
                obj.stbdWing.setHalfSpanGivenAR(obj.wingAR.Value/2,'');
            end
            obj.stbdWing.setSweep(obj.wingSweep.Value,'deg');
            obj.stbdWing.setDihedral(obj.wingDihedral.Value,'deg');
            obj.stbdWing.setIncidence(obj.wingIncidence.Value,'deg');
            obj.stbdWing.setAirfoil(obj.wingAirfoil.Value,'');
            obj.stbdWing.setClMin(obj.wingClMin.Value,'');
            obj.stbdWing.setClMax(obj.wingClMax.Value,'');
            obj.stbdWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.stbdWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.stbdWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')
            obj.stbdWing.setIncAlphaUnitVecSurf([0;-1;0],'');
        end
        
        % fluid dynamic coefficient data
        function calcFluidDynamicCoefffs(obj)
            fileLoc = which(obj.fluidCoeffsFileName.Value);            
            if ~isfile(fileLoc)
                fprintf(['The file containing the fluid dynamic coefficient data file does not exist.\n',...
                    'Would you like to run AVL and create data file ''%s'' ?\n'],obj.fluidCoeffsFileName.Value);
                str = input('(Y/N): \n','s');
                if isempty(str);  str = 'Y';  end
                if strcmpi(str,'Y')
                    aeroStruct = runAVL(obj);
                else
                    warning('Simulation won''t run without valid aero coefficient values')
                end
            else
                fprintf(['The file conaining the fluid dynamic coefficient data "%s" already exists.\n',...
                    'Would you like to overwrite?\n'],obj.fluidCoeffsFileName.Value);
                str = input('(Y/N): \n','s');
                if isempty(str);  str = 'Y';  end
                if strcmpi(str,'Y')
                    aeroStruct = runAVL(obj);
                else
                    fprintf('Would you like to create a new file?\n');
                    str1 = input('(Y/N): \n','s');
                    if isempty(str1);  str1 = 'Y';  end
                    if strcmpi(str1,'Y')
                        newName = input('New filename (excluding ".mat"): \n','s');
                        obj.setFluidCoeffsFileName(newName,'');
                        aeroStruct = runAVL(obj);
                    else
                        load(fileLoc,'aeroStruct');
                    end
                end
            end
            if obj.hydroChracterization.Value == 2
                if obj.portWing.AR.Value == 4.5
                    if obj.portWing.halfSpan.Value == 5
                        W = load('NACA2412_b10_AR9.mat');
                    elseif obj.portWing.halfSpan.Value == 4.5
                        W = load('NACA2412_b9_AR9.mat');
                    elseif obj.portWing.halfSpan.Value == 4
                        W = load('NACA2412_b8_AR9.mat');
                    else
                        error('No XFoil wing data exists for this combination of span = %.1f and AR = %.1f',obj.portWing.halfSpan.Value,obj.portWing.AR.Value)
                    end
                elseif obj.portWing.AR.Value == 4
                    W = load('NACA2412_b8_AR8.mat');
                elseif obj.portWing.AR.Value == 3.5
                    W = load('NACA2412_b8_AR7.mat');
                elseif floor(obj.portWing.AR.Value*10)/10 == 3.7 %&& obj.portWing.Airfoil.Value == 'SG6040.dat'
                    W = load('SG6040_AR7dot4_EXPT.mat');
                else  
                    error('No XFoil wing data exists for this combination of span = %.1f and AR = %.1f',obj.portWing.halfSpan.Value,obj.portWing.AR.Value)
                end
                aeroStruct(1).CL = W.cl_c/2;    aeroStruct(1).CD = W.CD_c/2;    aeroStruct(1).alpha = W.alfa_c;
                aeroStruct(2).CL = W.cl_c/2;    aeroStruct(2).CD = W.CD_c/2;    aeroStruct(2).alpha = W.alfa_c;
                if obj.hStab.halfSpan.Value == 2
                    if obj.hStab.rootChord.Value == 0.55
                        H = load('NACA0015_b2_c0.55.mat');
                    elseif obj.hStab.rootChord.Value == 0.6
                        H = load('NACA0015_b2_c0.6.mat');
                    else
                        error('No XFoil wing data exists for this combination of span = %.1f and chord = %.2f',obj.hStab.halfSpan.Value,obj.hStab.rootChord.Value)
                    end
                elseif obj.hStab.halfSpan.Value == 1.95
                    H = load('NACA0015_b1.95_c0.52.mat');
                elseif obj.hStab.halfSpan.Value == 0.2
                    H = load('NACA0015_b0.2_c0.055_1ms.mat');
                else
                    error('No XFoil wing data exists for this combination of span = %.3f and chord = %.3f',obj.hStab.halfSpan.Value,obj.hStab.rootChord.Value)
                end
                aeroStruct(3).CL = (H.cl_c-H.cl_c(36))*obj.hStab.planformArea.Value/obj.fluidRefArea.Value;
                aeroStruct(3).CD = H.CD_c*obj.hStab.planformArea.Value/obj.fluidRefArea.Value;
                aeroStruct(3).alpha = H.alfa_c-obj.hStab.incidence.Value;
                if obj.vStab.halfSpan.Value ~= 0.195
                    V = load('NACA0015_b.95_vStab.mat');
                elseif obj.vStab.halfSpan.Value ~= 0.2
                    V = load('NACA0015_b0.195_c_0.052_1ms.mat');
                else
                    V = load('NACA0015_b0.2_c0.055_1ms.mat');
                end
                aeroStruct(4).CL = (V.cl_c-V.cl_c(36))*obj.vStab.planformArea.Value/obj.fluidRefArea.Value;
                aeroStruct(4).CD = V.CD_c*obj.vStab.planformArea.Value/obj.fluidRefArea.Value;
                aeroStruct(4).alpha = V.alfa_c;
            elseif obj.hydroChracterization.Value == 3
                AR = obj.wingAR.Value;
                % hard coded values corresponding to NACA 2412
                if ~strcmp(obj.wingAirfoil.Value,'NACA2412')
                    warning('XFLR values are only applicable to wingAirfoil.Value=NACA2412');
                end
                gammaw = 0.9512;
                eLw = 0.7019;
                Clw0 = 0.16;
                Cdw_visc = 0.0297;
                Cdw_ind = 0.2697;
                AoA = linspace(-55,55,71)';
                [CLFullWing,CDFullWing] = ...
                    XFLRWingCalc(AoA,AR,gammaw,eLw,Clw0,Cdw_visc,...
                    Cdw_ind,obj.wingAirfoil.Value);
                [CLhStab,CDhStab] = XFLRHStabCalc_Ind(AoA,obj.fluidRefArea.Value,obj.hStab.planformArea.Value,obj.hStab.incidence.Value);
                [CLvStab,CDvStab] = XFLRVStabCalc(AoA,obj.fluidRefArea.Value,obj.vStab.planformArea.Value);
                % overwrite values from AVL
                for ii = 1:2
                    aeroStruct(ii).alpha = AoA;
                    aeroStruct(ii).CL = CLFullWing./2;
                    aeroStruct(ii).CD = CDFullWing./2;
                end
                aeroStruct(3).alpha = AoA;
                aeroStruct(3).CL    = CLhStab;
                aeroStruct(3).CD    = CDhStab;
                aeroStruct(4).alpha = AoA;
                aeroStruct(4).CL    = CLvStab;
                aeroStruct(4).CD    = CDvStab;
            elseif obj.hydroChracterization.Value == 4
                AR = obj.wingAR.Value;
                % hard coded values corresponding to NACA 2412
                if ~strcmp(obj.wingAirfoil.Value,'NACA2412')
                    warning('XFLR values are only applicable to wingAirfoil.Value=NACA2412');
                end
                gammaw = 0.9512;
                eLw = 0.7019;
                Clw0 = 0.16;
                Cdw_visc = 0.0297;
                Cdw_ind = 0.15;
                AoA = linspace(-55,55,71)';
                [CLFullWing,CDFullWing] = ...
                    XFLRWingCalc(AoA,AR,gammaw,eLw,Clw0,Cdw_visc,...
                    Cdw_ind,obj.wingAirfoil.Value);
                [CLhStab,CDhStab] = XFLRHStabCalc_Ind(AoA,obj.fluidRefArea.Value,obj.hStab.planformArea.Value,obj.hStab.incidence.Value);
                [CLvStab,CDvStab] = XFLRVStabCalc(AoA,obj.fluidRefArea.Value,obj.vStab.planformArea.Value);
                % overwrite values from AVL
                for ii = 1:2
                    aeroStruct(ii).alpha = AoA;
                    aeroStruct(ii).CL = CLFullWing./2;
                    aeroStruct(ii).CD = CDFullWing./2+.0035;
                end
                aeroStruct(3).alpha = AoA;
                aeroStruct(3).CL    = CLhStab;
                aeroStruct(3).CD    = CDhStab+.0035;
                aeroStruct(4).alpha = AoA;
                aeroStruct(4).CL    = CLvStab;
                aeroStruct(4).CD    = CDvStab+.0035;
            end
                
            obj.portWing.setCL(aeroStruct(1).CL,'');
            obj.portWing.setCD(aeroStruct(1).CD,'');
            obj.portWing.setAlpha(aeroStruct(1).alpha,'deg');
            obj.portWing.setGainCL(aeroStruct(1).GainCL,'1/deg');
            obj.portWing.setGainCD(aeroStruct(1).GainCD,'1/deg');
            obj.portWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.portWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.portWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')

            obj.stbdWing.setCL(aeroStruct(2).CL,'');
            obj.stbdWing.setCD(aeroStruct(2).CD,'');
            obj.stbdWing.setAlpha(aeroStruct(2).alpha,'deg');
            obj.stbdWing.setGainCL(aeroStruct(2).GainCL,'1/deg');
            obj.stbdWing.setGainCD(aeroStruct(2).GainCD,'1/deg');
            obj.stbdWing.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.stbdWing.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.stbdWing.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')

            obj.hStab.setCL(aeroStruct(3).CL,'');
            obj.hStab.setCD(aeroStruct(3).CD,'');
            obj.hStab.setAlpha(aeroStruct(3).alpha,'deg');
            obj.hStab.setGainCL(aeroStruct(3).GainCL,'1/deg');
            obj.hStab.setGainCD(aeroStruct(3).GainCD,'1/deg');
            obj.hStab.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.hStab.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.hStab.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')

            obj.vStab.setCL(aeroStruct(4).CL,'');
            obj.vStab.setCD(aeroStruct(4).CD,'');
            obj.vStab.setAlpha(aeroStruct(4).alpha,'deg');
            obj.vStab.setGainCL(aeroStruct(4).GainCL,'1/deg');
            obj.vStab.setGainCD(aeroStruct(4).GainCD,'1/deg');
            obj.vStab.setMaxCtrlDef(obj.allMaxCtrlDef.Value,'deg')
            obj.vStab.setMinCtrlDef(obj.allMinCtrlDef.Value,'deg')
            obj.vStab.setMaxCtrlDefSpeed(obj.allMaxCtrlDefSpeed.Value,'deg/s')            
        end
        function h = plot(obj,varargin)
            
            p = inputParser;
            addParameter(p,'FigHandle',[],@(x) isa(x,'matlab.ui.Figure'));
            addParameter(p,'AxHandle',[],@(x) isa(x,'matlab.graphics.axis.Axes'));
            addParameter(p,'EulerAngles',[0 0 0],@isnumeric)
            addParameter(p,'Position',[0 0 0]',@isnumeric)
            addParameter(p,'fuseRings',8,@isnumeric);
            addParameter(p,'Basic',false,@islogical) % Only plots aero surfaces if true
            parse(p,varargin{:})
            
            R = rotation_sequence(p.Results.EulerAngles);
            
            if isempty(p.Results.FigHandle) && isempty(p.Results.AxHandle)
                h.fig = figure;
                h.fig.Name ='Design';
            else
                h.fig = p.Results.FigHandle;
            end
            
            if isempty(p.Results.AxHandle)
                h.ax = gca;
            else
                h.ax = p.Results.AxHandle;
            end
            
            fs = obj.getPropsByClass("OCT.aeroSurf");
            % Aero surfaces (and fuselage)
            for ii = 1:4
                pts = R*obj.(fs{ii}).outlinePtsBdy.Value;
                h.surf{ii} = plot3(h.ax,...
                    pts(1,:)+p.Results.Position(1),...
                    pts(2,:)+p.Results.Position(2),...
                    pts(3,:)+p.Results.Position(3),...
                    'LineWidth',1.2,'Color','k','LineStyle','-',...
                    'DisplayName','Fluid Dynamic Surfaces');
                hold on
            end
            if p.Results.fuseRings == 0
                fusepts = [obj.fuse.rNose_LE.Value obj.fuse.rEnd_LE.Value];
                h.surf{5} = plot3(h.ax,fusepts(1,:),fusepts(2,:),fusepts(3,:),...
                                  'LineWidth',1.2,'Color','k','LineStyle','-',...
                                  'DisplayName','Fluid Dynamic Surfaces');
            else
                x=linspace(obj.fuse.rNose_LE.Value(1)+obj.fuse.diameter.Value/2,obj.fuse.rEnd_LE.Value(1)-obj.fuse.diameter.Value/2,p.Results.fuseRings);
                perSlice = 10;
                x = reshape(repmat(x,perSlice,1),[1 numel(x)*perSlice]);
                th=linspace(0,2*pi,perSlice);
                d=obj.fuse.diameter.Value;
                y=repmat(d/2*cos(th),1,p.Results.fuseRings);
                z=repmat(d/2*sin(th),1,p.Results.fuseRings);
                numextra=(perSlice-1)*2;
                xend=x(end);
                for i = 0:numextra-1
                    if mod(i,4)==0 || mod(i,4)==3
                        x(end+1)=x(1);
                    else
                        x(end+1)=xend;
                    end
                end
                y(end+1:end+numextra) = reshape(repmat(y(2:perSlice),2,1),[1 numextra]);
                z(end+1:end+numextra) = reshape(repmat(z(2:perSlice),2,1),[1 numextra]);
                
                [sx, sy, sz]=sphere;
                sx = reshape(obj.fuse.diameter.Value/2*sx,[1 numel(sx)]);
                sy = reshape(obj.fuse.diameter.Value/2*sy,[1 numel(sy)]);
                sz = reshape(obj.fuse.diameter.Value/2*sz,[1 numel(sz)]);
                nosex = sy(1:ceil(numel(sx)/2))+obj.fuse.rNose_LE.Value(1)+obj.fuse.diameter.Value/2;
                nosey = sx(1:ceil(numel(sx)/2));
                nosez = sz(1:ceil(numel(sx)/2));
%                 x(end+1:end+numel(nosex))=nosex;
%                 y(end+1:end+numel(nosey))=nosey;
%                 z(end+1:end+numel(nosez))=nosez;
                
                endx = sy(ceil(numel(sx)/2):end)+obj.fuse.rEnd_LE.Value(1)-obj.fuse.diameter.Value/2;
                endy = sx(ceil(numel(sx)/2):end);
                endz = sz(ceil(numel(sx)/2):end);
%                 x(end+1:end+numel(endx))=endx;
%                 y(end+1:end+numel(endy))=endy;
%                 z(end+1:end+numel(endz))=endz;
                
                
                h.surf{5}=plot3(h.ax,x,y,z,'LineWidth',.2,'Color','k','LineStyle','-',...
                      'DisplayName','Fluid Dynamic Surfaces');
                h.surf{6}=plot3(h.ax,nosex,nosey,nosez,'LineWidth',.2,'Color','k','LineStyle','-',...
                      'DisplayName','Fluid Dynamic Surfaces');
                h.surf{7}=plot3(h.ax,endx,endy,endz,'LineWidth',.2,'Color','k','LineStyle','-',...
                      'DisplayName','Fluid Dynamic Surfaces');
            end
                         
            if ~p.Results.Basic
                % Tether attachment points
                for ii = 1:obj.numTethers.Value
                    pts = R*obj.thrAttchPts_B(ii).posVec.Value;
                    h.thrAttchPts{ii} = plot3(h.ax,...
                        pts(1)+p.Results.Position(1),...
                        pts(2)+p.Results.Position(2),...
                        pts(3)+p.Results.Position(3),...
                        'r+','DisplayName','Tether Attachment Point');
                end
                % Turbines
                for ii = 1:obj.numTurbines.Value
                    pts = eval(sprintf('R*obj.turb%d.attachPtVec.Value',ii));
                    h.turb{ii} = plot3(h.ax,...
                        pts(1)+p.Results.Position(1),...
                        pts(2)+p.Results.Position(2),...
                        pts(3)+p.Results.Position(3),...
                        'm+','DisplayName','Turbine Attachment Point');
                end
                
                for ii = 1:4
                    pts = R*obj.fluidMomentArms.Value(:,ii);
                    h.momArms{ii} = plot3(h.ax,...
                        pts(1)+p.Results.Position(1),...
                        pts(2)+p.Results.Position(2),...
                        pts(3)+p.Results.Position(3),...
                        'b+','DisplayName','Fluid Dynamic Center');
                    
                end
                % Center of mass
                h.centOfMass = plot3(h.ax,...
                                    obj.rCM_LE.Value(1)+p.Results.Position(1),...
                                    obj.rCM_LE.Value(2)+p.Results.Position(2),...
                                    obj.rCM_LE.Value(3)+p.Results.Position(3),...
                                    'r*','DisplayName','Center of Mass');
                % Coordinate origin
                h.origin = plot3(h.ax,p.Results.Position(1),p.Results.Position(2),p.Results.Position(3),'kx','DisplayName','Body Frame Origin/Leading Edge');
                legend(h.ax,[h.surf{1} h.thrAttchPts{1} h.turb{1} h.momArms{2} h.centOfMass h.origin],'Location','northeast')
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
            ax1 = subplot(4,4,1);
            plot(obj.portWing.alpha.Value,obj.portWing.CL.Value);
            hWingCL_ax = gca;
            
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Port Wing')
            grid on
            hold on
            
            ax5 = subplot(4,4,5);
            plot(obj.portWing.alpha.Value,obj.portWing.CD.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            hWingCD_ax = gca;
            
            ax9 = subplot(4,4,9);
            plot(obj.portWing.alpha.Value,obj.portWing.CL.Value(:)./obj.portWing.CD.Value(:))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}}{C_D}$')
            grid on
            hold on
            
            ax13 = subplot(4,4,13);
            plot(obj.portWing.alpha.Value,(obj.portWing.CL.Value(:).^3)./(obj.portWing.CD.Value(:).^2))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}^3}{C_D^2}$')
            grid on
            hold on
                       
            linkaxes([ax1,ax5,ax9,ax13],'x');
            
            % right wing
            ax2 = subplot(4,4,2);
            plot(obj.stbdWing.alpha.Value,obj.stbdWing.CL.Value);
            
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Starboard Wing')
            grid on
            hold on
            
            ax6 = subplot(4,4,6);
            plot(obj.stbdWing.alpha.Value,obj.stbdWing.CD.Value);
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            ax10 = subplot(4,4,10);
            plot(obj.stbdWing.alpha.Value,obj.stbdWing.CL.Value(:)./obj.stbdWing.CD.Value(:))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}}{C_D}$')
            grid on
            hold on
            
            ax14 = subplot(4,4,14);
            plot(obj.stbdWing.alpha.Value,(obj.stbdWing.CL.Value(:).^3)./(obj.stbdWing.CD.Value(:).^2))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}^3}{C_D^2}$')
            grid on
            hold on
            
            linkaxes([ax2,ax6,ax10,ax14],'x');
            
            % HS
            ax3 = subplot(4,4,3);
            plot(obj.hStab.alpha.Value,obj.hStab.CL.Value);
            hhStabCL_ax = gca;
            
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Horizontal stabilizer')
            grid on
            hold on
            
            ax7 = subplot(4,4,7);
            plot(obj.hStab.alpha.Value,obj.hStab.CD.Value);
            hhStabCD_ax = gca;
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            ax11 = subplot(4,4,11);
            plot(obj.hStab.alpha.Value,obj.hStab.CL.Value(:)./obj.hStab.CD.Value(:))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}}{C_D}$')
            grid on
            hold on
            
            ax15 = subplot(4,4,15);
            plot(obj.hStab.alpha.Value,(obj.hStab.CL.Value(:).^3)./(obj.hStab.CD.Value(:).^3))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}^3}{C_D^2}$')
            grid on
            hold on
            
            linkaxes([ax3,ax7,ax11,ax15],'x');
            
            % VS
            ax4 = subplot(4,4,4);
            plot(obj.vStab.alpha.Value,obj.vStab.CL.Value);
            hvStabCL_ax = gca;
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{L}$')
            title('Vertical stabilizer')
            grid on
            hold on
            
            ax8 = subplot(4,4,8);
            plot(obj.vStab.alpha.Value,obj.vStab.CD.Value);
            hvStabCD_ax = gca;
            xlabel('$\alpha$ [deg]')
            ylabel('$C_{D}$')
            grid on
            hold on
            
            ax12 = subplot(4,4,12);
            plot(obj.vStab.alpha.Value,obj.vStab.CL.Value(:)./obj.vStab.CD.Value(:))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}}{C_D}$')
            grid on
            hold on
            
            ax16 = subplot(4,4,16);
            plot(obj.vStab.alpha.Value,(obj.vStab.CL.Value(:).^3)./(obj.vStab.CD.Value(:).^3))
            xlabel('$\alpha$ [deg]')
            ylabel('$\frac{C_{L}^3}{C_D^2}$')
            grid on
            hold on
            
            linkaxes([ax4,ax8,ax12,ax16],'x');
            
            %             axis([ax1 ax2 ax3 ax4],[-20 20 ...
%                 min([hWingCL_ax.YLim(1),hhStabCL_ax.YLim(1),hvStabCL_ax.YLim(1)])...
%                 max([hWingCL_ax.YLim(2),hhStabCL_ax.YLim(2),hvStabCL_ax.YLim(2)])]);
%             axis([ax5 ax6 ax7 ax8],[-20 20 ...
%                 min([hWingCD_ax.YLim(1),hhStabCD_ax.YLim(1),hvStabCD_ax.YLim(1)])...
%                 max([hWingCD_ax.YLim(2),hhStabCD_ax.YLim(2),hvStabCD_ax.YLim(2)])]);
            
        end
        
        %Get a struct of parameters of the desired class
        [output,varargout] = struct(obj,className);
        
        %returns a cell array of properties of the desired class
        output = getPropsByClass(obj,className);
               
        % calculate max equilibrium speed at a given azimuth, elevation, and
        % flow velocity vector
        [sp,tanRoll,velAng] = eqSpeed(obj,vf,az,el)
        
        % Functions to animate the vehicle
        val = animateSim(obj,tsc,timeStep,varargin)
        val = animateBody(obj,tsc,timeStep,varargin)
    end % methods
end