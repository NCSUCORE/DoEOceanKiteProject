function [init_O_rKite,init_Euler,init_O_vKite,init_OwB,init_Az,init_El,init_OcB] = ...
    getInitConditions(init_s,pathWidth,pathHeight,pathElev,rad,speed)

% local variables
w = pathWidth*pi/180;
h = pathHeight*pi/180;

% get abooth and bbooth
aBooth = 0.5*w;
bBooth = (1/(2*sqrt(2)))*sqrt(-w^2+sqrt((h^2*(4+h^2)*w^4))/(h^2));
meanEl = pathElev*pi/180;

% local functions
pathEq = @(aBooth,bBooth,meanElevation,pathParam,thrLength)[thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*cos((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0));-thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*sin((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0));thrLength.*sin(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0))];
pathTgt = @(aBooth,bBooth,meanElevation,pathParam,thrLength)[thrLength.*sin(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*cos((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)-(aBooth.^2.*1.0./bBooth.^2.*sin(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^4.*1.0./bBooth.^4.*cos(pathParam).^2.*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0)-thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*sin((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.*cos(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^3.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0);-thrLength.*sin(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*sin((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)-(aBooth.^2.*1.0./bBooth.^2.*sin(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^4.*1.0./bBooth.^4.*cos(pathParam).^2.*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0)-thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*cos((aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.*cos(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^3.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0);-thrLength.*cos(meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)).*((aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)-(aBooth.^2.*1.0./bBooth.^2.*sin(pathParam).^2)./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0)+aBooth.^4.*1.0./bBooth.^4.*cos(pathParam).^2.*sin(pathParam).^2.*1.0./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0).^2.*2.0)];
pathAz = @(aBooth,bBooth,pathParam)-(aBooth.*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0);
pathEl = @(aBooth,bBooth,meanElevation,pathParam)meanElevation-(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).*sin(pathParam))./(aBooth.^2.*1.0./bBooth.^2.*cos(pathParam).^2+1.0);


% initial conditions
init_O_rKite = pathEq(aBooth,bBooth,meanEl,init_s,rad);
% get body axes
bdyZ = init_O_rKite./norm(init_O_rKite);
bdyX = -pathTgt(aBooth,bBooth,meanEl,init_s,1);
bdyX = bdyX./norm(bdyX);
bdyY = cross(bdyZ,bdyX);
init_OcB = [bdyX bdyY bdyZ];
% calc euler angle from rotation matrix
init_Euler = flip(rotm2eul(init_OcB))';
% throw kite along the path tangent
init_O_vKite = -speed*bdyX;
init_OwB     = [0;0;0];
init_Az      = pathAz(aBooth,bBooth,init_s);
init_El      = pathEl(aBooth,bBooth,meanEl,init_s);



end
