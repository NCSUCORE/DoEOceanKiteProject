function [] = App_OverallKiteDesign(MTParams, SFOTParams, SWDTParams, SFDTParams)
% Kite Design optimization

warning('off','all');

intrvls = 10;
Df_vec = linspace(MTParams.Dfll,MTParams.Dful,intrvls);
Lf_vec = linspace(MTParams.Lfll,MTParams.Lful,intrvls);

Mtot = 10^10;
Mtot_mat = zeros(intrvls,intrvls);

for iDf= 1:length(Df_vec)
    Df =  Df_vec(iDf);
    for iLf = 1:length(Lf_vec)
       Lf =  Lf_vec(iLf);
       [AR_out, Span_out, Volwing,Ixx_lim,Ixx_req,Fz,Power] = App_SFOT(Df,Lf,MTParams,SFOTParams,SWDTParams);
       AR_mat(iDf,iLf) = AR_out;
       Span_mat(iDf,iLf) = Span_out;
       Ixx_lim_mat(iDf,iLf) = Ixx_lim;
       Ixx_req_mat(iDf,iLf) = Ixx_req;
       Power_mat(iDf,iLf) = Power;
       Volfuse = (0.25*pi*Df*Df*Lf*SFDTParams.eff_fuse);
       Voltot = Volfuse + Volwing;
       if AR_out > 0 && (Volwing*SWDTParams.rhow/SFOTParams.rho*Voltot) >= MTParams.wmassrat
          [Ixx_opt,Mwing,exitflagW,Wopt,NSp] = App_SWDT(AR_out, Span_out, Ixx_req,SWDTParams);
          NSp_mat(iDf,iLf) = NSp;
          exitflagW_mat(iDf,iLf) = exitflagW;
          Mwing_mat(iDf,iLf) = Mwing;
          if exitflagW == 1
              [Mfuse,Fthk,exitflagF] = App_SFDT(Df,Lf,Fz,MTParams,SFOTParams,SWDTParams,SFDTParams);
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



end
