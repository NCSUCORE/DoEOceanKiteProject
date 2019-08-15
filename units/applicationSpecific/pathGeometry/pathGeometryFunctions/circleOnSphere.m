function [posGround,varargout] = circleOnSphere(pathVariable,geomParams)
%pathVariable is parameterized along the path from 0 to 1
%geomParams is a vector in order of the following variables:
%   radius is the radius of the circle on the surface of the sphere
%   latCurve is the average Latitude (the lat of the crossover point)
%   longCurve is the average Longitude (the lat of the crossover point)
%   sphereRadius is the radius of the sphere the path is drawn on (optional)
%       if not given, a unit sphere is assumed
%Outpus:
%   posGround is the position in the ground frame at the given pathVar
%   The second output, if requested is a ground frame unit vector in the
%       direction tangent to the curve (the direction to go)

    pathVariable = 2*pi - (pathVariable * 2*pi);
    radius = geomParams(1);
    latCurve = geomParams(2);
    longCurve = geomParams(3);
    if length(geomParams)==4
        sphereRadius = geomParams(4);
    else
        sphereRadius = 1;
    end
    pathVariable = pathVariable(:)'; %make it a row vector
    
    long=@(x) radius*(longCurve+cos(x));
    lat=@(x) radius*(latCurve+sin(x));
    path = @(x)sphereRadius * [cos(long(x)).*cos(lat(x));...
                         sin(long(x)).*cos(lat(x));...
                         sin(lat(x));];
    posGround=path(pathVariable);
    if nargout==2
        dLongdS = @(x) -radius.*sin(x);
        dLatdS = @(x) radius.*cos(x);
        dPathdLong =  @(x) [-cos(radius.*(latCurve + sin(x))).*sin(radius.*(longCurve + cos(x)))
                             cos(radius.*(longCurve + cos(x))).*cos(radius.*(latCurve + sin(x)))
                                                                 0];
        dPathdLat = @(x) [-cos(radius.*(longCurve + cos(x))).*sin(radius.*(latCurve + sin(x)))
                          -sin(radius.*(longCurve + cos(x))).*sin(radius.*(latCurve + sin(x)))
                                   cos(radius.*(latCurve + sin(x)))];
        dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
         if latCurve >0 
            tangentVec = dPathdS(pathVariable);
        else 
           tangentVec = -dPathdS(pathVariable);
        end
        
        varargout{1}=tangentVec./norm(tangentVec);
    end
end