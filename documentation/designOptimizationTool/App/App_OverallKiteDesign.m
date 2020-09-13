function [Mtot, Mwing_opt,Mfuse_opt, AR_opt,Span_opt, Df_opt,Lf_opt,Wingdim, Power_out, NSp_opt] = App_OverallKiteDesign()
% Kite Design optimization
% Running steady flight and structural tool to obtain D,L grid 

% Setting up D and L grid
intrvls = 10;
Df_vec = linspace(0.5,1.2,intrvls);
Lf_vec = linspace(6.5,8,intrvls);

Mtot = 10^10;
Mtot_mat = zeros(intrvls,intrvls);

for iDf= 1:length(Df_vec)
    Df =  Df_vec(iDf);
    for iLf = 1:length(Lf_vec)
       Lf =  Lf_vec(iLf);
       [AR_out, Span_out, Volwing,Ixx_lim,Ixx_req,Fz,Power] = App_SFOT(Df,Lf);
       AR_mat(iDf,iLf) = AR_out;
       Span_mat(iDf,iLf) = Span_out;
       Ixx_lim_mat(iDf,iLf) = Ixx_lim;
       Ixx_req_mat(iDf,iLf) = Ixx_req;
       Power_mat(iDf,iLf) = Power;
       if AR_out > 0
          [Ixx_opt,Mwing,exitflagW,Wopt,NSp] = App_SWDT(AR_out, Span_out, Volwing, Ixx_req,Df,Lf);
          NSp_mat(iDf,iLf) = NSp;
          exitflagW_mat(iDf,iLf) = exitflagW;
          Mwing_mat(iDf,iLf) = Mwing;
          if exitflagW == 1
              [Mfuse,Fthk,exitflagF] = App_SFDT(Df,Lf,Fz);
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

end
