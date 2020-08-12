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
        vstabAeroCenter;
        vstabChord;
        vstabAspectRatio;
        vstabOswaldEff = 0.8;
        vstabZeroAoALift = 0.0;
        vstabZerAoADrag = 0.01;
        vstabControlSensitivity = 0;
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
        
        % tangent to body frame rotation matrix
        function BcT = makeTangentToBodyFrameRotMat(obj,heading,tgtPitch,roll)
            BcT = obj.Rx(roll)*obj.Ry(tgtPitch)*obj.Rz(heading);
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
        
    end
    
    %% methods for position, buoyancy loads, etc. calculation
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
        function val = calcTetherLoads(obj,G_vFlow,T_vKite,azimuth,elevation,...
                heading,tgtPitch,roll,elevatorDef)
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
        end
        
        % derivation
        function val = testDeriv(~)
            val = 0;
            
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
            dynPressure = 0.5*rho*norm(B_vApp)^2;
            % loads
            val.drag = dynPressure*CD*sVstab*uDrag;
            val.lift = dynPressure*CL*sVstab*uLift;
            val.force = val.drag + val.lift;
            val.moment = cross(rVstab,val.force);
        end
    end
    
    %% methods related to the path
    methods
        % get parameterized eqn for path co-ordinates & path tangent vectors
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
        
        % get parameterized eqn for radius of curvate over the path
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
            scale = obj.tetherLength/10;
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
            scale = obj.tetherLength/10;
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
            lwd = 0.5;
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
                plot3(X,Y,Z,lnType,'linewidth',lwd,'color',grayRGB);
                hold on;
            end
            % plot latitude lines
            for ii = 1:numel(latCoarse)
                X = r*cosd(longFine).*cosd(latCoarse(ii));
                Y = r*sind(longFine).*cosd(latCoarse(ii));
                Z = r*sind(latCoarse(ii))*ones(size(longFine));
                plot3(X,Y,Z,lnType,'linewidth',lwd,'color',grayRGB);
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
            
            function plotCL(AoA,CL)
                plot(AoA,CL,'k-','linewidth',1);
                grid on; hold on;
                xlabel('$\alpha$ (deg)'); xlabel('$C_{L,wing}$ (deg)');
            end
            function plotCD(AoA,CD)
                plot(AoA,CD,'k-','linewidth',1);
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
            scale = obj.tetherLength/10;
            % quiver plot it
            val = quiver3(pointLoc(1),pointLoc(2),pointLoc(3),...
                tanVec(1),tanVec(2),tanVec(3),scale,...
                'MaxHeadSize',0.6,...
                'color',[255,127,0]/255,...
                'linewidth',lineWidth);
        end
        
        % plot radius of curvature
        function val = plotRadiusOfCurvature(obj)
            % local variable
            pathParam = linspace(0,2*pi,300);
            % calculate radius of curvature
            R = obj.radiusOfCurvatureEq(pathParam);
            % plot
            pathParam = pathParam./(2*pi);
            val = plot(pathParam,R,'k-','linewidth',1);
            xlabel('Path parameter');
            ylabel('R (m)');
            grid on;
            hold on;
            xticks(0:.25:1);
        end
        
        % plot heading angle over the path
        function val = plotRequiredHeadingAngle(obj)
            % local variable
            pathParam = linspace(0,2*pi,300);
            % calculate radius of curvature
            headingAng = obj.pathAndTangentEqs.reqHeading(pathParam);
            headingAng = wrapTo2Pi(headingAng);
            % plot
            pathParam = pathParam./(2*pi);
            val = plot(pathParam,headingAng*180/pi,'k-','linewidth',1);
            xlabel('Path parameter');
            ylabel('Heading angle (deg)');
            grid on;
            hold on;
            xticks(0:.25:1);
            yticks(0:60:360);
        end            
    end
    
    %% animation methods
    methods
        function makeFancyAnimation(obj,doAnimate,pathParam)
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
            obj.plotRadiusOfCurvature;
            rC = obj.radiusOfCurvatureEq(pathParam);
            % make the static heading angle plot
            subplot(3,4,haIdx);
            obj.plotRequiredHeadingAngle;
            hAng = obj.pathAndTangentEqs.reqHeading(pathParam);
            hAng = wrapTo2Pi(hAng);
            % check if animation is wanted
            if doAnimate
                delete(pTanVec);
                pathParam = pathParam./(2*pi);
                for ii = 1:numel(pathParam)
                    % tangent vector
                    subplot(3,4,mainPlot);
                    if ii > 1
                        delete(pTanVec);
                        delete(pRadCur);
                        delete(pHeadAng);
                    end
                    pTanVec = obj.plotTangentVec(pathParam(ii)*2*pi);
                    title(sprintf('$s = %0.2f$',pathParam(ii)));
                    % radius of curvature
                    subplot(3,4,rcIdx);
                    pRadCur = plot(pathParam(ii),rC(ii),'mo');
                    % heading angle
                    subplot(3,4,haIdx);
                    pHeadAng = plot(pathParam(ii),hAng(ii)*180/pi,'mo');
                    % wait
                    waitforbuttonpress;
                end
                
            end
        end
        
    end
    
end

