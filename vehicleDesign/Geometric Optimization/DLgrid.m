% Kite Design optimization
clc;clear;clear all;
% Setting up D and L grid
Df_vec = linspace(0.5,1.3,20); %for grid of diameter values
Lf_vec = linspace(3,20,20);     %for grid of fusaloge length values
Mw = zeros(20,20);             %initial mass grid (0 if no converge)
exitflag1_mat = zeros(20,20);  %set initial exit flags 1 to 0 
exitflag2_mat = zeros(20,20);  %set initial exit flags 2 to 0 
for iDf= 1:length(Df_vec)   %for all diameters
    Df =  Df_vec(iDf);  %define Df to loops diameter
    for iLf = 1:length(Lf_vec)  %for all lengths
       Lf =  Lf_vec(iLf);   %define Lf to loops length
            %finds Aspect Ratio, Span, Wings Volume, and Wing Force 
            %based on the diameter and length
       [AR, Span, Vol,Fz,exitflag1] = Loadcalc_opt1(Df,Lf);                                            
       exitflag1_mat(iDf,iLf) = exitflag1;  %sets exit flag1 based on output
       if exitflag1 == 1 %if exitflag1 is 1 (converges?)
                %finds the mass of the kite based on aspect ratio,
                %span, volume, fing force, diameter, and length
           [exitflag2,Mw_out] = wingDes_opti2(AR, Span, Vol,Fz,Df,Lf);
           exitflag2_mat(iDf,iLf) = exitflag2;
           %if both converge set mass to found value if not keep mass value
           %of zero
           if exitflag2 == 1 
               Mw(iDf,iLf) = Mw_out;
           end
       end
    end
end


% Surface ploting  
surf(Lf_vec,Df_vec,Mw)
xlabel('Length [m]')
ylabel('Diameter [m]')
zlabel('Mass [kg]')
title('Mass surface plot') 

