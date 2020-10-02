% Optimization Solver Script for Manta Ray Project
clc; clear;
% Main Optimization Parameters ------------------------------------------------------------------
OPT.Preq        = 100.0;                %   kW - Rated power
OPT.vin         = .5;                   %   m/s - Flow speed
OPT.rho         = 1000;                 %   kg/m^3 - Fluid density 
OPT.Dfll        = .35;                  %   m - Fuselage diameter lower limit
OPT.Dful        = .5;                   %   m - Fuselage diameter upper limit
OPT.Lfll        = 6.5;                  %   m - Fuselage length lower limit
OPT.Lful        = 6.5;                  %   m - Fuselage length upper limit
OPT.ARll        = 7;                    %   AR lower limit
OPT.ARul        = 10;                   %   AR upper limit
OPT.Spanll      = 8;                    %   m - Span lower limit
OPT.Spanul      = 8;                    %   m - Span upper limit
OPT.tar_buoy    = 1;                    %   Target buoyancy ratio
OPT.wmassrat    = 0.5;                  %   Wing:kite mass ratio
% SFOT Parameters -------------------------------------------------------------------------------
loadComponent('Manta2RotXFlr_CFD_AR');  %   Manta kite with 2 rotors
SFOT            = initParam(vhcl);      %   Define initial vehicle properties
% SWDT variables --------------------------------------------------------------------------------
SWDT.ChrdT      = 0.12;                 %   Chord thickness fraction
SWDT.E          = 71.7e9;               %   Pa - Al 7075 Young's modulus
SWDT.rho        = 2810.0;               %   kg/m^3 - Al 7075 density
SWDT.dx         = 5.0;                  %   Maximum wing deflection at aerodynamic center
SWDT.NSparMax   = 3.0;                  %   Maximum number of spars
SWDT.Skmax      = 0.2;                  %    - Maximum skin thickness
SWDT.Sp1max     = 0.15;                 %    - Maximum spar 1 thickness
SWDT.Sp2max     = 0.12;                 %    - Maximum spar 2 thickness
SWDT.Sp3max     = 0.1;                  %    - Maximum spar 3 thickness
SWDT.Wskin      = 20;                   %   Objective function weights on skin thickness
SWDT.Wsp1       = 1;                    %   Objective function weights on spar 1 thickness
SWDT.Wsp2       = 5;                    %   Objective function weights on spar 2 thickness
SWDT.Wsp3       = 10;                   %   Objective function weights on spar 3 thickness
% SFDT variables --------------------------------------------------------------------------------
SFDT.eff_fuse   = 0.9;                  %
SFDT.Fthkmax    = 0.5;                  %
SFDT.x_1        = 0.4;                  %
SFDT.x_2        = 0.3;                  %
SFDT.x_W        = 0.45;                 %
SFDT.C_Hstab    = 0.2;                  %
SFDT.FOS        = 1.5;                  %   Factor of safety
SFDT.S_yield    = 270000000.0;          %   Pa -
SFDT.Int_P      = 100000.0;             %   Pa -
SFDT.Ext_P      = 220000.0;             %   Pa -
SFDT.Dyn_P      = 50000.0;              %   Pa -

%%  Optimization
warning('off','all');

intrvls = 10;
Df_vec = linspace(OPT.Dfll,OPT.Dful,intrvls);
Lf_vec = linspace(OPT.Lfll,OPT.Lful,intrvls);

Mtot = 10^10;
Mtot_mat = zeros(intrvls,intrvls);

for iDf= 1:length(Df_vec)
    SFOT.F.D =  Df_vec(iDf);                %   m - Update fuselage diameter
    for iLf = 1:length(Lf_vec)
        SFOT.F.L =  Lf_vec(iLf);            %   m - Update fuselage length
        SFOT = initParam(vhcl,SFOT);        %   Update vehicle properties
        options = optimoptions('fmincon'...  %   Optimization options
            ,'display','iter',...          
            'Algorithm','sqp',...
            'MaxIterations',1e6,...
            'MaxFunctionEvaluations',1e6);
        J = @(U_0)SFOTcost(U_0,SFOT,OPT);
        C = [];
        lb = [OPT.ARll OPT.Spanll];                     %   Optimization lower bound
        ub = [OPT.ARul OPT.Spanul];                     %   Optimization upper bound
        U = [OPT.ARul OPT.Spanul];                      %   Optimization initial guess
        [uopt,pow,conv_flag] = fmincon(J,U,[],[],[],... %   Perform optimization
            [],lb,ub,[],options);
        [Ixx] = airfoil_grid(uopt(1),SFOT.W.b);         %   Obtain current wing moment of inertia
        [Ixx_lim] = airfoil_grid_func_skin_web(uopt(1),SFOT.W.b);
        [Pow,Flift,~,~] = SFOTcost(uopt,SFOT,OPT);
        [Pow1,Flift1,~,~] = SFOTcost([7 8],SFOT,OPT);
        delX = percDef*SFOT.W.b/2/100.0;
        Ixx_req = 5*Flift*(wing.aeroCent^3)/(48*wing.E*delX)*(39.37^4);
        
        AR_mat(iDf,iLf) = AR_out;
        Span_mat(iDf,iLf) = Span_out;
        Ixx_lim_mat(iDf,iLf) = Ixx_lim;
        Ixx_req_mat(iDf,iLf) = Ixx_req;
        Power_mat(iDf,iLf) = Power;
        Volfuse = (0.25*pi*Df*Df*Lf*SFDT.eff_fuse);
        Voltot = Volfuse + Volwing;
        if AR_out > 0 && (Volwing*SWDT.rhow/SFOTParams.rho*Voltot) >= OPT.wmassrat
            [Ixx_opt,Mwing,exitflagW,Wopt,NSp] = App_SWDT(AR_out, Span_out, Ixx_req,SWDT);
            NSp_mat(iDf,iLf) = NSp;
            exitflagW_mat(iDf,iLf) = exitflagW;
            Mwing_mat(iDf,iLf) = Mwing;
            if exitflagW == 1
                [Mfuse,Fthk,exitflagF] = App_SFDT(Df,Lf,Fz,OPT,SFOTParams,SWDT,SFDT);
                Mfuse_mat(iDf,iLf) = Mfuse;
                Fthk_mat(iDf,iLf) = Fthk;
                exitflagF_mat(iDf,iLf) = exitflagF;
                Mtot_mat(iDf,iLf)=Mfuse + Mwing;
                if (Mtot > Mfuse+Mwing && exitflagF == 1)
                    Mtot = Mfuse+Mwing;
                    iLf_opt = iLf;
                    iDf_opt = iDf;
                    Wingdim = Wopt;
                end
                
            end
        end
    end
end

Mwing_opt = Mwing_mat(iDf_opt,iLf_opt)
Mfuse_opt = Mfuse_mat(iDf_opt,iLf_opt)
AR_opt = AR_mat(iDf_opt,iLf_opt)
Span_opt = Span_mat(iDf_opt,iLf_opt)
Df_opt = Df_vec(iDf_opt)
Lf_opt = Lf_vec(iLf_opt)
NSp_opt = NSp_mat(iDf_opt,iLf_opt)
Wingdim
Power_out = Power_mat(iDf_opt,iLf_opt)
Mtot

figure(1); hold on;
xlim([-0.2 1.1]);
ylim([-0.2 0.3]);
title('Wing Design');
if NSp_opt == 0
    A_wingDesignPlot(AR_opt,Span_opt,Wingdim(1), 0, 0, 0)
elseif NSp_opt == 1
    A_wingDesignPlot(AR_opt,Span_opt,Wingdim(1), Wingdim(2), 0, 0)
elseif NSp_opt == 2
    A_wingDesignPlot(AR_opt,Span_opt,Wingdim(1), Wingdim(2), Wingdim(2), 0)
elseif NSp_opt == 3
    A_wingDesignPlot(AR_opt,Span_opt,Wingdim(1), Wingdim(2), Wingdim(2), Wingdim(2))
end

figure(2);hold on;
A_kitePlot(AR_opt,Span_opt,Df_opt,Lf_opt)
title('Overall Kite Design');