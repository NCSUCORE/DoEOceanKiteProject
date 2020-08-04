%%  Kite Design optimization
% clc;clear;

%%  Input definitions 
loadComponent('Manta2RotNACA2412');                 %   Load vehicle 
wing.alphaw = vhcl.portWing.alpha.Value;            %   Wing alpha vec
wing.ARw = vhcl.portWing.AR.Value;                  %   Wing alpha vec
wing.bw = 8;                                        %   Wing span
wing.Sw = vhcl.fluidRefArea.Value;                  %   Reference area for wing
wing.CLw = vhcl.portWing.CL.Value;                  %   Wing lift coefficient at zero alpha
wing.CDw = vhcl.portWing.CD.Value;                  %   Wing drag coefficient at zero alpha
wing.CDw_visc = 0.0297;                             %   Wing viscous drag coefficient
wing.CDw_ind = 0.2697;                              %   Wing induced drag coefficient
wing.Cfe = 0.003;                                   %   Wing skin-friction drag coefficient
wing.gammaw = 1;                                    %   Wing airfoil lift curve slope multiplicative constant
wing.eLw = 0.9;                                     %   Wing lift Oswald efficiency factor
wing.eDw = 0.9;                                     %   Wing drag Oswald efficiency factor
wing.aeroCent = [.1807 0 0]';                       %   Wing aerodynamic center 
wing.E = 69e9;                                      %   Wing modulus of elasticity 

hStab.alphah = vhcl.hStab.alpha.Value;              %   Horizontal stabilizer alpha vec
hStab.CLh = vhcl.hStab.CL.Value;                    %   Horizontal stabilizer lift coefficient
hStab.CDh = vhcl.hStab.CD.Value;                    %   Horizontal stabilizer drag coefficient
hStab.ARh = vhcl.hStab.AR.Value;                    %   Horizontal stabilizer aspect ratio 
hStab.Sh = vhcl.fluidRefArea.Value;                 %   Reference area for horizontal stabilizer
hStab.gammah = 1;                                   %   Horizontal stabilizer airfoil lift curve slope multiplicative constant
hStab.eLh = 0.9;                                    %   Horizontal stabilizer lift Oswald efficiency factor
hStab.eDh = 0.9;                                    %   Horizontal stabilizer drag Oswald efficiency factor
hStab.aeroCent = vhcl.hStab.rAeroCent_SurfLE.Value; %   Horizontal stabilizer aero center

vStab.alphav = vhcl.vStab.alpha.Value;              %   Find index corresponding to 0 AoA
vStab.CDv = vhcl.vStab.CD.Value;                    %   Horizontal stabilizer drag coefficient at zero alpha
vStab.Sv = vhcl.fluidRefArea.Value;                 %   Reference area for horizontal stabilizer
vStab.eDv = 0.9;                                    %   Vertical stabilizer drag Oswald efficiency factor
vStab.aeroCent = [.1739 0 .9389]';                  %   Vertical stabilizer aero center

fuse.CD0f = vhcl.fuse.endDragCoeff.Value;           %   Fuselage drag coefficient at 0° AoA
fuse.CD9f = vhcl.fuse.sideDragCoeff.Value;          %   Fuselage drag coefficient at 90° AoA

Sys.m = vhcl.mass.Value;                            %   kg - vehicle mass
Sys.B = 1;                                          %   Buoyancy factor
Sys.xg = [0 0 0]';                               %   m - Center of gravity w/ respect to nose
Sys.xb = Sys.xg+[.0171 0 .0546]';                   %   m - Center of buoyancy
Sys.xbr = Sys.xg+[0 0 0]';                          %   m - Bridle location 
Sys.xW = Sys.xg+[0 0 0]'+wing.aeroCent;             %   m - Wing aerodynamic center 
Sys.xH = Sys.xg+[4.4 0 0]'+hStab.aeroCent;          %   m - Horizontal stabilizer aerodynamic center 
Sys.xV = Sys.xg+[4.28 0 0]'+vStab.aeroCent;         %   m - Vertical stabilizer aerodynamic center 
Sys.vKite = [0 0 0]';                               %   m/s - Kite velocity 

Env.vFlow = [.25 0 0]';                             %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater
Env.g = 9.81;                                       %   m/s^2 - gravitational acceleration 

%%  Rotation Matrices 
Rx = @(x) [1 0 0;0 cosd(x) sind(x);0 -sind(x) cosd(x)];
Ry = @(x) [cosd(x) 0 -sind(x);0 1 0;sind(x) 0 cosd(x)];
Rz = @(x) [cosd(x) sind(x) 0;-sind(x) cosd(x) 0;0 0 1];

%%  Euler Angles 
Theta = 40;                                         %   deg - Elevation angle
phi = 0;                                            %   deg - roll
theta = -(-20:.5:20)*pi/180;                         %   deg - pitch
psi = 0;                                            %   deg - yaw
M.tot = zeros(3,numel(theta));
for i = 1:numel(theta)
    vApp = Ry(theta(i))*Env.vFlow-Sys.vKite;                %   m/s - Apparent flow velocity
    uApp = vApp./norm(vApp);                                %   Apparent velocity direction
    alpha = atan2(vApp(3),vApp(1));                         %   Angle of attack
    BcT = Ry(theta(i))*Rz(psi);
    %%  Force Calculations
    F.gravG = [0 0 -Sys.m*Env.g]';                          %   N - Gravitational force
    F.gravB = Ry(theta(i))*F.gravG;                         %   N - Gravitational force (body)
    F.buoyG = -F.gravG*Sys.B;                               %   N - Buoyancy force
    F.buoyB = Ry(theta(i))*F.buoyG;                         %   N - Buoyancy force (body)
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
    
    %%  Moment Calculations
    M.buoyB = cross(Sys.xb,F.buoyB);                    %   Nm - Buoyancy moment
    M.liftBw = cross(Sys.xW,F.liftBw);                  %   Nm - Wing lift moment
    M.liftBh = cross(Sys.xH,F.liftBh);                  %   Nm - Horizontal stabilizer lift moment
    M.dragBw = cross(Sys.xW,F.dragBw);                  %   Nm - Wing drag moment
    M.dragBh = cross(Sys.xH,F.dragBh);                  %   Nm - Horizontal stabilizer drag moment
    M.dragBv = cross(Sys.xV,F.dragBv);                  %   Nm - Vertical stabilizer drag moment
%     M.buoyB = cross(F.buoyB,Sys.xb);                    %   Nm - Buoyancy moment
%     M.liftBw = cross(F.liftBw,Sys.xW);                  %   Nm - Wing lift moment
%     M.liftBh = cross(F.liftBh,Sys.xH);                  %   Nm - Horizontal stabilizer lift moment
%     M.dragBw = cross(F.dragBw,Sys.xW);                  %   Nm - Wing drag moment
%     M.dragBh = cross(F.dragBh,Sys.xH);                  %   Nm - Horizontal stabilizer drag moment
%     M.dragBv = cross(F.dragBv,Sys.xV);                  %   Nm - Vertical stabilizer drag moment
    M.tot(:,i) = M.buoyB+M.liftBw+M.liftBh+M.dragBw...  %   Nm - Total moment
        +M.dragBh+M.dragBv;
end

%%  Plotting 
figure; hold on; grid on
plot(theta*180/pi,M.tot(2,:),'b-');  xlabel('$\theta$ [deg]');  ylabel('Pitch Moment')