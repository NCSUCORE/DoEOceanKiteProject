%%  Kite Design optimization
clc;clear;clear;

%%  Setup Optimization 
Df_vec = linspace(0.5,1.3,20);                      %   m - Grid of fuselage diameter values
Lf_vec = linspace(3,20,20);                         %   m - Grid of fusaloge length values
Mw = zeros(20,20);                                  %   kg - Initialize mass grid (0 if no converge)
exitflag1_mat = zeros(20,20);                       %   set initial exit flags 1 to 0 
exitflag2_mat = zeros(20,20);                       %   set initial exit flags 2 to 0 

%%  Perform Optimization 
for iDf= 1:length(Df_vec)                           %   Loop over all diameters
    Df =  Df_vec(iDf);                              %   m - Current diameter value
    for iLf = 1:length(Lf_vec)                      %   Loop over all lengths 
        Lf =  Lf_vec(iLf);                          %   m - Current length value
        % Find Aspect Ratio, Span, Wings Volume, and Wing Force based on the diameter and length
        [AR, Span, Vol,Fz, exitflag1] = Loadcalc_opt1(Df,Lf);                                            
        exitflag1_mat(iDf,iLf) = exitflag1;         %   Optimization 1 exit flag
        if exitflag1 == 1                           %   Optimization 1 converged
            % Find the mass of the kite based on aspect ratio, span, volume, fing force, diameter, and length
            [exitflag2,Mw_out] = wingDes_opti2(AR, Span, Vol,Fz,Df,Lf);
            exitflag2_mat(iDf,iLf) = exitflag2;     %   Optimization 2 exit flag
            if exitflag2 == 1                       %   Optimization 2 converged
                Mw(iDf,iLf) = Mw_out;               %   kg - Assign found mass value 
            end
        end
    end
end

%%  Plot Results 
figure;
surf(Lf_vec,Df_vec,Mw);
xlabel('Length [m]');  ylabel('Diameter [m]');  zlabel('Mass [kg]');  title('Mass surface plot');

