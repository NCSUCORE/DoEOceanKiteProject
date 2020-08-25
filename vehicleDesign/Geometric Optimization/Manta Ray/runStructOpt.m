function [Ixx_opt,Fthk,Mtot,Wingdim] = runStructOpt(vhcl,wing,hStab,vStab,fuse,Env)

chord = vhcl.portWing.MACLength.Value;
span = vhcl.portWing.halfSpan.Value*2;
AR = vhcl.portWing.AR.Value*2;
volume = chord*span^3/AR^2;
Df = vhcl.fuse.diameter.Value;
Lf = vhcl.fuse.length.Value;
alph = -20:.5:20;
Flift = NaN*ones(numel(alph),1);
for i = 1:numel(alph)
    [~,Flift(i)] = wingPowerCost2([AR,alph(i)],wing,hStab,vStab,fuse,Env);
end
Fmax = max(Flift);
delx = span/4*.05;
Ixx_req = (39.37^4)*5*(0.9)*Fmax*(span/4)^3/(48*69e9*delx);
Skmax = 0.2; Sp1max = 0.1;  Sp2max = 0.1;  Sp3max = 0.1; 
[Ixx_calc]= App_Wing_MoICalc(chord, Skmax, Sp1max, Sp2max, Sp3max);
Ixx_calc = Ixx_calc*(39.37^4);
if Ixx_calc > Ixx_req
    [Ixx_opt,Mwing,exitflagW,Wopt] = App_SWDT2(AR,span,volume,Ixx_req,Df,Lf);
    if exitflagW == 1
        [Mfuse,Fthk,~] = App_SFDT2(Df,Lf,Fmax);
        Mtot = Mfuse+Mwing;
        Wingdim = Wopt;
    end
end
end

