classdef maneuverabilityAnalysisLibrary
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        aBooth
        bBooth
        tetherLength
        meanElevationInRadians
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
        
        function [eqX,eqY,eqK] = testWithCircle(obj)
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
        
        function [eqLong,eqLat,eqK] = derive_3D_Equations(obj)
            % symbolic
            syms pathParm
            a = obj.aBooth;
            b = obj.bBooth;
            % logitutude equation
            pathLong = (a*sin(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
            % latitude equation equation
            pathLat = (((a/b)^2)*sin(pathParm).*cos(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
            pathLat = pathLat + obj.meanElevationInRadians;
            % first derivative
            dLong = diff(pathLong,pathParm);
            dLat = diff(pathLat,pathParm);
            % second derivative
            ddLong = diff(dLong,pathParm);
            ddLat = diff(dLat,pathParm);
            % curvature numerator
            Knum = abs(dLong*ddLat - dLat*ddLong);
            % curvature denominator
            Kden = (dLong^2 + dLat^2)^1.5;
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqLong = matlabFunction(pathLong);
            eqLat = matlabFunction(pathLat);
        end
        
        function [eqX,eqY,eqK] = radiusOfCurvatureFlatEarthApprox(obj)
            
            a = obj.aBooth;
            b = obj.bBooth;
            r = obj.tetherLength;
            % % % initialize symbolics
            syms azimuth(pathParm) elevation(pathParm) ...
                tetLength aBooth bBooth pathParm
            
            % logitutude/azimuth equation
            azimuth = (a*sin(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
            % latitude/elevation equation
            elevation = (((a/b)^2)*sin(pathParm).*cos(pathParm))./...
                (1 + ((a/b)^2).*(cos(pathParm).^2));
%             elevation = elevation + obj.meanElevationInRadians;
            % using flat earth approximation
            y = r*elevation;
            x = r*azimuth*cos(elevation);
            
            % get first derivative
            dx = diff(x,pathParm);
            dy = diff(y,pathParm);
            
            % get second derivative
            ddx = diff(dx,pathParm);
            ddy = diff(dx,pathParm);
            
            % curvature numerator
            Knum = abs(dx*ddy - dy*ddx);
            % curvature denominator
            Kden = (dx^2 + dy^2)^1.5;
            
            % curvature
            eqK = matlabFunction(Knum/Kden);
            eqX = matlabFunction(x);
            eqY = matlabFunction(y+r*obj.meanElevationInRadians);
            
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
            % preallocate arrays
            xLoc = NaN*pathParam;
            yLoc = NaN*pathParam;
            RFE = NaN*pathParam;
            % get equations for x,y and K using flat earth function
            [eqX,eqY,eqK] = obj.radiusOfCurvatureFlatEarthApprox();
            for ii = 1:numel(pathParam)
                xLoc(ii) = eqX(pathParam(ii));
                yLoc(ii) = eqY(pathParam(ii));
                RFE(ii) = 1/max(eps,eqK(pathParam(ii)));
            end
            % outputs
            val.radiusOfCircle = RFE;
            val.xPosProjection = xLoc;
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
            % 2D plot of the flat earth path
            subplot(3,1,2)
            plot(xLoc,yLoc,'k-')
            grid on;hold on;
            xlabel('Y (m)');ylabel('Z (m)');
            title('Projection of path');
            % radius of curvature
            subplot(3,1,3)
            maxPercRad = 1;
            temp = RFE;
            temp(RFE>=maxPercRad*obj.tetherLength) = NaN;
            plot(pathParam,temp,'k-');
            grid on;hold on;
            xlabel('Path parameter');ylabel('$R_{\mathrm{osc}}$ (m)');
            title('Radius of osculating circle');
            
            % analyse section
            switch nargin
                case 2
                    nIdx = pathParam>=pathParamRange(1) &...
                        pathParam<=pathParamRange(2);
                    subplot(3,1,1)
                    plot3(lemVal.lemX(nIdx),lemVal.lemY(nIdx),lemVal.lemZ(nIdx),...
                        'r-','linewidth',1);
                    subplot(3,1,2)
                    plot(xLoc(nIdx),yLoc(nIdx),...
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
            
    end
end

