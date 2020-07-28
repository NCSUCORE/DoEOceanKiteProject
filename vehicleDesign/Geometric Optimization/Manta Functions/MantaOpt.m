%%  Kite Design optimization
clc;clear;clear;

%%  User Defined Inputs
Lscale = 1;             %scaling factor
gammaw = 0.9512;        %
eLw = 0.7019;           %
Clw0 = 0.16;            %
xg = 0.2*Lscale;        %
h = -0.2*Lscale;        %stability margin                                                   
Cd0h = 1.7e-4;          %
Cdw_visc = 0.0297;      %viscous drag coefficient
Cdw_ind = 0.2697;       %induced drag coefficient
Cdh_ovrall =  0.03917;  %
Cfe = 0.003;            %skin-friction drag coefficient
Prated = 100;           %rated power (kW) 
vf = 1;                 %flow speed (m/s) 
eta = 0.3;              %flight efficiency (can be a function of vf) 
netaV = 0.6;            %
rho = 1000.0;           %density of seawater
Df = Df_in;             %loops diameter
Lf = Lf_in;             %loops length
ChrdT = 0.12;           %chord thickness (m)
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
        % find Aspect Ratio, Span, Wings Volume, and Wing Force based on the diameter and length
        [AR, Span, Vol,Fz,exitflag1] = Loadcalc_opt1(Df,Lf);                                            
        exitflag1_mat(iDf,iLf) = exitflag1;         %   Optimization 1 exit flag
        if exitflag1 == 1                           %   Optimization 1 converged
            % find the mass of the kite based on aspect ratio, span, volume, fing force, diameter, and length
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

