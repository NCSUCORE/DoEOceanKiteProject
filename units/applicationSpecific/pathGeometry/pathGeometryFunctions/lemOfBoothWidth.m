function [posGround,varargout] = lemOfBoothWidth(pathVariable,geomParams,cntrPtPosVec)
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
pathWidth       = geomParams(1);
pathHeight      = geomParams(2);
meanLat = geomParams(3); % Mean course latitude
meanLon = geomParams(4); % Mean course longitude
% Correct path variable so that increasing path variable traverses the path
% in the same direction
if meanLat < 0
    pathVariable = 2*pi * pathVariable;
else
    pathVariable = 2*pi - (pathVariable * 2*pi);
end
% If we're given at least 5 geometric parametrs, the fifth one is radius
if length(geomParams)>=5
    radius = geomParams(5);
else
    radius = 1;
end

[n,m] = size(pathVariable);

if n > 1
    pathVariable = pathVariable(:)'; %Make the path variable a row vector
end

%%%%
% Convert from width and height in meters to basis parameters in radians
%%%%
w = pathWidth/radius
h = pathHeight/radius
a = pathWidth/(2*radius)
b = (1/(2*sqrt(2)))*sqrt(-w^2+sqrt((h^2*(4+h^2)*w^4))/(h^2))

% Create anonymous function handle to calculate path shape
long = @(x) meanLon+(a.*sin(x)./(1+(a./b).^2.*cos(x).^2));
lat  = @(x) meanLat+((a.^2./b).*sin(x).*cos(x)./(1 + (a./b).^2.*cos(x).^2));
path = @(x)radius * [cos(long(x)).*cos(lat(x));...
                     sin(long(x)).*cos(lat(x));...
                     sin(lat(x))]                   + cntrPtPosVec(:);
el = lat(pathVariable)*radius
% Evaluate function handles at the specified path variables
posGround = path(pathVariable);

% If asked for the tangent vector, calculate it
if nargout==2
    dLongdS    = @(x) (a.*cos(x))./((a.^2.*cos(x).^2)./b.^2 + 1) + (2.*a.^3.*cos(x).*sin(x).^2)./(b.^2.*((a.^2.*cos(x).^2)./b.^2 + 1).^2);
    dLatdS     = @(x) (a.^2.*cos(x).^2)./(b.^2.*((a.^2.*cos(x).^2)./b.^2 + 1)) - (a.^2.*sin(x).^2)./(b.^2.*((a.^2.*cos(x).^2)./b.^2 + 1)) + (2.*a.^4.*cos(x).^2.*sin(x).^2)./(b.^4.*((a.^2.*cos(x).^2)./b.^2 + 1).^2);
    dPathdLong  =  @(x) [-cos(lat(x)).*sin(long(x));
                          cos(lat(x)).*cos(long(x));
                          zeros(size(pathVariable))];
    dPathdLat   = @(x) [-cos(long(x)).*sin(lat(x));
                        -sin(lat(x)).*sin(long(x));
                         cos(lat(x))];
    dPathdS     = @(x) (dPathdLat(x).*dLatdS(x)) + (dPathdLong(x).*dLongdS(x));
    if meanLat < 0
        tangentVec =  dPathdS(pathVariable);
    else
        tangentVec = -dPathdS(pathVariable);
    end
    varargout{1} = tangentVec./sqrt(sum(tangentVec.^2,1));
end
end