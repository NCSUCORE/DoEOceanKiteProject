function [M,F,CLh,CLhReq] = hStabCLcalc(Sys,Env,wing,hStab,vStab,~,Ang)
%%  Rotation Matrices 
% Rx = @(x) [1 0 0;0 cosd(x) sind(x);0 -sind(x) cosd(x)]; %   Rotation matrix for rotations about the x-axis 
Ry = @(x) [cosd(x) 0 -sind(x);0 1 0;sind(x) 0 cosd(x)]; %   Rotation matrix for rotations about the y-axis 
Rz = @(x) [cosd(x) sind(x) 0;-sind(x) cosd(x) 0;0 0 1]; %   Rotation matrix for rotations about the z-axis
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
%   Lift Forces
CLw =         2*interp1(wing.alphaw*pi/180,wing.CLw,alpha,'linear','extrap');
CLh = (hStab.Sh/wing.Sw)*interp1(hStab.alphah*pi/180,hStab.CLh,alpha,'linear','extrap');
F.liftBw = 1/2*Env.rho*CLw*wing.Sw*norm(vApp)^2*cross(uApp,[0;1;0]);
F.liftBh = 1/2*Env.rho*CLh*hStab.Sh*norm(vApp)^2*cross(uApp,[0;1;0]);
%   Drag Forces
CDw =         2*interp1(wing.alphaw*pi/180,wing.CDw,alpha,'linear','extrap');
CDh = (hStab.Sh/wing.Sw)*interp1(hStab.alphah*pi/180,hStab.CDh,alpha,'linear','extrap');
CDv = (vStab.Sv/wing.Sw)*interp1(vStab.alphav*pi/180,vStab.CDv,alpha,'linear','extrap');
F.dragBw = 1/2*Env.rho*CDw*wing.Sw*norm(vApp)^2*uApp;
F.dragBh = 1/2*Env.rho*CDh*hStab.Sh*norm(vApp)^2*uApp;
F.dragBv = 1/2*Env.rho*CDv*vStab.Sv*norm(vApp)^2*uApp;
%   Tether Force
Fnet = F.buoyB+F.gravB+F.liftBw+F.liftBh ...
        +F.dragBw+F.dragBh+F.dragBv;
thrForce = -dot(TcB*Fnet,[0;0;1]);
F.thrB = BcT*[0;0;thrForce];                                %   N - Tether force in the body frame
%%  Moment Calculations
M.buoyB = cross(Sys.xb-Sys.xg,F.buoyB);                     %   Nm - Buoyancy moment
M.dragBh = cross(Sys.xH-Sys.xg,F.dragBh);                   %   Nm - Horizontal stabilizer drag moment
M.W = cross(Sys.xW-Sys.xg,F.liftBw+F.dragBw);               %   Nm - Wing moment
M.H = cross(Sys.xH-Sys.xg,F.liftBh+F.dragBh);               %   Nm - Horizontal stabilizer moment
M.V = cross(Sys.xV-Sys.xg,F.dragBv);                        %   Nm - Vertical stabilizer moment
M.thr = cross(Sys.xbr-Sys.xg,F.thrB);                       %   Nm - Tether moment
M.tot = M.buoyB+M.W+M.H+M.V+M.thr;                          %   Nm - Total moment
CLhReq = 2*dot(M.buoyB+M.W+M.V+M.thr+M.dragBh,[0;1;0])...
            /(Env.rho*hStab.Sh*norm(vApp)^2*norm(Sys.xH-Sys.xg));
F.liftBhReq = 1/2*Env.rho*CLhReq*hStab.Sh*norm(vApp)^2*cross(uApp,[0;1;0]);
M.HReq = cross(Sys.xH-Sys.xg,F.liftBhReq+F.dragBh);               %   Nm - Horizontal stabilizer moment
M.totReq = M.buoyB+M.W+M.HReq+M.V+M.thr;                          %   Nm - Total moment
end

