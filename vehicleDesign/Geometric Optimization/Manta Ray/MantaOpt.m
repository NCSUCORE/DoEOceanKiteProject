%%  Kite Design optimization
clc;clear;clear;

%%  User Defined Inputs
Wing.gammaw = 0.9512;               %   Wing airfoil lift curve slope multiplicative constant
Wing.eLw = 0.7019;                  %   Lift efficiency factor of wing
Wing.Clw0 = 0.16;                   %   Wing lift at zero alpha
Wing.xg = 0.2*Lscale;               %   Wing center of gravity 
Wing.h = -0.2*Lscale;               %   stability margin                                                   
Wing.Cdw_visc = 0.0297;             %   Wing viscous drag coefficient
Wing.Cdw_ind = 0.2697;              %   Wing induced drag coefficient
hStab.Cd0h = 1.7e-4;                %   Horizontal stabilizer drag coefficient at zero angle of attack 
hStab.Cdh_ovrall =  0.03917;        %
Wing.Cfe = 0.003;                   %   skin-friction drag coefficient
Wing.ratedP = 100;                  %   kW - System rated power  
Wing.vFlow = .25;                   %   m/s - Flow speed 
Wing.eta = 0.3;                     %   flight efficiency (can be a function of vf) 
Wing.netaV = 0.6;                   %
Wing.rho = 1000.0;                  %   kg/m^3 - density of seawater
%%  Setup Optimization 
Df_vec = linspace(0.5,1.3,20);                      %   m - Grid of fuselage diameter values
Lf_vec = linspace(3,20,20);                         %   m - Grid of fusaloge length values

%%  Perform Optimization 
for iDf= 1:length(Df_vec)                           %   Loop over all diameters
    Df =  Df_vec(iDf);                              %   m - Current diameter value
    for iLf = 1:length(Lf_vec)                      %   Loop over all lengths 
        Lf =  Lf_vec(iLf);                          %   m - Current length value
        % find Aspect Ratio, Span, Wings Volume, and Wing Force based on the diameter and length
        [AR, Span, Vol,Fz,exitflag1] = steadyFlightOpt(Df,Lf);                                            
        exitflag1_mat(iDf,iLf) = exitflag1;         %   Optimization 1 exit flag
        if exitflag1 == 1                           %   Optimization 1 converged
            % find the mass of the kite based on aspect ratio, span, volume, fing force, diameter, and length
            [exitflag2,Mw_out] = structuralOpt(AR, Span, Vol,Fz,Df,Lf);
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

