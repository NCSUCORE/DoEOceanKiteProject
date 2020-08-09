%%  Kite Design optimization
clc;clear;

%%  Input definitions 
loadComponent('Manta2RotNACA2412');                 %   Load vehicle 
wing.alpha = vhcl.portWing.alpha.Value;             %   Wing alpha vec
wing.AR = vhcl.portWing.AR.Value;                   %   Wing alpha vec
wing.b = 8;                                         %   Wing span
wing.S = vhcl.fluidRefArea.Value;                   %   Reference area for wing
wing.CL = vhcl.portWing.CL.Value;                   %   Wing lift coefficient at zero alpha
wing.CD = vhcl.portWing.CD.Value;                   %   Wing drag coefficient at zero alpha
wing.CD_visc = 0.0297;                              %   Wing viscous drag coefficient
wing.CD_ind = 0.2697;                               %   Wing induced drag coefficient
wing.Cfe = 0.003;                                   %   Wing skin-friction drag coefficient
wing.gamma = 1;                                     %   Wing airfoil lift curve slope multiplicative constant
wing.eL = 0.9;                                      %   Wing lift Oswald efficiency factor
wing.eD = 0.9;                                      %   Wing drag Oswald efficiency factor
wing.aeroCent = [.1807 0 0]';                       %   Wing aerodynamic center 
wing.E = 69e9;                                      %   Wing modulus of elasticity 

hStab.alpha = vhcl.hStab.alpha.Value;               %   Horizontal stabilizer alpha vec
hStab.CL = vhcl.hStab.CL.Value;                     %   Horizontal stabilizer lift coefficient
hStab.CD = vhcl.hStab.CD.Value;                     %   Horizontal stabilizer drag coefficient
hStab.AR = vhcl.hStab.AR.Value;                     %   Horizontal stabilizer aspect ratio 
hStab.S = vhcl.fluidRefArea.Value;                  %   Reference area for horizontal stabilizer
hStab.gamma = 1;                                    %   Horizontal stabilizer airfoil lift curve slope multiplicative constant
hStab.eL = 0.9;                                     %   Horizontal stabilizer lift Oswald efficiency factor
hStab.eD = 0.9;                                     %   Horizontal stabilizer drag Oswald efficiency factor
hStab.aeroCent = vhcl.hStab.rAeroCent_SurfLE.Value; %   Horizontal stabilizer aero center
hstab.dCLElevator = 0.08;                           %   change in hstab CL per deg deflection of elevator

vStab.alpha = vhcl.vStab.alpha.Value;               %   Find index corresponding to 0 AoA
vStab.CD = vhcl.vStab.CD.Value;                     %   Horizontal stabilizer drag coefficient at zero alpha
vStab.S = vhcl.fluidRefArea.Value;                  %   Reference area for horizontal stabilizer
vStab.eD = 0.9;                                     %   Vertical stabilizer drag Oswald efficiency factor
vStab.aeroCent = [.1739 0 .9389]';                  %   Vertical stabilizer aero center

fuse.CD0 = vhcl.fuse.endDragCoeff.Value;            %   Fuselage drag coefficient at 0° AoA
fuse.CDs = vhcl.fuse.sideDragCoeff.Value;           %   Fuselage drag coefficient at 90° AoA
fuse.L = vhcl.fuse.length.Value;                    %   m - Length of fuselage 
fuse.D = vhcl.fuse.diameter.Value;                  %   m - Fuselage diameter 

Sys.m = vhcl.mass.Value;                            %   kg - vehicle mass
Sys.B = 1;                                          %   Buoyancy factor
Sys.xg = [1.6 0 0]';                                %   m - Center of gravity w/ respect to nose
Sys.xb = Sys.xg+[.0171 0 .0546]';                   %   m - Center of buoyancy location 
Sys.xbr = Sys.xg+[0 0 0]';                          %   m - Bridle location 
Sys.xW = [1.6 0 0]'+wing.aeroCent;                  %   m - Wing aerodynamic center location 
Sys.xH = [6 0 0]'+hStab.aeroCent;                   %   m - Horizontal stabilizer aerodynamic center location 
Sys.xV = [5.88 0 0]'+vStab.aeroCent;                %   m - Vertical stabilizer aerodynamic center location 
Sys.vKite = [0 0 0]';                               %   m/s - Kite velocity 

Env.vFlow = [.25 0 0]';                             %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater
Env.g = 9.81;                                       %   m/s^2 - gravitational acceleration 
%%  Experimental Variables 
pitch = -20:.1:20;
xb = -.1:.01:.1;
xbr = 0:.1:2;
%%  Position and Orientation Angles 
Ang.elevation = 90;                                     %   deg - Elevation angle
Ang.zenith = 90-Ang.elevation;                          %   deg - Zenith angle 
Ang.azimuth = 0;                                        %   deg - Azimuth angle 
Ang.roll = 0;                                           %   deg - Roll angle 
Ang.pitch = pitch;                                      %   deg - Pitch angle 
Ang.yaw = 0;                                            %   deg - Yaw angle 
Ang.heading = 0;                                        %   deg - Heading on the sphere; 0 = south; 90 = east; etc.
% Ang.tanPitch = Ang.pitch-90+Ang.elevation;              %   deg - Tangent pitch angle
%%  Analyze Stability 
pitchMomentXb = zeros(numel(xb),numel(Ang.pitch));
pitchMomentXbr = zeros(numel(xbr),numel(Ang.pitch));
pitchXb = zeros(numel(xb),0);
pitchXbr = zeros(numel(xbr),0);
for j = 1:numel(xb)
    Sys.xb = Sys.xg+[xb(j) 0 .0546]';
    for i = 1:numel(Ang.pitch)
        Ang.tanPitch = Ang.pitch(i)-90+Ang.elevation;
        [M,F,CL,CD] = staticAnalysis(Sys,Env,wing,hStab,vStab,fuse,Ang);
        pitchMomentXb(j,i) = M.tot(2);
    end
    idx = find(abs(pitchMomentXb(j,:)) <= 5);
    if isempty(idx)
        pitchXb(j) = NaN;
    else
        pitchXb(j) = Ang.pitch(round(median(idx)));
    end
end
for j = 1:numel(xbr)
    Sys.xb = Sys.xg+[0 0 .0546]';
    Sys.xbr = Sys.xg+[0 0 -xbr(j)]';
    for i = 1:numel(Ang.pitch)
        Ang.tanPitch = Ang.pitch(i)-90+Ang.elevation;
        [M,F,CL,CD] = staticAnalysis(Sys,Env,wing,hStab,vStab,fuse,Ang);
        pitchMomentXbr(j,i) = M.tot(2);
    end
    idx = find(abs(pitchMomentXbr(j,:)) <= 5);
    if isempty(idx)
        pitchXbr(j) = NaN;
    else
        pitchXbr(j) = Ang.pitch(round(median(idx)));
    end
end
%%  Plotting 
% if numel(Ang.pitch) > 1
%     figure; hold on; grid on
%     plot(Ang.pitch,pitchMoment(2,:),'b-');  xlabel('$\theta$ [deg]');  ylabel('Pitch Moment')
% end
% figure; hold on; grid on
% plot(hStab.alpha-13.5,hStab.CL,'b-');  xlabel('$\theta$ [deg]');  ylabel('CLh')
figure; subplot(2,1,1); hold on; grid on
plot(xb,pitchXb,'b-');  xlabel('CB$_x$ [m]');  ylabel('$\theta_0$ [deg]')
subplot(2,1,2); hold on; grid on
plot(xbr,pitchXbr,'b-');  xlabel('CBr$_z$ [m]');  ylabel('$\theta_0$ [deg]')

    
    