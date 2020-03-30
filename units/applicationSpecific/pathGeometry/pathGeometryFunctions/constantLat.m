function [posGround,varargout] = constantLat(pathVariable,geomParams)
%pathVariable is parameterized along the path from 0 to 1
%geomParams is a vector in order of the following variables:
%   
%Outpus:
%   posGround is the position in the ground frame at the given pathVar
%   The second output, if requested is a ground frame unit vector in the
%       direction tangent to the curve (the direction to go)

    lat = geomParams(1);
    startLong = geomParams(2);
    longRange = geomParams(3);
    if length(geomParams)==4
        sphereRadius = geomParams(4);
    else
        sphereRadius = 1;
    end
    
    long=@(x) startLong+x*longRange;
    path = @(x)sphereRadius * [cos(long(x)).*cos(lat);
                               sin(long(x)).*cos(lat);
                               ones(length(long(x))).*sin(lat);];
    posGround=path(pathVariable);
    if nargout==2
        
        tangentVec=[-sin(long(pathVariable));...
                    cos(long(pathVariable));...
                    zeros(1,length(pathVariable))];
        varargout{1}=tangentVec./norm(tangentVec);
    end
end