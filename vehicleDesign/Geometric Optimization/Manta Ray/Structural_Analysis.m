%%  Kite Design optimization
clc;clear;

%%  Input definitions 
loadComponent('Manta2RotXFoil_AR8_b8');             %   AR = 8; 8m span

loads.Wp = 15e3;
loads.Ws = 15e3;
loads.H = 6.3e3;
loads.T = 38e3;

wing.alpha = vhcl.portWing.alpha.Value;             %   Wing alpha vec
wing.AR = vhcl.portWing.AR.Value;                   %   Wing alpha vec
wing.c = vhcl.portWing.MACLength.Value;
wing.b = vhcl.portWing.halfSpan.Value*2;                                         %   Wing span
wing.S = vhcl.fluidRefArea.Value;                   %   Reference area for wing
wing.CL = vhcl.portWing.CL.Value;                   %   Wing lift coefficient at zero alpha
wing.CD = vhcl.portWing.CD.Value;                   %   Wing drag coefficient at zero alpha
wing.aeroCent = ...                                 %   Wing aerodynamic center 
    [vhcl.portWing.rAeroCent_SurfLE.Value(1) 0 0]';
wing.E = 181e9;                                     %   Wing modulus of elasticity 

hStab.alpha = vhcl.hStab.alpha.Value;               %   Horizontal stabilizer alpha vec
hStab.CL = vhcl.hStab.CL.Value;                     %   Horizontal stabilizer lift coefficient
hStab.CD = vhcl.hStab.CD.Value;                     %   Horizontal stabilizer drag coefficient
hStab.AR = vhcl.hStab.AR.Value;                     %   Horizontal stabilizer aspect ratio 
hStab.S = vhcl.fluidRefArea.Value;                  %   Reference area for horizontal stabilizer
hStab.aeroCent = vhcl.hStab.rAeroCent_SurfLE.Value; %   Horizontal stabilizer aero center

vStab.alpha = vhcl.vStab.alpha.Value;               %   Find index corresponding to 0 AoA
vStab.CD = vhcl.vStab.CD.Value;                     %   Horizontal stabilizer drag coefficient at zero alpha
vStab.S = vhcl.fluidRefArea.Value;                  %   Reference area for horizontal stabilizer
vStab.aeroCent = vhcl.vStab.rAeroCent_SurfLE.Value;                  %   Vertical stabilizer aero center

fuse.CD0 = vhcl.fuse.endDragCoeff.Value;            %   Fuselage drag coefficient at 0° AoA
fuse.CDs = vhcl.fuse.sideDragCoeff.Value;           %   Fuselage drag coefficient at 90° AoA
fuse.L = vhcl.fuse.length.Value;                    %   m - Length of fuselage 
fuse.D = vhcl.fuse.diameter.Value;                  %   m - Fuselage diameter 
fuse.CM = -vhcl.fuse.rNose_LE.Value(1)+...
    vhcl.rCM_LE.Value(1);
fuse.rWing = -vhcl.fuse.rNose_LE.Value(1);
fuse.rStab = fuse.rWing+vhcl.hStab.rSurfLE_WingLEBdy.Value(1);
fuse.rBrid = fuse.rWing+vhcl.rBridle_LE.Value(1);
Env.vFlow = [0.5 0 0]';                             %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater
Env.g = 9.81;                                       %   m/s^2 - gravitational acceleration 
%%
[Ixx_opt,Ixx_req,thk,Mtot,Wingdim] = structOpt(wing,hStab,vStab,fuse,Env,loads);
fprintf('\nFuselage Thickness = %.1f mm\nWing Skin Thickness = %.1f mm\nSpar 1 Thickness = %.1f mm\nSpar 2 Thickness = %.1f mm\n',thk*1e3,Wingdim(1)*wing.c*.12e3,Wingdim(2)*wing.c*1e3,Wingdim(3)*wing.c*1e3)
%%
function [Ixx_calc,Ixx_req,thk,Mtot,Wingdim] = structOpt(wing,hStab,vStab,fuse,Env,loads)

chord = wing.c;
span = wing.b;
AR = wing.AR;
volume = chord*span^3/AR^2/2;
Df = fuse.D;
Lf = fuse.L;

P = loads.Wp;
L = span/2;
a = span/4;
delx = span/2*.05;
Ixx_req = (39.37^4)*P*a^3*(3*L-a)/(6*wing.E*delx);

Skn = 0.06; Sp1 = 0.05; Sp2 = 0.03; 
[Ixx_calc,area_skin,area_spar1,area_spar2] = App_Wing_MoICalc_old(chord,Skn,Sp1,Sp2);
Ixx_calc = Ixx_calc*(39.37^4);
area_opt = area_skin+area_spar1+area_spar2;
Mwing = area_opt*span*Env.rho;

[Mfuse,thk,~] = App_SFDT2(Df,Lf,fuse,wing,hStab,vStab,loads);
Mtot = Mfuse+Mwing;
Wingdim = [Skn Sp1 Sp2];
% Fthk = 0;
% Mtot = 0;
% Wingdim = 0;
end
