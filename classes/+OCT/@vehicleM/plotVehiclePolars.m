function h = plotVehiclePolars(obj,thr,varargin)
p = inputParser;
addParameter(p,'pMom',false,@islogical);
addParameter(p,'xLim',[-20 20],@isnumeric);
addParameter(p,'color',[0,0,1],@isnumeric);
addParameter(p,'fig',21,@isnumeric);
addParameter(p,'sub',1,@isnumeric);
addParameter(p,'vBdy',[0;0;0],@isnumeric);
addParameter(p,'vFlow',[.25;0;0],@isnumeric);
addParameter(p,'theta',-15:.5:15,@isnumeric);
addParameter(p,'phi',90,@isnumeric);
addParameter(p,'elevation',30,@isnumeric);
addParameter(p,'azimuth',0,@isnumeric);
addParameter(p,'heading',90,@isnumeric);
parse(p,varargin{:})

col = p.Results.color;
fig = p.Results.fig;
sub = p.Results.sub;
theta = p.Results.theta;
vFlow = p.Results.vFlow;

Sys.LE = -obj.fuse.rNose_LE.Value;                  %   m - wing leading edge w/ respect to nose
Sys.xg = Sys.LE+obj.rCM_LE.Value;                   %   m - Center of gravity w/ respect to nose
Sys.xW = Sys.LE+[.1807 0 0]';                       %   m - Wing aerodynamic center location w/ respect to nose
Sys.xH = Sys.LE+...                                 %   m - Horizontal stabilizer aerodynamic center location w/ respect to nose
    obj.hStab.rSurfLE_WingLEBdy.Value+...
    obj.hStab.rAeroCent_SurfLE.Value;
Sys.xV = Sys.LE+...                                 %   m - Vertical stabilizer aerodynamic center location w/ respect to nose
    obj.vStab.rSurfLE_WingLEBdy.Value+...
    [obj.vStab.rAeroCent_SurfLE.Value(1);...
    0;obj.vStab.rAeroCent_SurfLE.Value(2)];
Sys.f = Sys.LE+obj.fuseMomentArm.Value;            %   m - Fuselage aerodynamic center w/ respect to nose
D = [0;0;0];
CM.W = Sys.xW-Sys.xg;   CM.H = Sys.xH-Sys.xg;
CM.V = Sys.xV-Sys.xg;   CM.F = Sys.f-Sys.xg;
LE.W = D+Sys.xW-Sys.LE;   LE.H = D+Sys.xH-Sys.LE;
LE.V = D+Sys.xV-Sys.LE;   LE.F = D+Sys.f-Sys.LE;

Ry = @(x) [cosd(x) 0 -sind(x);0 1 0;sind(x) 0 cosd(x)]; %   Rotation matrix for rotations about the y-axis
Rz = @(x) [cosd(x) sind(x) 0;-sind(x) cosd(x) 0;0 0 1]; %   Rotation matrix for rotations about the z-axis

alpha = obj.portWing.alpha.Value;
Aref = obj.fluidRefArea.Value;
Afuse = pi/4*obj.fuse.diameter.Value^2.*cosd(alpha)+...
    (pi/4*obj.fuse.diameter.Value^2+obj.fuse.diameter.Value*obj.fuse.length.Value).*(1-cosd(alpha));
Athr = 3*thr.tether1.diameter.Value/4;
CDthr = thr.tether1.dragCoeff.Value*Athr/Aref;
CDfuse = (obj.fuse.endDragCoeff.Value.*cosd(alpha)+...
    obj.fuse.sideDragCoeff.Value.*(1-cosd(alpha))).*Afuse/Aref;
CLwing = obj.portWing.CL.Value+obj.stbdWing.CL.Value;
CLstab = obj.hStab.CL.Value;
CDwing = obj.portWing.CD.Value+obj.stbdWing.CD.Value;
CDstab = obj.hStab.CD.Value;
CDvert = obj.vStab.CD.Value;

CLtot = CLwing+CLstab;
CDtot = CDwing+CDstab+CDvert+CDfuse+CDthr;

figure(fig);
subplot(2,2,1);hold on;grid on;
plot(alpha,CLtot);
xlabel('alpha [deg]');  ylabel('$\mathrm{CL}$');  xlim(p.Results.xLim);
subplot(2,2,2);hold on;grid on;
plot(alpha,CDtot);
xlabel('alpha [deg]');  ylabel('$\mathrm{CD}$');  xlim(p.Results.xLim);
subplot(2,2,3);hold on;grid on;
plot(alpha,CLtot.^3./CDtot.^2);
xlabel('alpha [deg]');  ylabel('$\mathrm{CL^3/CD^2}$');  xlim(p.Results.xLim);
subplot(2,2,4);hold on;grid on;
plot(alpha,CLtot./CDtot);
xlabel('alpha [deg]');  ylabel('$\mathrm{CL/CD}$');  xlim(p.Results.xLim);

for i = 1:length(theta)
    tanPitch = theta(i)-90+40;
    TcG = Ry(50)*Rz(0);                                     %   Rotation matrix from ground to tangent frame
    BcT = Ry(tanPitch)*Rz(0);                               %   Rotation matrix from tangent to body frame
    BcG = BcT*TcG;                                          %   Rotation matrix from ground to body frame
    vApp = BcG*vFlow;                                       %   m/s - Apparent flow velocity
    uApp = vApp./norm(vApp);                                %   Apparent velocity direction
    uAppL = cross(uApp,[0;1;0]);
    alph(i) = atan2(vApp(3),vApp(1))*180/pi;                       %   Angle of attack
    dynPS = .5*1000*obj.fluidRefArea.Value*norm(vApp)^2;
    CLw = interp1(alpha,CLwing,alph(i));
    CDw = interp1(alpha,CDwing,alph(i));
    CLh = interp1(alpha,CLstab,alph(i));
    CDh = interp1(alpha,CDstab,alph(i));
    CDv = interp1(alpha,CDvert,alph(i));
    CDf = interp1(alpha,CDfuse,alph(i));
    CLhs = ((CLw+CDw)*norm(CM.W)+CDv*norm(CM.V)+CDf*norm(CM.F))/norm(CM.H)-CDh;
    F.W = dynPS*(CLw*uAppL+CDw*uApp);
    F.H = dynPS*(CLh*uAppL+CDh*uApp);
    F.V = dynPS*CDv*uApp;
    F.F = dynPS*CDf*uApp;
    F.L(i) = sqrt(sum((F.W+F.H).^2));
    F.tot(:,i) = F.W+F.H+F.V+F.F;
    M.W = cross(CM.W,F.W);    M.H = cross(CM.H,F.H);
    M.V = cross(CM.V,F.V);    M.F = cross(CM.F,F.F);
    M.W1 = cross(LE.W,F.W);    M.H1 = cross(LE.H,F.H);
    M.V1 = cross(LE.V,F.V);    M.F1 = cross(LE.F,F.F);
    Mw(i) = M.W(2);  Mh(i) = M.H(2);  Mv(i) = M.V(2);  Mf(i) = M.F(2);
    Mw1(i) = M.W1(2);  Mh1(i) = M.H1(2);  Mv1(i) = M.V1(2);  Mf1(i) = M.F1(2);
    M.tot(:,i) = M.W+M.H+M.V+M.F;
    M.tot1(:,i) = M.W1+M.H1+M.V1+M.F1;
    M.a(:,i) = M.tot(:,i)+cross(D+obj.rCM_LE.Value,F.tot(:,i));
end
m.L = (F.L(end)-F.L(end-1))/(alph(end)-alph(end-1));
m.M = (M.tot(end)-M.tot(end-1))/(alph(end)-alph(end-1));
h = m.M/m.L;
if p.Results.pMom
    figure(fig+1); 
    subplot(2,1,sub); 
    hold on; grid on;
    plot(alph,M.tot(2,:),'color',col)
    xlabel('alpha [deg]');  ylabel('CM Pitch Moment [Nm]');  xlim(p.Results.xLim);
end
end