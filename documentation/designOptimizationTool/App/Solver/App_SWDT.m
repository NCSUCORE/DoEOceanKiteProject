function [Ixx_opt,Mw_opt,exitflagW,Wopt,NSp_opt] = App_SWDT(AR_opt, S_opt, Ixx_req,SWDTParams)


%Airfoil parameters
ChrdL = S_opt/AR_opt; 


% Loop through skin and spar thickness
NSk_vec = 10;
Sk_vec = linspace(0.01,SWDTParams.Skmax,NSk_vec);
NSp_vec = 10;
Spmax = [SWDTParams.Sp1max,SWDTParams.Sp2max,SWDTParams.Sp3max];


Mwing_min = 10^10;
Mspars = 0;

SpT_opt = 0;
SkT_opt = 0;
NSp_opt = 0;
Ixx_tot = 0;
exitflagW = 0;

% Exhaustive search
for i = 1:NSk_vec
    Ixx = Ixx_req;NSp = -1;
    [Ixx_skin, area_skin,NA] = App_Wing_MoICalc_3(ChrdL, Sk_vec(i), 0,NSp);
    Mskin = area_skin*S_opt*SWDTParams.rhow;
    Ixx = Ixx - Ixx_skin;
    if Ixx > 0
        for j = 1:SWDTParams.NSparmax
            NSp = j;
            Sp_vec = linspace(0.01,Spmax(j),NSp_vec);
            for k = 1:NSp_vec
                [Ixx_spars, NA,area_spars] = App_Wing_MoICalc_3(ChrdL, 0, Sp_vec(k),NSp);
                Ixx_ss = Ixx_spars + Ixx_skin;
                if Ixx_ss - Ixx_req >0.0 && Ixx_ss - Ixx_req <= 20.0
                    Mspars = area_spars*S_opt*SWDTParams.rhow;
                    Mwing = Mskin + Mspars;
                    if Mwing_min > Mwing 
                        Mwing_min  = Mwing;
                        NSp_opt = NSp;
                        SpT_opt = Sp_vec(k);
                        SkT_opt = Sk_vec(i);
                        Ixx_tot(1) = Ixx_spars+Ixx_skin;
                        Ixx_tot(2) = Ixx_spars;
                        Ixx_tot(3) = Ixx_skin;
                        exitflagW = 1;
                    end
                    break;
                end
            end
        end
    elseif Ixx_skin - Ixx_req >0.0 && Ixx_skin - Ixx_req <= 20.0
        Mwing = Mskin;
        if Mwing_min > Mwing
            Mwing_min  = Mwing;
            NSp_opt = 0;
            SpT_opt = 0;
            SkT_opt = Sk_vec(i);
            Ixx_tot(1) = Ixx_skin;
            Ixx_tot(2) = 0;
            Ixx_tot(3) = Ixx_skin;
            exitflagW = 1;
        end
    end
    
end

NSp_opt
SpT_opt
SkT_opt
Ixx_tot

Wopt(1) = SkT_opt;
Wopt(2) = SpT_opt;
Mw_opt = Mwing_min;
Ixx_opt = Ixx_tot(1);
end

