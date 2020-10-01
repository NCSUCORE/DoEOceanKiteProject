% Solver Script
clc; clear;
% Setting Parameters Structs
%--------------------------------------------------------------
%Main tab Parameters
Opt.Preq   = 100.0;        %   kW - rated power
Opt.vin    = .5;           %   m/s - flow speed 
Opt.Dfll   = .35;          %   m - fuselage diameter lower limit 
Opt.Dful   = .5;           %   m - fuselage diameter upper limit 
Opt.Lfll   = 6.5;          %   m - fuselage length lower limit 
Opt.Lful   = 8;            %   m - fuselage length upper limit 
Opt.ARll   = 7;            %   AR lower limit 
Opt.ARul   = 10;           %   AR upper limit
Opt.Spanll = 8;            %   m - span lower limit
Opt.Spanul = 8;            %   m - span upper limit 
Opt.tar_buoy = 1;          %   target buoyancy ratio 
Opt.wmassrat = 0.5;        %   wing:kite mass ratio
%-------------------------------------------------------------------
% SFOT Parameters
loadComponent('Manta2RotXFlr_CFD_AR');      %   Manta kite with 2 rotors
W.b = vhcl.portWing.halfSpan.Value*2;
W.c = vhcl.portWing.MACLength.Value;
W.AR = W.b/W.c;
H.b = vhcl.hStab.halfSpan.Value*2;
H.c = vhcl.hStab.MACLength.Value;
H.AR = H.b/H.c;
V.b = vhcl.vStab.halfSpan.Value;
V.c = vhcl.vStab.MACLength.Value;
V.AR = V.b/V.c;
SFOTParams.Lscale = 1;  SFOTParams.gammaw = 0.95; SFOTParams.eLw = 0.71;
SFOTParams.Clw0 = 0.16; SFOTParams.x_g = 0.2*SFOTParams.Lscale;
SFOTParams.h_sm = -0.2*SFOTParams.Lscale; SFOTParams.Cd0_h = 1.7*(10^-4);
SFOTParams.Cdw_visc = 0.03; SFOTParams.Cdw_ind = 1/(pi*0.98);
SFOTParams.Cdh_ovrall =  0.16;  SFOTParams.Cfuse = 0.003; 

SFOTParams.eta = 0.3; SFOTParams.netaV = 0.8; 
SFOTParams.rho = 1000.0;

SFOTParams.ClHStall = 0.0791.*(10) + 0.1553;
%------------------------------------------------------------------------
% SWDT variables
SWDTParams.ChrdT = 0.12;
% Material properties
SWDTParams.E = 69*(10^9); %Aluminium
SWDTParams.rhow = 2710.0; %Al
% Percentage Deflection at centroid
SWDTParams.defper = 5.0;
SWDTParams.NSparmax = 3.0;
SWDTParams.Skmax = 0.2; SWDTParams.Sp1max = 0.15; 
SWDTParams.Sp2max = 0.12;  SWDTParams.Sp3max = 0.1; 
%Weights on objective function entities
SWDTParams.Wskin = 20; SWDTParams.Wsp1 = 1; 
SWDTParams.Wsp2 = 5; SWDTParams.Wsp3 = 10;
%------------------------------------------------------------------------
SFDTParams.eff_fuse = 0.9;
SFDTParams.Fthkmax = 0.5;
SFDTParams.x_1 = 0.4;SFDTParams.x_2 = 0.3;SFDTParams.x_W = 0.45;
SFDTParams.C_Hstab = 0.2;
SFDTParams.FOS = 1.5;
SFDTParams.S_yield = 270000000.0;
SFDTParams.Int_P = 100000.0;
SFDTParams.Ext_P = 220000.0;
SFDTParams.Dyn_P = 50000.0;

App_OverallKiteDesign(Opt, SFOTParams, SWDTParams, SFDTParams)

%%  Optimization
warning('off','all');

intrvls = 10;
Df_vec = linspace(Opt.Dfll,Opt.Dful,intrvls);
Lf_vec = linspace(Opt.Lfll,Opt.Lful,intrvls);

Mtot = 10^10;
Mtot_mat = zeros(intrvls,intrvls);

for iDf= 1:length(Df_vec)
    Df =  Df_vec(iDf);
    for iLf = 1:length(Lf_vec)
       Lf =  Lf_vec(iLf);
       [AR_out, Span_out, Volwing,Ixx_lim,Ixx_req,Fz,Power] = App_SFOT(Df,Lf,Opt,SFOTParams,SWDTParams);
       AR_mat(iDf,iLf) = AR_out;
       Span_mat(iDf,iLf) = Span_out;
       Ixx_lim_mat(iDf,iLf) = Ixx_lim;
       Ixx_req_mat(iDf,iLf) = Ixx_req;
       Power_mat(iDf,iLf) = Power;
       Volfuse = (0.25*pi*Df*Df*Lf*SFDTParams.eff_fuse);
       Voltot = Volfuse + Volwing;
       if AR_out > 0 && (Volwing*SWDTParams.rhow/SFOTParams.rho*Voltot) >= Opt.wmassrat
          [Ixx_opt,Mwing,exitflagW,Wopt,NSp] = App_SWDT(AR_out, Span_out, Ixx_req,SWDTParams);
          NSp_mat(iDf,iLf) = NSp;
          exitflagW_mat(iDf,iLf) = exitflagW;
          Mwing_mat(iDf,iLf) = Mwing;
          if exitflagW == 1
              [Mfuse,Fthk,exitflagF] = App_SFDT(Df,Lf,Fz,Opt,SFOTParams,SWDTParams,SFDTParams);
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