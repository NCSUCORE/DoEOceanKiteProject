function [Ixx_calc,Ixx_req,Fthk,Mtot,Wingdim] = runStructOpt(wing,hStab,vStab,fuse,Env,loads)

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

Skn = 0.025; Sp1 = 0.04; Sp2 = 0.02; 
[Ixx_calc,area_skin,area_spar1,area_spar2] = App_Wing_MoICalc_old(chord,Skn,Sp1,Sp2);
Ixx_calc = Ixx_calc*(39.37^4);
area_opt = area_skin+area_spar1+area_spar2;
% Mwing = area_opt*S_opt*in.rhow;

% [Mfuse,Fthk,~] = App_SFDT2(Df,Lf,Fmax);
% Mtot = Mfuse+Mwing;
% Wingdim = Wopt;
Fthk = 0;
Mtot = 0;
Wingdim = 0;
end

