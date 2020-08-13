classdef maneuverabilityAdvanced
    
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties % generic
        aBooth
        bBooth
        tetherLength
        meanElevationInRadians
        EllipticalWidth = 2*pi/4;
        EllipticalHeight = 0.6*2*pi/4;
    end
    
    properties % mass properties
        buoyFactor;
        mass;
        centerOfBuoy;
        bridleLocation;
    end
    
    properties %wing
        wingAeroCenter;
        wingChord;
        wingAspectRatio;
        wingOswaldEff = 0.8;
        wingZeroAoALift = 0.1;
        wingZerAoADrag = 0.01;
    end
    
    properties % hstab
        hstabAeroCenter;
        hstabChord;
        hstabAspectRatio;
        hstabOswaldEff = 0.8;
        hstabZeroAoALift = 0.0;
        hstabZerAoADrag = 0.01;
        hstabControlSensitivity;
    end
    
    properties % vstab
        vStabOn = true;
        vstabAeroCenter;
        vstabChord;
        vstabAspectRatio;
        vstabOswaldEff = 0.8;
        vstabZeroAoALift = 0.0;
        vstabZerAoADrag = 0.01;
        vstabControlSensitivity = 0;
        vstabMaxDef = 30;
    end
    
    properties (Dependent = true)
        wingArea;
        hstabArea;
        vstabArea;
    end
    
    properties (Dependent = true) % path related equations
        pathAndTangentEqs;
        radiusOfCurvatureEq;
    end
    
    properties (Constant = true)
        fluidDensity = 1e3;
        gravAcceleration = 9.81;
    end
    
    properties (SetAccess = private) % plot properties
        lwd = 1.0;
        linStyleOrder = {'-','--',':o',};
        colorOrder = [228,26,28
            55,126,184
            77,175,74
            152,78,16]./255;
    end
    
    %% getters
    methods
        % wing area
        function val = get.wingArea(obj)
            val = obj.wingChord^2*obj.wingAspectRatio;
        end
        
        % h-stab area
        function val = get.hstabArea(obj)
            val = obj.hstabChord^2*obj.hstabAspectRatio;
        end
        
        % v-stab area
        function val = get.vstabArea(obj)
            val = obj.vstabChord^2*obj.vstabAspectRatio/2;
        end
        
        % parameterized eqn for path co-ordinates & path tangent vectors
        function val = get.pathAndTangentEqs(obj)
            % local variables
            r    = obj.tetherLength;
            elev = obj.meanElevationInRadians;
            a    = obj.aBooth;
            b    = obj.bBooth;
            % make symbolic path parameter
            syms s
            % equations for path longitude and latitude
            pathAzimuth = (a*sin(s))./...
                (1 + ((a/b)^2).*(cos(s).^2));
            pathElevation = (((a/b)^2)*sin(s).*cos(s))./...
                (1 + ((a/b)^2).*(cos(s).^2));
            pathElevation = pathElevation + elev;
            % x,y,and z coordinates in inertial frame
            G_path = r*[cos(pathAzimuth).*cos(pathElevation);
                sin(pathAzimuth).*cos(pathElevation);
                sin(pathElevation)];
            % differentiate wrt s to get path tangent vector
            G_pathTgt = diff(G_path,s);
            % rotate path tangent vector to tangent frame
            TcG = obj.makeGroundToTangentialFrameRotMat(pathAzimuth,...
                pathElevation);
            T_pathTgt = TcG*G_pathTgt;
            % calculate heading angle required in the tangent frame
            reqHeading = atan2(T_pathTgt(2),T_pathTgt(1));
            % output
            val.AzimAndElev  = matlabFunction([pathAzimuth;pathElevation]);
            val.PathCoords   = matlabFunction(G_path);
            val.PathTangents = matlabFunction(G_pathTgt);
            val.reqHeading   = matlabFunction(reqHeading);
        end
        
        % parameterized eqn for radius of curvate over the path
        function val = get.radiusOfCurvatureEq(obj)
            % symbolic
            syms pathParm
            a = obj.aBooth;
            b = obj.bBooth;
            r = obj.tetherLength;
            % logitutude equation
            pathLong = (a*sin(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
            % latitude equation equation
            pathLat = (((a/b)^2)*sin(pathParm).*cos(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
            pathLat = pathLat + obj.meanElevationInRadians;
            % get lemniscate coordinates
            lemX = r*cos(pathLong).*cos(pathLat);
            lemY = r*sin(pathLong).*cos(pathLat);
            lemZ = r*sin(pathLat);
            % first derivative
            dx = diff(lemX,pathParm);
            dy = diff(lemY,pathParm);
            dz = diff(lemZ,pathParm);
            % second derivative
            ddx = diff(dx,pathParm);
            ddy = diff(dy,pathParm);
            ddz = diff(dz,pathParm);
            % curvature numerator
            Knum = sqrt((ddz*dy - ddy*dz)^2 + (ddx*dz - ddz*dx)^2 + (ddy*dx - ddx*dy)^2);
            % curvature denominator
            Kden = (dx^2 + dy^2 + dz^2)^1.5;
            % radius of curvature = 1/curvate
            val = matlabFunction(Kden/Knum);
        end
    end
    
    %% private methods. Rotations and such
    methods (Access = private)
        % rotation about x axis
        function val = Rx(~,x)
            val = [1 0 0; 0 cos(x) sin(x); 0 -sin(x) cos(x)];
        end
        
        % rotatioin about y axis
        function val = Ry(~,x)
            val = [cos(x) 0 -sin(x); 0 1 0; sin(x) 0 cos(x)];
        end
        
        % rotation about z axis
        function val = Rz(~,x)
            val = [cos(x) sin(x) 0; -sin(x) cos(x) 0; 0 0 1];
        end
        
        % ground to tangential frame rotation
        function TcG = makeGroundToTangentialFrameRotMat(obj,azimuth,elevation)
            TcG = obj.Ry(-elevation)*obj.Rx(azimuth)*obj.Ry(-pi/2);
        end
        
        % tangent to heading frame rotation
        function HcT = makeTangentToHeadingFrameRotMat(obj,heading)
            HcT = obj.Rz(heading);
        end
        
        % heading to body frame rotation
        function BcH = makeHeadingToBodyFrameRotMat(obj,tgtPitch,roll)
            BcH = obj.Rx(roll)*obj.Ry(tgtPitch);
        end
        
        % tangent to body frame rotation matrix
        function BcT = makeTangentToBodyFrameRotMat(obj,heading,tgtPitch,roll)
            BcT = obj.makeHeadingToBodyFrameRotMat(tgtPitch,roll)*...
                obj.makeTangentToHeadingFrameRotMat(heading);
        end
        
        % ground to body frame totation matrix
        function BcG = makeGroundToBodyFrameRotMat(obj,azimuth,elevation,...
                heading,tgtPitch,roll)
            % local variables
            TcG = obj.makeGroundToTangentialFrameRotMat(azimuth,elevation);
            BcT = obj.makeTangentToBodyFrameRotMat(heading,tgtPitch,roll);
            % output
            BcG = BcT*TcG;
        end
        
        function val =  plot2D(obj,x,y,varargin)
            val = plot(x,y,varargin{:});
            hold on;
            % set color order and line style order
            set(gca,'ColorOrder', obj.colorOrder);
            set(gca,'LineStyleOrder',obj.linStyleOrder);
        end
        
    end
    
    %% methods for position, buoyancy loads, tether loads, etc. calculation
    methods
        % calculate inertial position given polar co-ordinates
        function val = calcInertialPosition(obj,azimuth,elevation)
            % local variable
            TcG = obj.makeGroundToTangentialFrameRotMat(azimuth,elevation);
            val = transpose(TcG)*[0;0;-obj.tetherLength];
        end
        
        % calculate buoyancy force in body frame
        function val = calcBuoyLoads(obj,azimuth,elevation,...
                heading,tgtPitch,roll)
            % local variables
            BF  = obj.buoyFactor;
            m   = obj.mass;
            g   = obj.gravAcceleration;
            rCB = obj.centerOfBuoy;
            % ground to body rotation
            BcG = obj.makeGroundToBodyFrameRotMat(azimuth,elevation,...
                heading,tgtPitch,roll);
            % buoyancy force in ground frame
            G_Fbuoy = BF*m*g*[0;0;1];
            % rotate to body frame
            val.force = BcG*G_Fbuoy;
            val.moment = cross(rCB,val.force);
        end
        
        % calculate gravity force in body frame
        function val = calcGravForce(obj,azimuth,elevation,...
                heading,tgtPitch,roll)
            % local variables
            m   = obj.mass;
            g   = obj.gravAcceleration;
            % ground to body rotation
            BcG = obj.makeGroundToBodyFrameRotMat(azimuth,elevation,...
                heading,tgtPitch,roll);
            % buoyancy force in ground frame
            G_Fgrav = m*g*[0;0;-1];
            % rotate to body frame
            val = BcG*G_Fgrav;
        end
        
        % calculate tether force and moment
        function [val,allLoads] = calcTetherLoads(obj,G_vFlow,T_vKite,...
                azimuth,elevation,heading,tgtPitch,roll,elevatorDef)
            % local variable
            rThr = obj.bridleLocation;
            % calculate buoyancy loads
            buoyLoads = obj.calcBuoyLoads(azimuth,elevation,heading,...
                tgtPitch,roll);
            B_Fbuoy = buoyLoads.force;
            % calculate gravity force
            B_Fgrav = obj.calcGravForce(azimuth,elevation,heading,...
                tgtPitch,roll);
            % calculate apparent velocity
            B_vApp = obj.calcApparentVelInBodyFrame(G_vFlow,T_vKite,...
                azimuth,elevation,heading,tgtPitch,roll);
            % calculate wing loads
            wingLoads = obj.calcWingLoads(B_vApp);
            B_Fwing = wingLoads.force;
            % calculate h-stab loads
            hstabLoads = obj.calchStabLoads(B_vApp,elevatorDef);
            B_Fhstab = hstabLoads.force;
            % calculate v-stab loads
            vstabLoads = obj.calcvStabLoads(B_vApp);
            B_Fvstab = vstabLoads.force;
            % sum the forces
            B_Fsum = B_Fbuoy + B_Fgrav + B_Fwing + B_Fhstab + B_Fvstab;
            % rotate to tangent (North-East-Down) frame
            BcT = obj.makeTangentToBodyFrameRotMat(heading,tgtPitch,roll);
            TcB = transpose(BcT);
            T_Fsum = TcB*B_Fsum;
            % make tether tension equal to -ve of forces in the z direction
            thrTension = -T_Fsum(3);
            % make tether force vector (tension points in Down direction)
            T_Fthr = [0;0;thrTension];
            % rotate to body frame and output
            val.force = BcT*T_Fthr;
            val.moment = cross(rThr,val.force);
            % output all loads
            allLoads.wingLoads  = wingLoads;
            allLoads.hstabLoads = hstabLoads;
            allLoads.vstabLoads = vstabLoads;
            allLoads.buoyLoads  = buoyLoads;
            allLoads.B_Fgrav    = B_Fgrav;
        end
        
        
    end
    
    %% fluid dynamics related methods
    methods
        % calculate apparent velocity in the body frame
        function val = calcApparentVelInBodyFrame(obj,...
                G_vFlow,T_vKite,azimuth,elevation,heading,tgtPitch,roll)
            % rotation matrix from ground to body
            BcG = obj.makeGroundToBodyFrameRotMat(azimuth,elevation,...
                heading,tgtPitch,roll);
            % rotation matrix from tangent to body frame
            BcT = obj.makeTangentToBodyFrameRotMat(heading,tgtPitch,roll);
            % flow velocity in body frame
            B_vFlow = BcG*G_vFlow;
            % kite velocity in body frame
            B_vKite = BcT*T_vKite;
            % apparent velocity
            val = B_vFlow - B_vKite;
        end
        
        % calculate angle of attack and side-slip angle
        function val = calcAngleOfAttackInRadians(~,B_vApp)
            val = atan2(-B_vApp(3),-B_vApp(1));
        end
        
        % calculate side slip angle
        function val = calcSideSlipAngleInRadians(~,B_vApp)
            val = atan2(B_vApp(2),sqrt(B_vApp(1)^2 + B_vApp(3)^2));
        end
        
        % calculate drag direction
        function val = calcDragDirection(~,B_vApp)
            val = B_vApp./(max(norm(B_vApp),eps));
        end
        
        % calculate horizontal surface lift direction
        function val = calcHsurfLiftDirection(obj,B_vApp)
            % local variables
            uD = obj.calcDragDirection(B_vApp);
            % output
            val = cross(uD,[0;1;0]);
        end
        
        % calculate v-Stab lift direction
        function val = calcVstabLiftDirection(obj,B_vApp)
            % local variables
            uD = obj.calcDragDirection(B_vApp);
            % output
            val = cross(uD,[0;0;1]);
        end
        
        % calculate aerodynamic coefficeints
        function [CL,CD] = calcFluidCoeffs(~,AoA,oswaldEff,aspectRatio,...
                ZeroAoALift,ZeroAoADrag,dCL_dCS,csDeflection)
            % lift curve slope
            liftSlope = 2*pi/(1 + (2*pi/(pi*oswaldEff*aspectRatio)));
            % lift coeff
            switch nargin
                case 8
                    CL = liftSlope*AoA + ZeroAoALift + dCL_dCS*csDeflection;
                case 6
                    CL = liftSlope*AoA + ZeroAoALift;
            end
            % drag coeff
            CD = ZeroAoADrag + CL^2/(pi*oswaldEff*aspectRatio);
        end
        
        % calcualte wing forces and moment
        function val = calcWingLoads(obj,B_vApp)
            % local variables
            rWing = obj.wingAeroCenter;
            sWing = obj.wingArea;
            rho   = obj.fluidDensity;
            eWing = obj.wingOswaldEff;
            AR    = obj.wingAspectRatio;
            CL0   = obj.wingZeroAoALift;
            CD0   = obj.wingZerAoADrag;
            % lift and drag directions
            uDrag = obj.calcDragDirection(B_vApp);
            uLift = obj.calcHsurfLiftDirection(B_vApp);
            % angle of attack
            AoA = obj.calcAngleOfAttackInRadians(B_vApp);
            % get coefficients
            [CL,CD] = obj.calcFluidCoeffs(AoA,eWing,AR,CL0,CD0);
            % dynamic pressure
            dynPressure = 0.5*rho*norm(B_vApp)^2;
            % loads
            val.drag = dynPressure*CD*sWing*uDrag;
            val.lift = dynPressure*CL*sWing*uLift;
            val.force = val.drag + val.lift;
            val.moment = cross(rWing,val.force);
        end
        
        % calcualte hstab forces and moment (some code reuse, not proud of it)
        function val = calchStabLoads(obj,B_vApp,elevatorDef)
            % local variables
            rHstab = obj.hstabAeroCenter;
            sHstab = obj.hstabArea;
            rho    = obj.fluidDensity;
            eHstab = obj.hstabOswaldEff;
            AR     = obj.hstabAspectRatio;
            CL0    = obj.hstabZeroAoALift;
            CD0    = obj.hstabZerAoADrag;
            dCL_dCS = obj.hstabControlSensitivity;
            dCS = elevatorDef;
            % lift and drag directions
            uDrag = obj.calcDragDirection(B_vApp);
            uLift = obj.calcHsurfLiftDirection(B_vApp);
            % angle of attack
            AoA = obj.calcAngleOfAttackInRadians(B_vApp);
            % get coefficients
            [CL,CD] = obj.calcFluidCoeffs(AoA,eHstab,AR,CL0,CD0,dCL_dCS,dCS);
            % dynamic pressure
            dynPressure = 0.5*rho*norm(B_vApp)^2;
            % loads
            val.drag = dynPressure*CD*sHstab*uDrag;
            val.lift = dynPressure*CL*sHstab*uLift;
            val.force = val.drag + val.lift;
            val.moment = cross(rHstab,val.force);
        end
        
        % calcualte vstab forces and moment (some code reuse, not proud of it)
        function val = calcvStabLoads(obj,B_vApp,rudderDef)
            % local variables
            rho     = obj.fluidDensity;
            rVstab  = obj.vstabAeroCenter;
            sVstab  = obj.vstabArea;
            eVstab  = obj.vstabOswaldEff;
            AR      = obj.vstabAspectRatio;
            CL0     = obj.vstabZeroAoALift;
            CD0     = obj.vstabZerAoADrag;
            % lift and drag directions
            uDrag = obj.calcDragDirection(B_vApp);
            uLift = obj.calcVstabLiftDirection(B_vApp);
            % angle of attack
            SSA = obj.calcSideSlipAngleInRadians(B_vApp);
            % get coefficients
            switch nargin
                case 3
                    dCL_dCS = obj.vstabControlSensitivity;
                    dCS = rudderDef;
                    [CL,CD] = obj.calcFluidCoeffs(SSA,eVstab,AR,CL0,CD0,...
                        dCL_dCS,dCS);
                case 2
                    [CL,CD] = obj.calcFluidCoeffs(SSA,eVstab,AR,CL0,CD0);
            end
            % dynamic pressure
            dynPressure = obj.vStabOn*0.5*rho*norm(B_vApp)^2;
            % loads
            val.drag = dynPressure*CD*sVstab*uDrag;
            val.lift = dynPressure*CL*sVstab*uLift;
            val.force = val.drag + val.lift;
            val.moment = cross(rVstab,val.force);
        end
    end
    
    %% control methods
    methods
        
        % calculate kite velocity in tangent frame given heading speed
        function T_vKite = calcKiteVelInTangentFrame(obj,H_vKite,heading)
            % output
            T_vKite = NaN(3,numel(heading));
            for ii = 1:numel(heading)
                HcT = obj.makeTangentToHeadingFrameRotMat(heading(ii));
                T_vKite(:,ii) = transpose(HcT)*H_vKite;
            end
        end
        
        % calculate required centripetal force over the path
        function val = calcRequiredCentripetalForce(obj,H_vKite,pathParam)
            % get radius of curvature over the path
            pathRcurve = obj.radiusOfCurvatureEq(pathParam);
            % calculate centripetal force required
            val = obj.mass*H_vKite(1)^2./pathRcurve;
            % correct direction
            val(pathParam>=pi) = -1*val(pathParam>=pi);
        end
        
        function val = calcRequiredRoll(obj,G_vFlow,H_vKite,pathParam,varargin)
            % number of points on path
            nPoints = numel(pathParam);
            % parse input
            pp = inputParser;
            addParameter(pp,'tgtPitch',0*pathParam,@isnumeric);
            addParameter(pp,'elevatorDef',0*pathParam,@isnumeric);
            parse(pp,varargin{:});
            % local variables
            tgtPitch = pp.Results.tgtPitch;
            % % dElevator = pp.Results.elevatorDef;
            % get path azimuth and elevation
            pathAzimElev = obj.pathAndTangentEqs.AzimAndElev(pathParam);
            azim = pathAzimElev(1,:);
            elev = pathAzimElev(2,:);
            % get path heading angle
            pathHeading = obj.pathAndTangentEqs.reqHeading(pathParam);
            % calculate required centripetal force to stay on path
            reqFcentripetal = obj.calcRequiredCentripetalForce(H_vKite,...
                pathParam);
            % preallocation
            val = pathParam*nan;
            % kite velocity in tangent frame along the path
            T_vKite = obj.calcKiteVelInTangentFrame(H_vKite,pathHeading);
            % find wing roll angle that cancels the centripetal force
            for ii = 1:nPoints
                if ii == 1
                    x0 = 0;         % initial roll angle guess
                else
                    x0 = val(ii-1);
                end
                val(ii) = fzero(@(roll) ...
                    obj.calcDifferenceInCentripetalForces(reqFcentripetal(ii),...
                    G_vFlow,T_vKite(:,ii),azim(ii),elev(ii),...
                    pathHeading(ii),tgtPitch(ii),roll),x0);
            end
        end
        
        function val = calcDifferenceInCentripetalForces(obj,Fcent,...
                G_vFlow,T_vKite,azimuth,elevation,heading,tgtPitch,roll)
            % calculate wing loads
            B_vApp = obj.calcApparentVelInBodyFrame(...
                G_vFlow,T_vKite,azimuth,elevation,heading,tgtPitch,roll);
            wingLoads = obj.calcWingLoads(B_vApp);
            % rotate wing lift to the heading frame
            BcH = obj.makeHeadingToBodyFrameRotMat(tgtPitch,roll);
            H_wingLift = transpose(BcH)*wingLoads.lift;
            % get the differnce between its y component and centripetal
            % force
            val = Fcent - H_wingLift(2);
        end
    end
    
    %% pitch stability methods
    methods
        % calculate elevator deflection to trim
        function [val,allMoments] = calcElevatorDefForTrim(obj,G_vFlow,T_vKite,...
                azimuth,elevation,heading,tgtPitch,roll)
            % define symbolic
            syms de
            % calculate all loads
            [thrLoads,allLoads] = obj.calcTetherLoads(G_vFlow,T_vKite,...
                azimuth,elevation,heading,tgtPitch,roll,de);
            % extract moments
            B_Mwing  = allLoads.wingLoads.moment;
            B_Mhstab = allLoads.hstabLoads.moment;
            B_Mvstab = allLoads.vstabLoads.moment;
            B_Mbuoy  = allLoads.buoyLoads.moment;
            B_Mthr   = thrLoads.moment;
            % get sum of moments
            B_Msum = B_Mwing + B_Mhstab + B_Mvstab + B_Mbuoy + B_Mthr;
            % solve
            val = solve(B_Msum(2) == 0,de,'Real',true);
            val = min(abs(val));
            % output all moments
            allMoments.B_Mwing  = B_Mwing;
            allMoments.B_Mhstab = B_Mhstab;
            allMoments.B_Mvstab = B_Mvstab;
            allMoments.B_Mbuoy  = B_Mbuoy;
            allMoments.B_Mthr   = B_Mthr;
            allMoments.B_Msum   = B_Msum;
            
        end
        
        % loop throught tangent pitch angles and get moments and other
        % things
        function val = pitchStabilityAnalysis(obj,G_vFlow,T_vKite,...
                azimuth,elevation,heading,tgtPitch,roll,dElev)
            % number of points
            nPoints = numel(tgtPitch);
            % preallocate matrices
            AoA      = NaN(1,nPoints);
            SSA      = NaN(1,nPoints);
            de       = NaN(1,nPoints);
            B_Mwing  = NaN(3,nPoints);
            B_Mhstab = NaN(3,nPoints);
            B_Mvstab = NaN(3,nPoints);
            B_Mbuoy  = NaN(3,nPoints);
            B_Mthr   = NaN(3,nPoints);
            B_Msum   = NaN(3,nPoints);
            % run the loop
            for ii = 1:nPoints
                % apparent wind velocity
                B_vApp = obj.calcApparentVelInBodyFrame(G_vFlow,T_vKite,...
                    azimuth,elevation,heading,tgtPitch(ii),roll);
                % angle of attack and sideslip angle
                AoA(ii) = obj.calcAngleOfAttackInRadians(B_vApp)*180/pi;
                SSA(ii) = obj.calcSideSlipAngleInRadians(B_vApp)*180/pi;
                % calculate required elevator deflection
                [de(ii),allMoments] = obj.calcElevatorDefForTrim(G_vFlow,...
                    T_vKite,azimuth,elevation,heading,tgtPitch(ii),roll);
                % store all moments
                B_Mwing(:,ii)  = allMoments.B_Mwing;
                B_Mhstab(:,ii) = subs(allMoments.B_Mhstab,dElev);
                B_Mvstab(:,ii) = allMoments.B_Mvstab;
                B_Mbuoy(:,ii)  = allMoments.B_Mbuoy;
                B_Mthr(:,ii)   = subs(allMoments.B_Mthr,dElev);
                B_Msum(:,ii)   = subs(allMoments.B_Msum,dElev);
            end
            % output
            val.AoA         = AoA;
            val.SSA         = SSA;
            val.elevatorDef = de;
            val.B_Mwing     = B_Mwing;
            val.B_Mhstab    = B_Mhstab;
            val.B_Mvstab    = B_Mvstab;
            val.B_Mbuoy     = B_Mbuoy;
            val.B_Mthr      = B_Mthr;
            val.B_Msum      = B_Msum;
        end
        
        function val = plotPitchStabilityAnalysisResults(obj,G_vFlow,T_vKite,...
                azimuth,elevation,heading,tgtPitch,roll,dElev)
            % initialize graphics object matrix
            val = gobjects;
            spAxes = gobjects;
            % results from the analysis
            res = obj.pitchStabilityAnalysis(G_vFlow,T_vKite,...
                azimuth,elevation,heading,tgtPitch,roll,dElev);
            fprintf('Done calculating.\n');
            % normalizing Moment
            normM = 1e3;
            % local variables
            noSp = [2,5]; % number of subplots
            pIdx = 1;    % plot index
            spIdx = 1;   % subplot index
            tgtPitch = tgtPitch*180/pi;
            % plot buoyancy pitching moments
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(tgtPitch,res.B_Mbuoy(2,:)./normM);
            grid on; hold on;
            xlabel('Tangent pitch (deg)');
            ylabel('Buoyancy moment (kN-m)');
            % plot wing pitching moments
            pIdx = pIdx+1; spIdx = spIdx + 1;
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(tgtPitch,res.B_Mwing(2,:)./normM);
            grid on; hold on;
            xlabel('Tangent pitch (deg)');
            ylabel('Wing moment (kN-m)');
            % plot H-stab pitching moments
            pIdx = pIdx+1; spIdx = spIdx + 1;
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(tgtPitch,res.B_Mhstab(2,:)./normM);
            grid on; hold on;
            xlabel('Tangent pitch (deg)');
            ylabel('H-stab moment (kN-m)');
            % plot tether pitching moments
            pIdx = pIdx+1; spIdx = spIdx + 1;
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(tgtPitch,res.B_Mthr(2,:)./normM);
            grid on; hold on;
            xlabel('Tangent pitch (deg)');
            ylabel('Tether moment (kN-m)');
            % plot sum of pitching moments
            pIdx = pIdx+1; spIdx = spIdx + 1;
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(tgtPitch,res.B_Msum(2,:)./normM);
            grid on; hold on;
            xlabel('Tangent pitch (deg)');
            ylabel('Sum of moments (kN-m)');
            % plot angle of attack
            pIdx = pIdx+1; spIdx = spIdx + 1;
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(tgtPitch,res.AoA);
            grid on; hold on;
            xlabel('Tangent pitch (deg)');
            ylabel('AoA (deg)');
            % plot elevator deflection to trim
            pIdx = pIdx+1; spIdx = spIdx + 1;
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(tgtPitch,res.elevatorDef);
            grid on; hold on;
            xlabel('Tangent pitch (deg)');
            ylabel('Elevator deflection to trim (deg)');
            pIdx = pIdx+1;
            val(pIdx) = yline(obj.vstabMaxDef,'r-','linewidth',obj.lwd);
            pIdx = pIdx+1;
            val(pIdx) = yline(-obj.vstabMaxDef,'r-','linewidth',obj.lwd);
            % plot AoA of attack vs sum of moments
            pIdx = pIdx+1; spIdx = spIdx + 1;
            spAxes(spIdx) = subplot(noSp(1),noSp(2),spIdx);
            val(pIdx) = obj.plot2D(res.AoA,res.B_Msum(2,:)./normM);
            grid on; hold on;
            xlabel('AoA (deg)');
            ylabel('Sum of moments (kN-m)');
            % link the axes of the first row
            linkaxes(spAxes(1:5),'y');
            % main title
            sgtitle(sprintf(['Azimuth = %.1f, Elevation = %.1f, Heading = %.1f, ',...
                'Roll = %.1f'],[azimuth,elevation,...
                heading,roll]*180/pi));
            % plot the dome and shit
            spIdx = spIdx + 1;
            subplot(noSp(1),noSp(2),[spIdx, spIdx+1]);
            cla;
            obj.plotDome;
            obj.plotLemniscate;
            obj.plotBodyFrameAxes(azimuth,elevation,heading,0,roll);
            view(100,35);
            axis equal;
        end
    end
      
    %% plotting methods
    methods
        % plot body frame axes
        function val =  plotBodyFrameAxes(obj,azimuth,elevation,...
                heading,tgtPitch,roll)
            % body to ground rotation matrix
            BcG = obj.makeGroundToBodyFrameRotMat(azimuth,elevation,...
                heading,tgtPitch,roll);
            GcB = transpose(BcG);
            % kite position
            rCM = obj.calcInertialPosition(azimuth,elevation);
            % get body frame x,y,and z in the ground frame
            G_axisB = GcB*eye(3);
            % plot options
            rgbColors = 1/255*[228,26,28        % red
                77,175,74                       % green
                55,126,184];                    % blue
            lineWidth = 0.8;
            scale = obj.tetherLength*0.1;
            % plot
            val = gobjects(3);
            for ii = 1:3
                val(ii) = quiver3(rCM(1),rCM(2),rCM(3),...
                    G_axisB(1,ii),G_axisB(2,ii),G_axisB(3,ii),scale,...
                    'MaxHeadSize',0.6,...
                    'color',rgbColors(ii,:),...
                    'linewidth',lineWidth);
                hold on
            end
        end
        
        % plot flow and kite velocity vectors
        function val = plotVelocities(obj,G_vFlow,T_vKite,azimuth,elevation)
            % rotation matrix from tangent to body frame
            TcG = obj.makeGroundToTangentialFrameRotMat(azimuth,elevation);
            GcT = transpose(TcG);
            % get velocities in ground frame
            G_vKite = GcT*T_vKite;
            % concatenate vectors for easy plotting
            catVec = [G_vFlow G_vKite];
            % kite position
            rCM = obj.calcInertialPosition(azimuth,elevation);
            % plot options
            lineWidth = 0.8;
            scale = obj.tetherLength*0.1;
            % plot flow velocity
            val = gobjects(2);
            for ii = 1:2
                val(ii) = quiver3(rCM(1),rCM(2),rCM(3),...
                    catVec(1,ii),catVec(2,ii),catVec(3,ii),scale,...
                    'MaxHeadSize',0.6,...
                    'color','k',...
                    'linewidth',lineWidth);
                hold on
            end
        end
        
        % plot latitude and longitude lines
        function plotDome(obj)
            % get constants
            r = obj.tetherLength;
            linWidth = 0.5;
            lnType = ':';
            grayRGB = 128/255.*[1 1 1];
            % make longitude and latitude fine grids
            longFine = -90:1:90;
            latFine = -0:1:90;
            % make longitude and latitude coarse grids
            stepSize = 30;
            longCoarse = longFine(1):stepSize:longFine(end);
            latCoarse = latFine(1):stepSize:latFine(end);
            % plot longitude lines
            for ii = 1:numel(longCoarse)
                X = r*cosd(longCoarse(ii)).*cosd(latFine);
                Y = r*sind(longCoarse(ii)).*cosd(latFine);
                Z = r*sind(latFine);
                plot3(X,Y,Z,lnType,'linewidth',linWidth,'color',grayRGB);
                hold on;
            end
            % plot latitude lines
            for ii = 1:numel(latCoarse)
                X = r*cosd(longFine).*cosd(latCoarse(ii));
                Y = r*sind(longFine).*cosd(latCoarse(ii));
                Z = r*sind(latCoarse(ii))*ones(size(longFine));
                plot3(X,Y,Z,lnType,'linewidth',linWidth,'color',grayRGB);
            end
        end
        
        % plot wing lift and drag curves
        function plotWingCoefficients(obj,subPlotIdx)
            % local variables
            eWing = obj.wingOswaldEff;
            AR    = obj.wingAspectRatio;
            CL0   = obj.wingZeroAoALift;
            CD0   = obj.wingZerAoADrag;
            % angle of attack
            AoA = linspace(-20,20,100);
            % get coefficients
            CL = AoA*nan;
            CD = AoA*nan;
            for ii = 1:numel(AoA)
                [CL(ii),CD(ii)] = obj.calcFluidCoeffs(AoA(ii)*pi/180,eWing,...
                    AR,CL0,CD0,0,0);
            end
            
            switch nargin
                case 1
                    % CL
                    subplot(2,1,1);
                    plotCL(AoA,CL);
                    % CD
                    subplot(2,1,2)
                    plotCD(AoA,CD);
                case 2
                    subplot(subPlotIdx(1,1),subPlotIdx(1,2),subPlotIdx(1,3));
                    plotCL(AoA,CL);
                    % CD
                    subplot(subPlotIdx(2,1),subPlotIdx(2,2),subPlotIdx(2,3));
                    plotCL(AoA,CL);
            end
            
            function plotCL(obj,AoA,CL)
                obj.plot2D(AoA,CL,'linewidth',obj.lwd);
                grid on; hold on;
                xlabel('$\alpha$ (deg)'); xlabel('$C_{L,wing}$ (deg)');
            end
            function plotCD(obj,AoA,CD)
                obj.plot2D(AoA,CD,'linewidth',obj.lwd);
                grid on; hold on;
                xlabel('$\alpha$ (deg)'); xlabel('$C_{D,wing}$ (deg)');
            end
        end
        
        % plot lemniscate
        function val = plotLemniscate(obj)
            % local variable
            pathParam = linspace(0,2*pi,300);
            % get equations
            path = obj.pathAndTangentEqs.PathCoords(pathParam);
            % plot
            val = plot3(path(1,:),path(2,:),path(3,:),'k-',...
                'linewidth',1);
            xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
            grid on; hold on;
        end
        
        % plot tangent vetor
        function val = plotTangentVec(obj,pathParam)
            % get location of point on path
            pointLoc = obj.pathAndTangentEqs.PathCoords(pathParam);
            % get the tangent vector
            tanVec = obj.pathAndTangentEqs.PathTangents(pathParam);
            tanVec = tanVec./max(norm(tanVec),eps);
            % plot options
            lineWidth = 0.8;
            scale = obj.tetherLength*0.15;
            % quiver plot it
            val = quiver3(pointLoc(1),pointLoc(2),pointLoc(3),...
                tanVec(1),tanVec(2),tanVec(3),scale,...
                'MaxHeadSize',0.6,...
                'color',[255,127,0]/255,...
                'linewidth',lineWidth);
        end
        
        % plot radius of curvature
        function val = plotPathRadiusOfCurvature(obj)
            % local variable
            pathParam = linspace(0,2*pi,300);
            % calculate radius of curvature
            R = obj.radiusOfCurvatureEq(pathParam);
            % plot
            pathParam = pathParam./(2*pi);
            val = obj.plot2D(pathParam,R,'linewidth',obj.lwd);
            xlabel('Path parameter');
            ylabel('R (m)');
            grid on;
            hold on;
            xticks(0:.25:1);
        end
        
        % plot heading angle over the path
        function val = plotPathHeadingAngle(obj)
            % local variable
            pathParam = linspace(0,2*pi,300);
            % calculate radius of curvature
            headingAng = obj.pathAndTangentEqs.reqHeading(pathParam);
            headingAng = wrapTo2Pi(headingAng);
            % plot
            pathParam = pathParam./(2*pi);
            val = obj.plot2D(pathParam,headingAng*180/pi,'linewidth',obj.lwd);
            xlabel('Path parameter');
            ylabel('Heading angle (deg)');
            grid on;
            hold on;
            xticks(0:.25:1);
            yticks(0:60:360);
        end
        
        function val = plotRollAngle(obj,pathParam,rollAng)
            % plot
            pathParam = pathParam./(2*pi);
            val = obj.plot2D(pathParam,rollAng*180/pi,'linewidth',obj.lwd);
            xlabel('Path parameter');
            ylabel('Roll angle (deg)');
            grid on;
            hold on;
            xticks(0:.25:1);
        end
    end
    
    %% animation methods
    methods
        function makeFancyAnimation(obj,pathParam,varargin)
            % parse input
            pp = inputParser;
            addParameter(pp,'animate',true,@islogical);
            addParameter(pp,'addKiteTrajectory',false,@islogical);
            addParameter(pp,'tgtPitch',0*pathParam,@isnumeric);
            addParameter(pp,'rollInRad',0*pathParam,@isnumeric);
            parse(pp,varargin{:});
            % local variables
            tgtPitch = pp.Results.tgtPitch;
            roll = pp.Results.rollInRad;
            % make a 3x4 subplot grid and get plot indices
            plotIdx = NaN(4,3);
            for ii = 1:numel(plotIdx)
                plotIdx(ii) = ii;
            end
            plotIdx = plotIdx';
            % the big plot indices
            mainPlot = reshape(plotIdx(:,1:3),1,[]);
            % the radius of curvature idx
            rcIdx = plotIdx(1,4);
            % heading angle idx
            haIdx = plotIdx(2,4);
            % tangent roll angle idx
            tgIdx = plotIdx(3,4);
            % make the static 3D plot
            subplot(3,4,mainPlot);
            obj.plotDome;
            obj.plotLemniscate;
            view(100,35);
            axis equal;
            pTanVec = obj.plotTangentVec(0);
            % make the static radius of curvature plot
            subplot(3,4,rcIdx);
            obj.plotPathRadiusOfCurvature;
            rC = obj.radiusOfCurvatureEq(pathParam);
            % make the static heading angle plot
            subplot(3,4,haIdx);
            obj.plotPathHeadingAngle;
            % make required roll angle plot
            subplot(3,4,tgIdx);
            obj.plotRollAngle(pathParam,roll);
            % calculate values for azimuth,elevation, and heading
            hAng = obj.pathAndTangentEqs.reqHeading(pathParam);
            hAng = wrapTo2Pi(hAng);
            azimElev = obj.pathAndTangentEqs.AzimAndElev(pathParam);
            % check if animation is wanted
            if pp.Results.animate
                delete(pTanVec);
                pathParam = pathParam./(2*pi);
                for ii = 1:numel(pathParam)
                    % tangent vector
                    subplot(3,4,mainPlot);
                    if ii > 1
                        delete(pTanVec);
                        delete(pRadCur);
                        delete(pHeadAng);
                        delete(pAxes);
                        delete(pRollAng);
                    end
                    pTanVec = obj.plotTangentVec(pathParam(ii)*2*pi);
                    title(sprintf('s = %0.2f',pathParam(ii)));
                    % kite axes
                    if pp.Results.addKiteTrajectory
                        pAxes = obj.plotBodyFrameAxes(azimElev(1,ii),...
                            azimElev(2,ii),hAng(ii),tgtPitch(ii),roll(ii));
                    end
                    % radius of curvature
                    subplot(3,4,rcIdx);
                    pRadCur = plot(pathParam(ii),rC(ii),'mo');
                    % heading angle
                    subplot(3,4,haIdx);
                    pHeadAng = plot(pathParam(ii),hAng(ii)*180/pi,'mo');
                    % roll angle
                    subplot(3,4,tgIdx);
                    pRollAng = plot(pathParam(ii),roll(ii)*180/pi,'mo');
                    % wait
                    waitforbuttonpress;
                end
                
            end
        end
        
        function pitchStabAnalysisAnim(obj,G_vFlow,H_vKite,...
                tgtPitch,dElev,pathParam)
            % local varibales hopefully
            obj.linStyleOrder = {'-'};
            obj.colorOrder = [0 0 0];
            % get path azimuth and elevation
            pathAzimElev = obj.pathAndTangentEqs.AzimAndElev(pathParam);
            pathHeading  = obj.pathAndTangentEqs.reqHeading(pathParam);
            reqRoll      = obj.calcRequiredRoll(G_vFlow,H_vKite,pathParam);
            % kite vel in tangent frame
            T_vKite = obj.calcKiteVelInTangentFrame(H_vKite,pathHeading);
            % make the plots
            for ii = 1:numel(pathParam)
                if ii > 1
                    delete(plotArray)
                end
                plotArray = obj.plotPitchStabilityAnalysisResults(G_vFlow,T_vKite(:,ii),...
                    pathAzimElev(1,ii),pathAzimElev(2,ii),pathHeading(ii),...
                    tgtPitch,reqRoll(ii),dElev);
                subplot(2,5,9:10);
                title(sprintf('s = %.2f',pathParam(ii)));
                set(findobj('-property','FontSize'),'FontSize',11);
                waitforbuttonpress;
            end
            
        end
        
        
    end
    
end

