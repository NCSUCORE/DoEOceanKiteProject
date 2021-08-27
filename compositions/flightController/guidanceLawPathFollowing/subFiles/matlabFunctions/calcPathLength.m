function val = calcPathLength(pathWidth_deg,pathHeight_deg,...
    pathElevation_deg,pathRadius_m,pathParamRange)
%CALCPATHLENGTH(pathWidth_deg,pathHeight_deg,pathElevation_deg,pathRadius_m,pathParamRange)
% Calculate path length between pathParamRange
% Inputs:   pathWidth_deg - Path width [deg]
%           pathHeight_deg - Path height [deg]
%           pathElevation_deg - Path elevation [deg]
%           pathRadius_m - Path radius or tether length [m]
%           pathParamRange - Path parameter range,s where 0 < s < 2*pi for 1 lap
% Output:   Path length in meters


%% dummy local variables with shorter names
w = pathWidth_deg*pi/180;
h = pathHeight_deg*pi/180;
e = pathElevation_deg*pi/180;
r = pathRadius_m;
sRange = pathParamRange;

%% path shape parameters a and b
a = 0.5*w;
b = (1/(2*sqrt(2)))*sqrt(-w^2+sqrt((h^2*(4+h^2)*w^4))/(h^2));

eqPathLength = @(aBooth,bBooth,meanElevation,pathParam,thrLength)sqrt((thrLength.*sin(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*sin((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)-(aBooth.^2.*1.0./bBooth.^2.*sin(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^4.*1.0./bBooth.^4.*cos(pathParam).^2.*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0)+thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*cos((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.*cos(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^3.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0)).^2+(thrLength.*sin(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*cos((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)-(aBooth.^2.*1.0./bBooth.^2.*sin(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^4.*1.0./bBooth.^4.*cos(pathParam).^2.*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0)-thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*sin((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.*cos(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^3.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0)).^2+thrLength.^2.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).^2.*((aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)-(aBooth.^2.*1.0./bBooth.^2.*sin(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^4.*1.0./bBooth.^4.*cos(pathParam).^2.*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0).^2);
% output
val = integral(@(pathParam) ...
    eqPathLength(a,b,e,pathParam,r),sRange(1),sRange(2));

end