function [posGround,varargout] = lemOfBooth(pathVariable,geomParams)
%pathVariable is parameterized along the path from 0 to 1
%geomParams is a vector in order of the following variables:
%   aBooth is the general size
%   bBooth is roughly the height to width ratio
%   latCurve is the average Latitude (the lat of the crossover point)
%   longCurve is the average Longitude (the lat of the crossover point)
%   radius is the radius of the sphere the path is drawn on (optional)
%       if not given, a unit sphere is assumed
%Outpus:
%   posGround is the position in the ground frame at the given pathVar
%   The second output, if requested is a ground frame unit vector in the
%       direction tangent to the curve (the direction to go)
    aBooth=geomParams(1);
    bBooth=geomParams(2);
    latCurve=geomParams(3);
    longCurve=geomParams(4);
    if latCurve < 0
        pathVariable = 2*pi * pathVariable;
    else
        pathVariable = 2*pi - (pathVariable * 2*pi);
    end
    if length(geomParams)>=5
        radius = geomParams(5);
    else
        radius = 1;
    end
    pathVariable = pathVariable(:)'; %Make it a row vector
    
    long=@(x) longCurve+(aBooth.*sin(x)./(1+(aBooth./bBooth).^2.*cos(x).^2));
    lat=@(x) latCurve+((aBooth./bBooth).^2.*sin(x).*cos(x)./(1 + (aBooth./bBooth).^2.*cos(x).^2));
    path = @(x)radius * [cos(long(x)).*cos(lat(x));...
                         sin(long(x)).*cos(lat(x));...
                         sin(lat(x));];
    posGround=path(pathVariable);
    if nargout==2
        dLongdS = @(x) (aBooth.*cos(x))./((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1) + (2.*aBooth.^3.*cos(x).*sin(x).^2)./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1).^2);
        dLatdS = @(x) (aBooth.^2.*cos(x).^2)./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1)) - (aBooth.^2.*sin(x).^2)./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1)) + (2.*aBooth.^4.*cos(x).^2.*sin(x).^2)./(bBooth.^4.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1).^2);
        dPathdLong =  @(x) [-cos(lat(x)).*sin(long(x));
                            cos(lat(x)).*cos(long(x));
                            zeros(size(pathVariable))];
        dPathdLat = @(x) [-cos(long(x)).*sin(lat(x));
                          -sin(lat(x)).*sin(long(x));
                          cos(lat(x))];
        dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
        if latCurve < 0
            tangentVec = dPathdS(pathVariable);
        else 
            tangentVec = -dPathdS(pathVariable);
        end
        varargout{1}=tangentVec./sqrt(sum(tangentVec.^2,1));
    end
end