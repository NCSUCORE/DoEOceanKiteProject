function [MCM,MBR,MLE,F,CLCM,CLBR,CLLE,CD,Theta0] = staticAnalysis(Sys,Env,wing,hStab,vStab,fuse,Ang,CM,LE,BR)
%%  Rotation Matrices 
% Rx = @(x) [1 0 0;0 cosd(x) sind(x);0 -sind(x) cosd(x)]; %   Rotation matrix for rotations about the x-axis 
% Ry = @(x) [cosd(x) 0 -sind(x);0 1 0;sind(x) 0 cosd(x)]; %   Rotation matrix for rotations about the y-axis 
% Rz = @(x) [cosd(x) sind(x) 0;-sind(x) cosd(x) 0;0 0 1]; %   Rotation matrix for rotations about the z-axis
%%  Important Variables 
TcG = Ry(Ang.zenith)*Rz(Ang.azimuth);                   %   Rotation matrix from ground to tangent frame 
BcT = Ry(Ang.tanPitch)*Rz(Ang.heading);                 %   Rotation matrix from tangent to body frame 
TcB = transpose(BcT);                                   %   Rotation matrix from body to tangent frame 
BcG = BcT*TcG;                                          %   Rotation matrix from ground to body frame 

vApp = BcG*Env.vFlow-Sys.vKite;                         %   m/s - Apparent flow velocity
uApp = vApp./norm(vApp);                                %   Apparent velocity direction
alpha = atan2(vApp(3),vApp(1));                         %   Angle of attack
%%  Force Calculations
F.gravG = [0 0 -Sys.m*Env.g]';                          %   N - Gravitational force
F.gravB = BcG*F.gravG;                                  %   N - Gravitational force (body)
F.buoyG = -F.gravG*Sys.B;                               %   N - Buoyancy force
F.buoyB = BcG*F.buoyG;                                  %   N - Buoyancy force (body)
[CL,CD,fuse] = getCLCD(alpha,wing,hStab,vStab,fuse);
%   Lift Forces
F.liftBw = 1/2*Env.rho*CL.W*wing.S*norm(vApp)^2*cross(uApp,[0;1;0]);
F.liftBh = 1/2*Env.rho*CL.H*hStab.S*norm(vApp)^2*cross(uApp,[0;1;0]);
%   Drag Forces
F.dragBw = 1/2*Env.rho*CD.W*wing.S*norm(vApp)^2*uApp;
F.dragBh = 1/2*Env.rho*CD.H*hStab.S*norm(vApp)^2*uApp;
F.dragBv = 1/2*Env.rho*CD.V*vStab.S*norm(vApp)^2*uApp;
F.dragBf = 1/2*Env.rho*CD.F*fuse.S*norm(vApp)^2*uApp;
%   Tether Force
Fnet = F.buoyB+F.gravB+F.liftBw+F.liftBh+F.dragBw+F.dragBh+F.dragBv+F.dragBf;
thrForce = -dot(TcB*Fnet,[0;0;1]);
F.thrB = BcT*[0;0;thrForce];                        %   N - Tether force in the body frame
F.thrB = -Fnet;                                     %   N - Tether force during static equilibrium 
Theta0 = atan2(-F.thrB(3),-F.thrB(1))*180/pi;         %   deg - Steady-state elevation angle 
%%  Moment Calculations
%%  About the CM
M.B = cross(CM.xb,F.buoyB);                         %   Nm - Buoyancy moment
M.G = cross(CM.xb,F.gravB);                         %   Nm - Gravitational moment
M.dH = cross(CM.xH,F.dragBh);                       %   Nm - Horizontal stabilizer drag moment
M.W = cross(CM.xW,F.liftBw+F.dragBw);               %   Nm - Wing moment
M.H = cross(CM.xH,F.liftBh+F.dragBh);               %   Nm - Horizontal stabilizer moment
M.V = cross(CM.xV,F.dragBv);                        %   Nm - Vertical stabilizer moment
M.F = cross(CM.xf,F.dragBf);                        %   Nm - Fuselage moment
M.T = cross(CM.xbr,F.thrB);                         %   Nm - Tether moment
M.tot = M.B + M.G + M.W + M.H + M.V + M.F + M.T;    %   Nm - Total moment
MCM = M;
%%  About the tether attachment point 
M.B = cross(BR.xb,F.buoyB);                         %   Nm - Buoyancy moment
M.G = cross(BR.xb,F.gravB);                         %   Nm - Gravitational moment
M.dH = cross(BR.xH,F.dragBh);                       %   Nm - Horizontal stabilizer drag moment
M.W = cross(BR.xW,F.liftBw+F.dragBw);               %   Nm - Wing moment
M.H = cross(BR.xH,F.liftBh+F.dragBh);               %   Nm - Horizontal stabilizer moment
M.V = cross(BR.xV,F.dragBv);                        %   Nm - Vertical stabilizer moment
M.F = cross(BR.xf,F.dragBf);                        %   Nm - Fuselage moment
M.T = cross(BR.xbr,F.thrB);                         %   Nm - Tether moment
M.tot = M.B + M.G + M.W + M.H + M.V + M.F + M.T;    %   Nm - Total moment
MBR = M;
%%  About the LE
M.B = cross(LE.xb,F.buoyB);                         %   Nm - Buoyancy moment
M.G = cross(LE.xb,F.gravB);                         %   Nm - Gravitational moment
M.dH = cross(LE.xH,F.dragBh);                       %   Nm - Horizontal stabilizer drag moment
M.W = cross(LE.xW,F.liftBw+F.dragBw);               %   Nm - Wing moment
M.H = cross(LE.xH,F.liftBh+F.dragBh);               %   Nm - Horizontal stabilizer moment
M.V = cross(LE.xV,F.dragBv);                        %   Nm - Vertical stabilizer moment
M.F = cross(LE.xf,F.dragBf);                        %   Nm - Fuselage moment
M.T = cross(LE.xbr,F.thrB);                         %   Nm - Tether moment
M.tot = M.B + M.G + M.W + M.H + M.V + M.F + M.T;    %   Nm - Total moment
MLE = M;
%%  Find required horizontal stabilizer CL for trim
[MCM,F,CLCM] = getReqStab(MCM,F,CM,Env,hStab,vApp,uApp);
[MBR,F,CLBR] = getReqStab(MBR,F,BR,Env,hStab,vApp,uApp);
[MLE,F,CLLE] = getReqStab(MLE,F,LE,Env,hStab,vApp,uApp);
end
%%  Local functions 
function C = Rx(x)
C = [1 0 0; 0 cosd(x) sind(x); 0 -sind(x) cosd(x)];
end
function C = Ry(x)
C = [cosd(x) 0 -sind(x); 0 1 0; sind(x) 0 cosd(x)];
end
function C = Rz(x)
C = [cosd(x) sind(x) 0; -sind(x) cosd(x) 0; 0 0 1];
end
function [CL,CD,fuse] = getCLCD(alpha,wing,hStab,vStab,fuse)
fuse.S = pi/4*fuse.D^2.*cosd(alpha)+(pi/4*fuse.D^2+fuse.D*fuse.L).*(1-cosd(alpha));
%   Lift Coefficients 
CL.W =         2*interp1(wing.alpha*pi/180,wing.CL,alpha,'linear','extrap');
CL.H = (hStab.S/wing.S)*interp1((hStab.alpha)*pi/180,hStab.CL,alpha,'linear','extrap');
CLwa = 2*pi/(1+(2*pi/pi*wing.eL*wing.AR));
CLha = 2*pi/(1+(2*pi/pi*hStab.eL*hStab.AR));
CL.Wa = CLwa*alpha*pi/180 + 2*interp1(wing.alpha*pi/180,wing.CL,0,'linear','extrap');
CL.Ha = CLha*alpha*pi/180 + interp1(hStab.alpha*pi/180,hStab.CL,0,'linear','extrap');
%   Drag Coefficients
CD.W =                2*interp1(wing.alpha*pi/180,wing.CD,alpha,'linear','extrap');
CD.H = (hStab.S/wing.S)*interp1((hStab.alpha)*pi/180,hStab.CD,alpha,'linear','extrap');
CD.V = (vStab.S/wing.S)*interp1(vStab.alpha*pi/180,vStab.CD,alpha,'linear','extrap');
CD.Fa = (fuse.S/wing.S)*(fuse.CD0.*cosd(alpha)+fuse.CDs.*(1-cosd(alpha)));
CD.F =                 (fuse.CD0.*cosd(alpha)+fuse.CDs.*(1-cosd(alpha)));
CD.Wa = CL.Wa^2/(pi*wing.eD*wing.AR);
CD.Ha = CL.Ha^2/(pi*hStab.eD*hStab.AR);
end
function [M,F,CL] = getReqStab(M,F,A,Env,hStab,vApp,uApp)
CL.hReq = 2*dot(M.B+M.G+M.W+M.V+M.F+M.T+M.dH,[0;1;0])...
            /(Env.rho*hStab.S*norm(vApp)^2*norm(A.xH));
F.liftBhReq = 1/2*Env.rho*CL.hReq*hStab.S*norm(vApp)^2*cross(uApp,[0;1;0]);
M.HReq = cross(A.xH,F.liftBhReq+F.dragBh);               %   Nm - Horizontal stabilizer moment
M.totReq = M.B+M.G+M.W+M.HReq+M.V+M.T;                          %   Nm - Total moment
end




