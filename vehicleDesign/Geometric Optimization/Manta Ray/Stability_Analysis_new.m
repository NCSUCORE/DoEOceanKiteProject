%%  Kite Design optimization
clc;clear;

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
fuse.L = vhcl.fuse.length.Value;                    %   m - Length of fuselage 

Sys.m = vhcl.mass.Value;                            %   kg - vehicle mass
Sys.B = 1;                                          %   Buoyancy factor
Sys.xg = [1.6 0 0]';                                %   m - Center of gravity w/ respect to nose
Sys.xb = Sys.xg+[.0171 0 .0546]';                   %   m - Center of buoyancy location 
Sys.xbr = Sys.xg+[0 0 0]';                         %   m - Bridle location 
Sys.xW = [1.6 0 0]'+wing.aeroCent;                  %   m - Wing aerodynamic center location 
Sys.xH = [6 0 0]'+hStab.aeroCent;                   %   m - Horizontal stabilizer aerodynamic center location 
Sys.xV = [5.88 0 0]'+vStab.aeroCent;                %   m - Vertical stabilizer aerodynamic center location 

Sys.vKite = [0 0 0]';                               %   m/s - Kite velocity 

Env.vFlow = [.25 0 0]';                             %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater
Env.g = 9.81;                                       %   m/s^2 - gravitational acceleration 

%%  Position and Orientation Angles 
Ang.elevation = 40;                                     %   deg - Elevation angle
Ang.zenith = 90-Ang.elevation;                          %   deg - Zenith angle 
Ang.azimuth = 0;                                        %   deg - Azimuth angle 
Ang.roll = 0;                                           %   deg - Roll angle 
Ang.pitch = 0;                                          %   deg - Pitch angle 
Ang.yaw = 0;                                            %   deg - Yaw angle 
Ang.heading = 0;                                        %   deg - Heading on the sphere; 0 = south; 90 = east; etc.
% Ang.tanPitch = Ang.pitch-90+Ang.elevation;              %   deg - Tangent pitch angle
%%  Analyze Stability 
pitchMoment = zeros(3,numel(Ang.pitch));
for i = 1:numel(Ang.pitch)
    Ang.tanPitch = Ang.pitch(i)-90+Ang.elevation;              %   deg - Tangent pitch angle
    [M,F,CLh,CLhReq] = hStabCLcalc(Sys,Env,wing,hStab,vStab,fuse,Ang);
    pitchMoment(:,i) = M.tot;
end

%%  Plotting 
if numel(Ang.pitch) > 1
    figure; hold on; grid on
    plot(Ang.pitch,pitchMoment(2,:),'b-');  xlabel('$\theta$ [deg]');  ylabel('Pitch Moment')
end
% figure; hold on; grid on
% plot(hStab.alphah-13.5,hStab.CLh,'b-');  xlabel('$\theta$ [deg]');  ylabel('CLh')

    
    