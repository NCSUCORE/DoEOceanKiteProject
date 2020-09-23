function [Ixx_opt,Mw_opt,exitflagW,Wopt,NSp_opt] = App_SWDT(AR_opt, S_opt, Volwing, Ixx_req,Df, Lf)
% DoE Project
% I beam dimensions optimization
% Author: Sumedh Beknalkar

global SpanW ChrdL rhow Ixx 
global Volw Voltot eff_fuse Volfuse
global NSparmax NSp
global Skmax Sp1max Sp2max Sp3max


%Length of beam
SpanW = S_opt/2;

%Airfoil parameters
ChrdL = S_opt/AR_opt; %Chord Length

% Ixx calculation



% Total Volume and Volume of wing
Volw = Volwing;
eff_fuse = 0.8;
Volfuse = (0.25*pi*Df*Df*Lf*eff_fuse);
Voltot = Volfuse + Volw;

% Loop through skin and spar thickness
NSk_vec = 10;
Sk_vec = linspace(0.01,Skmax,NSk_vec);
NSp_vec = 10;
Spmax = [Sp1max,Sp2max,Sp3max];


NSp = -1;

Mwing_min = 10^10;
Mskin = 0;Mspars = 0;

u0 = 0.01;
lb = 0.0001;
ub = 2.0;

SpT_opt = 0;
SkT_opt = 0;
NSp_min = 0;

NSp_opt = 0;

exitflagW = 0;

for i = 1:NSk_vec
    Ixx = Ixx_req;
    [Ixx_skin, area_skin,NA] = App_Wing_MoICalc(ChrdL, Sk_vec(i), 0,NSp);
    Mskin = area_skin*S_opt*rhow;
    Ixx = Ixx - Ixx_skin;
    if Ixx > 0
        for j = 1:NSparmax
            NSp = j;
            Sp_vec = linspace(0.01,Spmax(j),NSp_vec);
            for k = 1:NSp_vec
                [Ixx_spars, NA,area_spars] = App_Wing_MoICalc(ChrdL, 0, Sp_vec(k),NSp);
                Ixx_ss = Ixx_spars + Ixx_skin;
                if Ixx_ss - Ixx_req >0.0 && Ixx_ss - Ixx_req <= 20.0
                    Mspars = area_spars*S_opt*rhow;
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

