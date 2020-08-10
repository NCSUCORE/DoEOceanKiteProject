classdef maneuverabilityAnalysisLibrary
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        aBooth
        bBooth
        tetherLength
        meanElevationInRadians
        EllipticalWidth = 2*pi/4;
        EllipticalHeight = 0.6*2*pi/4;
    end
    
    methods
        %% derivation of radius of curvature
        function [eqx,eqy,eqK] = derive_2D_Equations(obj)
            % symbolic
            syms t
            r = obj.tetherLength;
            a = obj.aBooth;
            % x equation
            x = r*(a*(2^0.5)*cos(t))/((sin(t))^2 + 1);
            % y equation
            y = r*(a*(2^0.5)*cos(t)*sin(t))/((sin(t))^2 + 1);
            % dx/dt and dy/dt
            dx = diff(x,t);
            dy = diff(y,t);
            % d^2x/dt^2 and d^y/dt^2
            ddx = diff(dx,t);
            ddy = diff(dy,t);
            % curvature numerator
            Knum = abs(dx*ddy - dy*ddx);
            % curvature denominator
            Kden = (dx^2 + dy^2)^1.5;            
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqx = matlabFunction(x);
            eqy = matlabFunction(y);
        end
        
        function [eqX,eqY,eqK] = circular_2D_Path(obj)
            % symbolic
            syms t
            % radius
            r = obj.tetherLength;
            % x equation
            x = r*cos(t);
            % y equation
            y = r*sin(t);
            % dx/dt and dy/dt
            dx = diff(x,t);
            dy = diff(y,t);
            % d^2x/dt^2 and d^y/dt^2
            ddx = diff(dx,t);
            ddy = diff(dy,t);
            % curvature numerator
            Knum = abs(dx*ddy - dy*ddx);
            % curvature denominator
            Kden = (dx^2 + dy^2)^1.5;
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqX = matlabFunction(x);
            eqY = matlabFunction(y);
        end
        
        function [eqX,eqY,eqZ,eqK] = derive_3D_Equations(obj)
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
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqX = matlabFunction(lemX);
            eqY = matlabFunction(lemY);
            eqZ = matlabFunction(lemZ);

        end
        
        function [eqX,eqY,eqZ,eqK] = ellipticalPath(obj)
            % symbolics
            syms pathParam
            % get path width and height
            a = obj.EllipticalWidth/2;
            b = obj.EllipticalHeight/2;
            r = obj.tetherLength;
            % path longitude
            pathLong = a*cos(pathParam);
            % path latitude
            pathLat = obj.meanElevationInRadians + b*sin(pathParam);
            % path cartesian cordinates
            pathX = r*cos(pathLong).*cos(pathLat);
            pathY = r*sin(pathLong).*cos(pathLat);
            pathZ = r*sin(pathLat);
            % first derivative
            dx = diff(pathX,pathParam);
            dy = diff(pathY,pathParam);
            dz = diff(pathZ,pathParam);
            % second derivative
            ddx = diff(dx,pathParam);
            ddy = diff(dy,pathParam);
            ddz = diff(dz,pathParam);
            % curvature numerator
            Knum = sqrt((ddz*dy - ddy*dz)^2 + (ddx*dz - ddz*dx)^2 + (ddy*dx - ddx*dy)^2);
            % curvature denominator
            Kden = (dx^2 + dy^2 + dz^2)^1.5;
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqX = matlabFunction(pathX);
            eqY = matlabFunction(pathY);
            eqZ = matlabFunction(pathZ);
        end
        
        function [eqX,eqY,eqZ,eqK] = circular_3D_Path(obj)            
            % symbolics
            syms pathParam
            % get tether length
            R = obj.tetherLength;
            mE = obj.meanElevationInRadians;
            % set radius for intersecting plane
            rP = 0.9*R;
            % radius of great circle
            rG = sqrt(R^2 - rP^2);
            % make rotation matrix for tangent plane
            TcO = [cos(mE) 0 sin(mE);0 1 0;-sin(mE) 0 cos(mE)] ;
            % plane vector in tangent plane
            rP_T = [rP;0;0];
            % rotation matrix for rotating frame
            BcT = [1 0 0;0 cos(pathParam) sin(pathParam);...
                0 -sin(pathParam) cos(pathParam)];
            % rotate vector into tangent frame
            rG_T = transpose(BcT)*[0;0;-rG];
            % get great circle in the inertial frame
            rCM_O = transpose(TcO)*(rP_T + rG_T);
            % path cartesian cordinates
            pathX = rCM_O(1);
            pathY = rCM_O(2);
            pathZ = rCM_O(3);
            % first derivative
            dx = diff(pathX,pathParam);
            dy = diff(pathY,pathParam);
            dz = diff(pathZ,pathParam);
            % second derivative
            ddx = diff(dx,pathParam);
            ddy = diff(dy,pathParam);
            ddz = diff(dz,pathParam);
            % curvature numerator
            Knum = sqrt((ddz*dy - ddy*dz)^2 + (ddx*dz - ddz*dx)^2 + (ddy*dx - ddx*dy)^2);
            % curvature denominator
            Kden = (dx^2 + dy^2 + dz^2)^1.5;
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqX = matlabFunction(pathX);
            eqY = matlabFunction(pathY);
            eqZ = matlabFunction(pathZ);
        end
        
        function [eqZ,eqY,eqK] = radiusOfCurvatureFlatEarthApprox(obj)
            
            a = obj.aBooth;
            b = obj.bBooth;
            r = obj.tetherLength;
            meanElev = obj.meanElevationInRadians;
            % % % initialize symbolics
            syms azimuth elevation pathParm
            
            % logitutude/azimuth equation
            azimuth = (a*sin(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
            % latitude/elevation equation
            elevation = (((a/b)^2)*sin(pathParm).*cos(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
            elevation = elevation + meanElev;
            
            % make rotation matrix parallel to the sphere at mean elevation
            Ry = [cos(meanElev) 0 sin(meanElev);
                0 1 0;
                -sin(meanElev) 0 cos(meanElev)];
            % roate rCM from inertial to tangent frame
            rCM = Ry*[r*cos(azimuth).*cos(elevation);
                r*sin(azimuth).*cos(elevation);
                r*sin(elevation)];
            % get rid of the x component to get the projected path
            yProj = rCM(2);
            zProj = rCM(3);
            % get first derivatives of the simplified x and y equations
            dy = diff(yProj,pathParm);
            dz = diff(zProj,pathParm);
            % get second derivative
            ddy = diff(dy,pathParm);
            ddz = diff(dz,pathParm);
            % curvature numerator
            Knum = abs(dz*ddy - dy*ddz);
            % curvature denominator
            Kden = (dz^2 + dy^2)^1.5;
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqY = matlabFunction(yProj);
            eqZ = matlabFunction(zProj);
        end
        
        function [lemniscate,polarCoord] = getLemniScateCoordinates(...
                obj,pathParam)
            % local variables
            tetLength = obj.tetherLength;
            meanElev = obj.meanElevationInRadians;
            a = obj.aBooth;
            b = obj.bBooth;
            % equations for path longitude and latitude
            pathLong = (a*sin(pathParam))./...
                (1 + ((a/b)^2).*(cos(pathParam).^2));
            pathLat = (((a/b)^2)*sin(pathParam).*cos(pathParam))./...
                (1 + ((a/b)^2).*(cos(pathParam).^2));
            pathLat = pathLat + meanElev;
            % x,y,and z coordinates
            lemniscate.lemX = tetLength*cos(pathLong).*cos(pathLat);
            lemniscate.lemY = tetLength*sin(pathLong).*cos(pathLat);
            lemniscate.lemZ = tetLength*sin(pathLat);
            % polar cooridnates
            polarCoord.azimuth = pathLong;
            polarCoord.elevation = pathLat;
            
        end
        
        function val = analyseFlatEarthRes(obj,pathParamRange)
            % local variables
            pathParam = linspace(0,2*pi,300);
            avgEl = obj.meanElevationInRadians;
            tetLen = obj.tetherLength;
            % preallocate arrays
            zLoc = NaN*pathParam;
            yLoc = NaN*pathParam;
            RFE = NaN*pathParam;
            % get equations for x,y and K using flat earth function
            [eqZ,eqY,eqK] = obj.radiusOfCurvatureFlatEarthApprox();
            for ii = 1:numel(pathParam)
                zLoc(ii) = eqZ(pathParam(ii));
                yLoc(ii) = eqY(pathParam(ii));
                RFE(ii) = min(tetLen,1/max(eps,eqK(pathParam(ii))));
            end
            % outputs
            val.radiusOfCircle = RFE;
            val.zPosProjection = zLoc;
            val.yPosProjection = yLoc;
            % get lemniscate cordinates and polar coordinates
            [lemVal,polVal] = obj.getLemniScateCoordinates(pathParam);
            % make plots
            fig = obj.findFigureObject('Results');
            set(gcf,'Position',fig.Position.*[1 0.1 1 2]);
            % 3D plot of the path
            subplot(3,1,1);
            plot3(lemVal.lemX,lemVal.lemY,lemVal.lemZ,'k-');
            grid on; hold on;
            xlabel('X (m)');ylabel('Y (m)');zlabel('Z (m)');
            title(['$a$ = ',num2str(round(obj.aBooth,2)),...
                ', $b$ = ',num2str(round(obj.bBooth,2)),...
                ', $R$ = ',num2str(round(obj.tetherLength,1)),' m']);
            
            view(100,35);
            % plot the 0 elevation line line
            txtOffset = 0.5;
            azimLine = [obj.tetherLength*cos(avgEl)*cos(polVal.azimuth);...
                obj.tetherLength*cos(avgEl)*sin(polVal.azimuth);
                obj.tetherLength*sin(avgEl)*ones(size(pathParam))];
            plot3(azimLine(1,:),azimLine(2,:),azimLine(3,:),...
                'b:','linewidth',1);
            [maxAzim,maxAzimIdx] = max(polVal.azimuth);
            [minAzim,minAzimIdx] = min(polVal.azimuth);
            text(azimLine(1,maxAzimIdx),azimLine(2,maxAzimIdx)+txtOffset,...
                azimLine(3,maxAzimIdx),sprintf('%.2f',maxAzim*180/pi));
            text(azimLine(1,minAzimIdx),azimLine(2,minAzimIdx)-txtOffset,...
                azimLine(3,minAzimIdx),sprintf('%.2f',minAzim*180/pi));
            % plot the 0 azimuth line line
            elevLine = [obj.tetherLength*cos(polVal.elevation);...
                zeros(size(pathParam));
                obj.tetherLength*sin(polVal.elevation)];
            plot3(elevLine(1,:),elevLine(2,:),elevLine(3,:),...
                'b:','linewidth',1);
            [maxElev,maxElevIdx] = max(polVal.elevation);
            [minElev,minElevIdx] = min(polVal.elevation);
            text(elevLine(1,maxElevIdx),elevLine(2,maxElevIdx),...
                elevLine(3,maxElevIdx)+txtOffset,sprintf('%.2f',maxElev*180/pi));
            text(elevLine(1,minElevIdx),elevLine(2,minElevIdx),...
                elevLine(3,minElevIdx)-txtOffset,sprintf('%.2f',minElev*180/pi));
            obj.plotDome
            % 2D plot of the flat earth path
            subplot(3,1,2)
            plot(yLoc,zLoc,'k-')
            grid on;hold on;
            axis equal
            xlabel('Y (m)');ylabel('Z (m)');
            title('Projection of path');
            % radius of curvature
            subplot(3,1,3)
            maxPercRad = 1;
            plot(pathParam,RFE,'k-');
            grid on;hold on;
            xlabel('Path parameter');ylabel('$R_{\mathrm{osc}}$ (m)');
            title('Radius of curvature');
            
            % analyse section
            switch nargin
                case 2
                    nIdx = pathParam>=pathParamRange(1) &...
                        pathParam<=pathParamRange(2);
                    subplot(3,1,1)
                    plot3(lemVal.lemX(nIdx),lemVal.lemY(nIdx),lemVal.lemZ(nIdx),...
                        'r-','linewidth',1);
                    subplot(3,1,2)
                    plot(yLoc(nIdx),zLoc(nIdx),...
                        'r-','linewidth',1);
                    subplot(3,1,3)
                    nPathParm = pathParam(nIdx);
                    nRFE = RFE(nIdx);
                    plot(nPathParm(nRFE<maxPercRad*obj.tetherLength),...
                        nRFE(nRFE<maxPercRad*obj.tetherLength),...
                        'r-','linewidth',1);
            end
            
        end
        
        function val = findFigureObject(obj,figName)
            val = findobj( 'Type', 'Figure', 'Name',figName);
            
            if isempty(val)
                val = figure;
                val.Name = figName;
            else
                figure(val);
            end
        end
        
        function plotDome(obj)
            % get constants
            r = obj.tetherLength;
            lwd = 0.5;
            lnType = ':';
            grayRGB = 128/255.*[1 1 1];
            % make longitude and latitude fine grids
            longFine = -90:1:90;
            latFine = -0:1:90;
            stepSize = 30;
            % make longitude and latitude coarse grids
            longCoarse = longFine(1):stepSize:longFine(end);
            latCoarse = latFine(1):stepSize:latFine(end);
            % plot longitude lines
            for ii = 1:numel(longCoarse)
            X = r*cosd(longCoarse(ii)).*cosd(latFine);
            Y = r*sind(longCoarse(ii)).*cosd(latFine);
            Z = r*sind(latFine);
            plot3(X,Y,Z,lnType,'linewidth',lwd,'color',grayRGB);
            end
            % plot latitude lines
            for ii = 1:numel(latCoarse)
            X = r*cosd(longFine).*cosd(latCoarse(ii));
            Y = r*sind(longFine).*cosd(latCoarse(ii));
            Z = r*sind(latCoarse(ii))*ones(size(longFine));
            plot3(X,Y,Z,lnType,'linewidth',lwd,'color',grayRGB);
            end
            
        end
            
    end
end

