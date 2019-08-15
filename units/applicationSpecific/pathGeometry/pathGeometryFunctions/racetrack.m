function [posGround,varargout] = racetrack(pathVariable,geomParams)
%pathVariable is parameterized along the path from 0 to 1
%The path is drawn on the sphere and defined in the lat long plane.
%geomParams is a vector in order of the following variables:
%   radius is the radius of the semi-circular ends of the path in radians
%   centToCent is the center to center distance. This is also the width of
%       the straight sections
%   latCurve is the average Latitude (the lat of the center)
%   longCurve is the average Longitude (the long of the center)
%   sphereRadius is the radius of the sphere the path is drawn on (optional)
%       if not given, a unit sphere is assumed
%Outpus:
%   posGround is the position in the ground frame at the given pathVar
%   The second output, if requested is a ground frame unit vector in the
%       direction tangent to the curve (the direction to go)

    radius = geomParams(1);
    centToCent = geomParams(2);
    latCurve = geomParams(3);
    longCurve = geomParams(4);
    if latCurve < 0 
        pathVariable = 1 - pathVariable;
    end
    if length(geomParams)==5
        sphereRadius = geomParams(5);
    else
        sphereRadius = 1;
    end
    pathVariable = pathVariable(:)'; %make it a row vector
    
    posGround = zeros(3,length(pathVariable));
    tangentVec = zeros(3,length(pathVariable));
    for ii = 1:length(pathVariable)
        if pathVariable(ii) <= .25
            %% bottom straightaway (left to right from the outside)
            long=@(x) longCurve-(.5*centToCent)+(centToCent*x*(1/.25));
            lat=@(x) latCurve-radius;
            path = @(x)sphereRadius * [cos(long(x)).*cos(lat(x));...
                                       sin(long(x)).*cos(lat(x));...
                                       sin(lat(x));];
            posGround(:,ii)=path(pathVariable(ii));
            if nargout==2
                dLongdS = @(x) centToCent*(1/.25);
                dLatdS = @(x) 0;
                dPathdLong =  @(x) [-cos(lat(x)).*sin(long(x));
                                    cos(lat(x)).*cos(long(x));
                                    zeros(size(pathVariable))];
                dPathdLat = @(x) [-cos(long(x)).*sin(lat(x));
                                  -sin(lat(x)).*sin(long(x));
                                  cos(lat(x))];
                dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
                if latCurve < 0 
                   tangentVec(:,ii) = -dPathdS(pathVariable(ii));
                else 
                   tangentVec(:,ii) = dPathdS(pathVariable(ii));
                end
            end
        elseif pathVariable(ii) <= .5
            %% right semicircle (bottom to top from the outside)
            long=@(x) longCurve+(.5*centToCent)+ (radius*sin((x-.25)*(pi/.25)));
            lat=@(x) latCurve+(radius*-1*cos((x-.25)*(pi/.25)));
            path = @(x)sphereRadius * [cos(long(x)).*cos(lat(x));...
                                       sin(long(x)).*cos(lat(x));...
                                       sin(lat(x));];
            posGround(:,ii)=path(pathVariable(ii));
            if nargout==2
                dLongdS = @(x) radius*cos((x-.25)*(pi/.25))*(pi/.25);
                dLatdS = @(x) radius*sin((x-.25)*(pi/.25))*(pi/.25);
                dPathdLong =  @(x) [-cos(lat(x)).*sin(long(x));
                                    cos(lat(x)).*cos(long(x));
                                    zeros(size(pathVariable))];
                dPathdLat = @(x) [-cos(long(x)).*sin(lat(x));
                                  -sin(lat(x)).*sin(long(x));
                                  cos(lat(x))];
                dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
                if latCurve < 0 
                   tangentVec(:,ii) = -dPathdS(pathVariable(ii));
                else 
                   tangentVec(:,ii) = dPathdS(pathVariable(ii));
                end
            end
        elseif pathVariable(ii) <= .75
            %% bottom straightaway (left to right from the outside)
            long=@(x) longCurve+(.5*centToCent)-(centToCent*(x-.5)*(1/.25));
            lat=@(x) latCurve+radius;
            path = @(x)sphereRadius * [cos(long(x)).*cos(lat(x));...
                                       sin(long(x)).*cos(lat(x));...
                                       sin(lat(x));];
            posGround(:,ii)=path(pathVariable(ii));
            if nargout==2
                dLongdS = @(x) -centToCent*(1/.25);
                dLatdS = @(x) 0;
                dPathdLong =  @(x) [-cos(lat(x)).*sin(long(x));
                                    cos(lat(x)).*cos(long(x));
                                    zeros(size(pathVariable))];
                dPathdLat = @(x) [-cos(long(x)).*sin(lat(x));
                                  -sin(lat(x)).*sin(long(x));
                                  cos(lat(x))];
                dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
                if latCurve < 0 
                   tangentVec(:,ii) = -dPathdS(pathVariable(ii));
                else 
                   tangentVec(:,ii) = dPathdS(pathVariable(ii));
                end
            end
        
        elseif pathVariable(ii) <= 1
            %% right semicircle (bottom to top from the outside)
            long=@(x) longCurve - (.5*centToCent) - (radius*sin((x-.75)*(pi/.25)));
            lat=@(x)  latCurve + (radius*cos((x-.75)*(pi/.25)));
            path = @(x)sphereRadius * [cos(long(x)).*cos(lat(x));...
                                       sin(long(x)).*cos(lat(x));...
                                       sin(lat(x));];
            posGround(:,ii)=path(pathVariable(ii));
            if nargout==2
                dLongdS = @(x) -radius*cos((x-.25)*(pi/.25))*(pi/.25);
                dLatdS = @(x) -radius*sin((x-.25)*(pi/.25))*(pi/.25);
                dPathdLong =  @(x) [-cos(lat(x)).*sin(long(x));
                                    cos(lat(x)).*cos(long(x));
                                    zeros(size(pathVariable))];
                dPathdLat = @(x) [-cos(long(x)).*sin(lat(x));
                                  -sin(lat(x)).*sin(long(x));
                                  cos(lat(x))];
                dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
                if latCurve < 0 
                   tangentVec(:,ii) = -dPathdS(pathVariable(ii));
                else
                   tangentVec(:,ii) = dPathdS(pathVariable(ii));
                end
            end
    end
    varargout{1}=tangentVec./sqrt(sum(tangentVec.^2,1));
end