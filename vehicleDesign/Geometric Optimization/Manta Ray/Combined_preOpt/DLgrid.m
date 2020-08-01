% Kite Design optimization
clc;clear;close all;

loadComponent('Manta2rot0WingGeom');                    %   Vehicle with 2 rotors

Preq = 1.0;                                             %   kW - Rated Power
v_in = .25;                                             %   m/s - Environment flow speed 

Df_vec = linspace(.35,.65,10);                          %   m - Grid of fuselage diameter values
Lf_vec = linspace(6,8,10);                              %   m - Grid of fusaloge length values

AR_mat = zeros(length(Df_vec),length(Lf_vec));          %   Initialize aspect ratio matrix 
Span_mat = zeros(length(Df_vec),length(Lf_vec));        %   Initialize aspect ratio matrix 
Ixx_lim_mat = zeros(length(Df_vec),length(Lf_vec));     %   Initialize aspect ratio matrix 

for iDf = 1:1%length(Df_vec)
    for iLf = 1:1%length(Lf_vec)
       [AR, Span, Ixx_lim] = AR_limit(Df_vec(iDf),Lf_vec(iLf),Preq,v_in);
       AR_mat(iDf,iLf) = AR;
       Span_mat(iDf,iLf) = Span;
       Ixx_lim_mat(iDf,iLf) = Ixx_lim;
    end
end

%% 

% Surface ploting  
% surf(Lf_vec,Df_vec,Mw)
figure(1)
surf(Lf_vec,Df_vec,AR_mat)
xlabel('Length [m]','interpreter','latex')
ylabel('Diameter [m]','interpreter','latex')
zlabel('Aspect Ratio','interpreter','latex')

figure(2)
surf(Lf_vec,Df_vec,Span_mat)
xlabel('Length [m]','interpreter','latex')
ylabel('Diameter [m]','interpreter','latex')
zlabel('Span[m]','interpreter','latex')

figure(3)
surf(Lf_vec,Df_vec,Ixx_lim_mat)
xlabel('Length [m]','interpreter','latex')
ylabel('Diameter [m]','interpreter','latex')
zlabel('Area Moment of Inertia[in^4]','interpreter','latex')



