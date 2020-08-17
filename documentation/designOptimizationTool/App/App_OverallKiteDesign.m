function [Mtot, Mwing_opt,Mfuse_opt, AR_opt,Span_opt, Df_opt,Lf_opt,Wingdim, Power_out] = App_OverallKiteDesign()
% Kite Design optimization
% Running steady flight and structural tool to obtain D,L grid 

% Setting up D and L grid
intrvls = 5;
Df_vec = linspace(0.5,1.2,intrvls);
Lf_vec = linspace(6.5,8,intrvls);


% [AR_out, Span_out, Volwing,Ixx_lim,Ixx_req,Fz] = App_SFOT(0.8,7.0);
% [Ixx_opt,Mwing,exitflag1] = App_SWDT(AR_out, Span_out, Volwing, Ixx_req,0.8,7.0);
% [Mfuse,thk,exitflag2] = App_SFDT(0.8,7.4,Fz);
% Mtot = Mwing+Mfuse;

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
          [Ixx_opt,Mwing,exitflagW,Wopt] = App_SWDT(AR_out, Span_out, Volwing, Ixx_req,Df,Lf);
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
Wingdim
Power_out = Power_mat(iDf_opt,iLf_opt)
Mtot
% 
% % Surface ploting  
% % surf(Lf_vec,Df_vec,Mw)
% figure(1)
% surf(Lf_vec,Df_vec,AR_mat)
% xlabel('Length [m]','interpreter','latex')
% ylabel('Diameter [m]','interpreter','latex')
% zlabel('Aspec Ratio','interpreter','latex')
% 
% figure(2)
% surf(Lf_vec,Df_vec,Span_mat)
% xlabel('Length [m]','interpreter','latex')
% ylabel('Diameter [m]','interpreter','latex')
% zlabel('Span[m]','interpreter','latex')
% 
% figure(3)
% surf(Lf_vec,Df_vec,Ixx_lim_mat)
% xlabel('Length [m]','interpreter','latex')
% ylabel('Diameter [m]','interpreter','latex')
% zlabel('Area Moment of Inertia[inc^4]','interpreter','latex')
% 
% %% Optimization: Steady flight + Wing structure 
% 
% exiflag_mat = zeros(length(Df_vec),length(Lf_vec));
% Mwing_mat = zeros(length(Df_vec),length(Lf_vec));
% Mkite_mat = zeros(length(Df_vec),length(Lf_vec));
% Mfuse_mat = zeros(length(Df_vec),length(Lf_vec));
% OptAR_mat = zeros(length(Df_vec),length(Lf_vec));
% OptSpan_mat = zeros(length(Df_vec),length(Lf_vec));
% Fz_mat = zeros(length(Df_vec),length(Lf_vec));
% 
% MassF_opt = 1e10;
% for iDf= 1:length(Df_vec)
%     Df =  Df_vec(iDf);
%     for iLf = 1:length(Lf_vec)
%        Lf =  Lf_vec(iLf);
%        if AR_mat(iDf,iLf) >0
%            [AR, Span, Vol, Fz] = Loadcalc_opt1(Df,Lf,Preq,v_in,AR_mat(iDf,iLf));
%            OptSpan_mat(iDf,iLf) = Span; 
%            OptAR_mat(iDf,iLf) = AR; 
%            Fz_mat(iDf,iLf) = Fz; 
%            [Mwing,exitflag] = wingDes_opti(AR, Span, Vol,Fz, Df, Lf);
% %            exitflag_mat(iDf,iLf) = exitflag;
%            if exitflag == 1
%                [Massfuse,thk] = selectDL(D,L,Fz)
%                if MassF_opt > Massfuse
%                    MassF_opt = MassFuse;
%                    D_opt = Df_vec(iDf);
%                    L_opt = Lf_vec(iLf);
%                    Mwing_opt = Mwing;
%                    thk_opt = thk;
%                    AR_opt = OptAR_mat(iDf,iLf);
%                    Span_opt = OptSpan_mat(iDf,iLf);
%                    Fz_opt = Fz_mat(iDf,iLf);
%                end
%            end
% %            Mwing_mat(iDf,iLf) = Mwing;
% %            Mkite_mat(iDf,iLf) = Mkite;
% %            Mfuse_mat(iDf,iLf) = Mkite-Mwing;
%        end
% 
%     end
% end


%% Selecting optimal D,L values 

% Getting x,y indices of converged values 
% [x,y] = find(exiflag_mat ==1);
% 
% for count = 1:length(x)
% DVec(count) = Df_vec(x(count));
% LVec(count) = Lf_vec(y(count));
% FzVec = Fz_mat(find(exiflag_mat == 1));
% ARVec = OptAR_mat(find(exiflag_mat == 1));
% SpanVec = OptSpan_mat(find(exiflag_mat == 1));
% end
% 
% % Run optimization to choose optimal L,D,t 
% [Dfuse,Lfuse,tfuse,Massfuse,Mindex] = selectDL(DVec,LVec,FzVec);
% 
% 
% 
% 
% %% Plotting Kite geometry 
% 
% % Kite dimensions 
% KiteAR = ARVec(Mindex); 
% KiteSpan = SpanVec(Mindex); 
% KiteDia = round(Dfuse,2,'significant'); 
% KiteLen = Lfuse; 
% KiteWingPos = 0.35; 
% 
% % plotting 
% set(gca,'FontName','latex')
% plotKite(KiteLen,KiteDia,KiteSpan,KiteAR,KiteWingPos)
% title({['Fuse Length is ',num2str(KiteLen)],['Fuse Diameter is ',num2str(KiteDia)],...
%     ['Wing parameters: AR is ',num2str(KiteAR),' and Span is ',num2str(KiteSpan)]})
% grid on 

end
