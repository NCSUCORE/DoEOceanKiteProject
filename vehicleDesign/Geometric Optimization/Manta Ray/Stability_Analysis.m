%%  Kite Design optimization
clc;clear;

%%  Input definitions 
loadComponent('Manta2RotNACA2412');                 %   Load vehicle 
% loadComponent('newManta2RotNACA2412');              %   Load vehicle 
% loadComponent('Manta2RotTest');                     %   Load vehicle 
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
hStab.LE = vhcl.hStab.rSurfLE_WingLEBdy.Value;
hStab.gainCL = vhcl.hStab.gainCL;                   %   change in hstab CL per deg deflection of elevator
hStab.gainCD = vhcl.hStab.gainCD;                   %   change in hstab CD per deg deflection of elevator

vStab.alpha = vhcl.vStab.alpha.Value;               %   Find index corresponding to 0 AoA
vStab.CD = vhcl.vStab.CD.Value;                     %   Horizontal stabilizer drag coefficient at zero alpha
vStab.S = vhcl.fluidRefArea.Value;                  %   Reference area for horizontal stabilizer
vStab.eD = 0.9;                                     %   Vertical stabilizer drag Oswald efficiency factor
vStab.aeroCent = [.1739 0 .9389]';                  %   Vertical stabilizer aero center
vStab.LE = vhcl.vStab.rSurfLE_WingLEBdy.Value;

fuse.CD0 = vhcl.fuse.endDragCoeff.Value;            %   Fuselage drag coefficient at 0° AoA
fuse.CDs = vhcl.fuse.sideDragCoeff.Value;           %   Fuselage drag coefficient at 90° AoA
fuse.L = vhcl.fuse.length.Value;                    %   m - Length of fuselage 
fuse.D = vhcl.fuse.diameter.Value;                  %   m - Fuselage diameter 

Sys.m = vhcl.mass.Value;                            %   kg - vehicle mass
Sys.B = 1;                                          %   Buoyancy factor
Sys.xg = vhcl.rCM_LE.Value-vhcl.fuse.rNose_LE.Value;%   m - Center of gravity w/ respect to nose
Sys.LE = -vhcl.fuse.rNose_LE.Value;                 %   m - wing leading edge 
Sys.xb = Sys.xg+vhcl.rCentOfBuoy_LE.Value-...       %   m - Center of buoyancy location 
    vhcl.rCM_LE.Value;
Sys.xbr = Sys.xg+[0 0 0]';                          %   m - Bridle location 
Sys.xW = Sys.LE+wing.aeroCent;                      %   m - Wing aerodynamic center location 
Sys.xH = Sys.LE+hStab.LE+hStab.aeroCent;            %   m - Horizontal stabilizer aerodynamic center location 
Sys.xV = Sys.LE+vStab.LE+vStab.aeroCent;            %   m - Vertical stabilizer aerodynamic center location 
Sys.vKite = [0 0 0]';                               %   m/s - Kite velocity 

Env.vFlow = [.25 0 0]';                             %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater
Env.g = 9.81;                                       %   m/s^2 - gravitational acceleration 
%%  Experimental Variables 
elevator = -30:.5:30;
pitch = -20:.1:20;
xb = -.1:.01:.1;
xbr = 0:.1:2;
%%  Position and Orientation Angles 
Ang.elevation = 30;                                     %   deg - Elevation angle
Ang.zenith = 90-Ang.elevation;                          %   deg - Zenith angle 
Ang.azimuth = 0;                                        %   deg - Azimuth angle 
Ang.roll = 0;                                           %   deg - Roll angle 
Ang.pitch = pitch;                                      %   deg - Pitch angle 
Ang.yaw = 0;                                            %   deg - Yaw angle 
Ang.heading = 0;                                        %   deg - Heading on the sphere; 0 = south; 90 = east; etc.
% Ang.tanPitch = Ang.pitch-90+Ang.elevation;              %   deg - Tangent pitch angle
%%  Analyze Stability 
pitchMomentXbrXb = zeros(numel(xbr),numel(xb),numel(Ang.pitch));
pitchXbrXb = zeros(numel(xbr),numel(xb));
for k = 1:numel(xbr)
    for j = 1:numel(xb)
        Sys.xb = Sys.xg+[xb(j) 0 .0546]';
        Sys.xbr = Sys.xg+[0 0 -xbr(j)]';
        for i = 1:numel(Ang.pitch)
            Ang.tanPitch = Ang.pitch(i)-90+Ang.elevation;
            [M,F,CL,CD] = staticAnalysis(Sys,Env,wing,hStab,vStab,fuse,Ang);
            pitchMomentXbrXb(k,j,i) = M.tot(2);
        end
        idx = find(abs(pitchMomentXbrXb(k,j,:)) <= 5);
        if isempty(idx)
            pitchXbrXb(k,j) = NaN;
        else
            pitchXbrXb(k,j) = Ang.pitch(round(median(idx)));
        end
    end
end
%%  Plotting 
% if numel(Ang.pitch) > 1
%     figure; hold on; grid on
%     plot(Ang.pitch,pitchMoment(2,:),'b-');  xlabel('$\theta$ [deg]');  ylabel('Pitch Moment')
% end
% figure; hold on; grid on
% plot(hStab.alpha-13.5,hStab.CL,'b-');  xlabel('$\theta$ [deg]');  ylabel('CLh')

figure; 
surf(xbr,xb,pitchXbrXb)
xlabel('Br$_z$ [m]');  ylabel('CB$_x$ [m]');  zlabel('$\theta_0$ [deg]')

% plotVehPolars(vhcl)
%%
function plotVehPolars(obj,varargin)
p = inputParser;
addParameter(p,'xLim',[-inf inf],@isnumeric);
parse(p,varargin{:})

alpha = obj.portWing.alpha.Value;
Aref = obj.fluidRefArea.Value;
Afuse = pi/4*obj.fuse.diameter.Value^2.*cosd(alpha)+...
    (pi/4*obj.fuse.diameter.Value^2+obj.fuse.diameter.Value*obj.fuse.length.Value).*(1-cosd(alpha));
CDfuse = (obj.fuse.endDragCoeff.Value.*cosd(alpha)+...
    obj.fuse.sideDragCoeff.Value.*(1-cosd(alpha))).*Afuse/Aref;
CLsurf = obj.portWing.CL.Value+obj.stbdWing.CL.Value+obj.hStab.CL.Value;
CDtot = obj.portWing.CD.Value+obj.stbdWing.CD.Value+obj.hStab.CD.Value+obj.vStab.CD.Value+CDfuse;

figure;subplot(2,1,1);hold on;grid on;
plot(alpha,CLsurf.^3./CDtot.^2,'b-');
plot(alpha,(obj.portWing.CL.Value+obj.stbdWing.CL.Value).^3./(obj.portWing.CD.Value+obj.stbdWing.CD.Value).^2,'r-')
xlabel('alpha [deg]');  ylabel('$\mathrm{CL^3/CD^2}$');  xlim(p.Results.xLim);
subplot(2,1,2);hold on;grid on;
plot(alpha,CLsurf./CDtot,'b-');
plot(alpha,(obj.portWing.CL.Value+obj.stbdWing.CL.Value)./(obj.portWing.CD.Value+obj.stbdWing.CD.Value),'r-')
xlabel('alpha [deg]');  ylabel('$\mathrm{CL/CD}$');  xlim(p.Results.xLim);
legend('kite','wing')
end