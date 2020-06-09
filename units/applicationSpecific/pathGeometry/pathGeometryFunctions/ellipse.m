function [posGround,varargout] = ellipse(pathVariable,geomParams,cntrPtPosVec)
%pathVariable is parameterized along the path from 0 to 1
%geomParams is a vector in order of the following variables:
%   width is the total horizontal sweep angle of the curve (usually the major axis) in radians
%   height is the total vertical sweep angle of the curve in radians
%   latCurve is the average Latitude (the lat of the center)
%   longCurve is the average Longitude (the long of the center)
%   sphereRadius (optional) is the radius of the sphere the path is drawn on 
%       if not given, a unit sphere is assumed
%Outputs:
%   posGround is the position in the ground frame at the given pathVar
%   The second output, if requested is a ground frame unit vector in the
%       direction tangent to the curve (the direction to go)
    pathVariable = rem(pathVariable+.25,1);
    width = geomParams(1);
    height = geomParams(2);
    latCurve = geomParams(3);
    longCurve = geomParams(4);
    if latCurve < 0 
        pathVariable = 2*pi - (pathVariable * 2*pi);
    else
        pathVariable = 2*pi * pathVariable;
    end
    if length(geomParams)==5
        sphereRadius = geomParams(5);
    else
        sphereRadius = 1;
    end
    pathVariable = pathVariable(:)'; %make it a row vector
    
    %assume (from this point) that width > height
    a = width/2;
    b = height/2;
        
    long=@(x) longCurve+(a*cos(x));
    lat=@(x) latCurve+(b*sin(x));
    path = @(x)sphereRadius * [cos(long(x)).*cos(lat(x));...
                         sin(long(x)).*cos(lat(x));...
                         sin(lat(x))] + cntrPtPosVec(:);
    posGround = path(pathVariable);
    if nargout==2
        dLongdS = @(x) -a.*sin(x);
        dLatdS = @(x) b.*cos(x);
        dPathdLong =  @(x) [-cos(lat(x)).*sin(long(x));
                            cos(lat(x)).*cos(long(x));
                            zeros(size(pathVariable))];
        dPathdLat = @(x) [-cos(long(x)).*sin(lat(x));
                          -sin(lat(x)).*sin(long(x));
                          cos(lat(x))];
        dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
        if latCurve < 0 
           tangentVec = -dPathdS(pathVariable);
        else 
           tangentVec = dPathdS(pathVariable);
        end
        
        varargout{1}=tangentVec./sqrt(sum(tangentVec.^2,1));
    end
end