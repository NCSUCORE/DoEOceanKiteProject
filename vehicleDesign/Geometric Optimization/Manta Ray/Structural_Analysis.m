%%  Kite Design optimization
clc;clear;

%%  Input definitions 
loadComponent('Manta2RotXFoil_PDR');             %   AR = 8; 8m span

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
wing.E = 75e9;                                     %   Wing modulus of elasticity 

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
[Ixx_opt,Ixx_req,thk,Mtot,Wingdim,delX] = structOpt(wing,hStab,vStab,fuse,Env,loads);
fprintf('\nFuselage Thickness = %.1f mm\nWing Skin Thickness = %.1f mm\nSpar 1 Thickness = %.1f mm\nSpar 2 Thickness = %.1f mm\nTip Deflection = %.1f mm\n',thk*1e3,Wingdim(1)*wing.c*.12e3,Wingdim(2)*wing.c*1e3,Wingdim(3)*wing.c*1e3,delX*1e3)
%%
function [Ixx_calc,Ixx_req,thk,Mtot,Wingdim,delX] = structOpt(wing,hStab,vStab,fuse,Env,loads)

chord = wing.c;
span = wing.b;
Df = fuse.D;
Lf = fuse.L;

P = loads.Wp;
L = span/2;
a = span/4;
delx = span/2*.05;
Ixx_req = (39.37^4)*P*a^2*(3*L-a)/(6*wing.E*delx);

Skn = 0.066; Sp1 = 0.04; Sp2 = 0.03; 
[Ixx_calc,area_skin,area_spar1,area_spar2] = App_Wing_MoICalc_old(chord,Skn,Sp1,Sp2);
Ixx_calc = Ixx_calc*(39.37^4);
area_opt = area_skin+area_spar1+area_spar2;
Mwing = area_opt*span*Env.rho;

[Mfuse,thk,~] = fuseAnalysis(Df,Lf,fuse,wing,hStab,vStab,loads);
Mtot = Mfuse+Mwing;
Wingdim = [Skn Sp1 Sp2];

delX = P*a^2*(3*L-a)/(6*wing.E*Ixx_calc/(39.37^4));
end
function [Mfuse,thk,exitflag] = fuseAnalysis(D,L,fuse,~,~,~,loads)
DecVar.L = L;  % shear stress calc
DecVar.D = D; %decision variable 

Forces.FzW = loads.Wp+loads.Ws; 
Forces.FzH = loads.H; 
Forces.Thr = loads.T;
pos.W = fuse.rWing;
pos.H = fuse.rStab;
pos.T = fuse.rBrid;

%% Input parameters 
Inp.fos = 5;              %factor of safety 
Inp.Syield = 2.068427e+9;         %yield stress 

% Internal, external and dynamic pressures
Inp.IntP = 10^5; 
Inp.ExtP = 2.2e5; 
Inp.DynP = 5e4; 

% Densities  
Inp.rhow = 1000; 
Inp.rhoAl = 1800; 
Inp.tarBuoy = 1; 

%% 
% lb = 0.01; 
% ub = 0.03;
uopt = 0.01; 

Jopt = DLCalc_cost(DecVar,uopt);
% C = @(u)DLCalc_constraint(u,Forces,DecVar,Inp,pos);

% options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',1e7,'MaxIterations',1e7);
% [uopt, Jopt, exitflag] = fmincon(J,u0,[],[],[],[],lb,ub,C,options);

Mfuse = Jopt*pi*Inp.rhoAl;
thk = uopt; 
exitflag = 1;
% end 




%% functions 
function J = DLCalc_cost(DecVar,u)
r = 0.5*DecVar.D; 
l = DecVar.L; 

J = (u^2 + 2*u*r)*l; 
end 

function [c_ineq, c_eq] = DLCalc_constraint(u,Forces,DecVar,Inp,Pos)
r = 0.5*DecVar.D; 

% Length from shear stress 
ineq1 = (Forces.FzW+Forces.FzH)/(pi*(r^2-(r-u)^2)) - 1/Inp.fos*Inp.Syield; 

% Radius for hoop stress due to shear  
Pdiff = Inp.ExtP + Inp.DynP - Inp.IntP; 
ineq2 = (Pdiff*r)/u - 1/Inp.fos*Inp.Syield; 

% Buckling of fuselage  
BMmax = Forces.FzW*(Pos.T-Pos.W); %max bending moment
SMod = pi*r^2*u; 
ineq3 = BMmax/SMod - 1/Inp.fos*Inp.Syield;

% Neutral buoyancy 
eq4 = Inp.rhoAl*(u^2 + 2*r*u) - Inp.rhow*r^2 - Inp.tarBuoy; 

c_ineq = [ineq1; ineq2; ineq3];  
c_eq = eq4; 

end 

end 