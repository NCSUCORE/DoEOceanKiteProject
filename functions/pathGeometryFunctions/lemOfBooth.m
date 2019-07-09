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
    pathVariable1 = pathVariable * 2*pi;
    pathVariable2 = (1-pathVariable) * 2*pi;
    pathVariable = (1-pathVariable) * 2*pi;
    aBooth=geomParams(1);
    bBooth=geomParams(2);
    latCurve=geomParams(3);
    longCurve=geomParams(4);
    if length(geomParams)==5
        radius = geomParams(5);
    else
        radius = 1;
    end
    
    long=@(x) aBooth.*sin(x)./(1+(aBooth./bBooth).^2.*cos(x).^2);
    lat=@(x) (aBooth./bBooth).^2.*sin(x).*cos(x)./(1 + (aBooth./bBooth).^2.*cos(x).^2);
    path = @(x)radius * [cos(longCurve+long(x)).*cos(latCurve+lat(x));...
                         sin(longCurve+long(x)).*cos(latCurve+lat(x));...
                         sin(latCurve+lat(x));];
    posGround=path(pathVariable);
    if nargout==2
        dLongdS = @(x) (aBooth.*cos(x))./((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1) + (2.*aBooth.^3.*cos(x).*sin(x).^2)./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1).^2);
        dLatdS = @(x) (aBooth.^2.*cos(x).^2)./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1)) - (aBooth.^2.*sin(x).^2)./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1)) + (2.*aBooth.^4.*cos(x).^2.*sin(x).^2)./(bBooth.^4.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1).^2);
        dPathdLong =  @(x) [-cos(latCurve + (aBooth.^2.*cos(x).*sin(x))./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1))).*sin(longCurve + (aBooth.*sin(x))./((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1));
                            cos(latCurve + (aBooth.^2.*cos(x).*sin(x))./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1))).*cos(longCurve + (aBooth.*sin(x))./((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1));
                            zeros(size(pathVariable))];
        dPathdLat = @(x) [-cos(longCurve + (aBooth.*sin(x))./((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1)).*sin(latCurve + (aBooth.^2.*cos(x).*sin(x))./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1)));
                          -sin(latCurve + (aBooth.^2.*cos(x).*sin(x))./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1))).*sin(longCurve + (aBooth.*sin(x))./((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1));
                          cos(latCurve + (aBooth.^2.*cos(x).*sin(x))./(bBooth.^2.*((aBooth.^2.*cos(x).^2)./bBooth.^2 + 1)))];
        dPathdS = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
        tangentVec=-dPathdS(pathVariable);
        varargout{1}=tangentVec./norm(tangentVec);
    end
end