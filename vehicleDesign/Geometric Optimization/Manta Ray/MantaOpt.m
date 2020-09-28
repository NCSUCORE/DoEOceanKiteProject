%%  Kite Design optimization
clc;%clear;clear;

%%  Input definitions 
loadComponent('Manta2RotXFlr_CFD');                              %   Manta kite with XFlr5 
wing.alpha = vhcl.portWing.alpha.Value;            %   Wing alpha vec
wing.AR = vhcl.portWing.AR.Value;                  %   Wing alpha vec
wing.b = 8;                                        %   Wing span
wing.S = vhcl.fluidRefArea.Value;                  %   Reference area for wing
wing.CL = vhcl.portWing.CL.Value;                  %   Wing lift coefficient at zero alpha
wing.CD = vhcl.portWing.CD.Value;                  %   Wing drag coefficient at zero alpha
wing.CD_visc = 0.0297;                             %   Wing viscous drag coefficient
wing.CD_ind = 0.2697;                              %   Wing induced drag coefficient
wing.Cfe = 0.003;                                   %   Wing skin-friction drag coefficient
wing.gamma = 1;                                    %   Wing airfoil lift curve slope multiplicative constant
wing.eL = 0.9;                                     %   Wing lift Oswald efficiency factor
wing.eD = 0.9;                                     %   Wing drag Oswald efficiency factor
wing.aeroCent = 1.9259;                             %   Wing aerodynamic center 
wing.E = 69e9;                                      %   Wing modulus of elasticity 

hStab.alpha = vhcl.hStab.alpha.Value;              %   Horizontal stabilizer alpha vec
hStab.CL = vhcl.hStab.CL.Value;                    %   Horizontal stabilizer lift coefficient
hStab.CD = vhcl.hStab.CD.Value;                    %   Horizontal stabilizer drag coefficient
hStab.AR = vhcl.hStab.AR.Value;                    %   Horizontal stabilizer aspect ratio 
hStab.S = vhcl.fluidRefArea.Value;                 %   Reference area for horizontal stabilizer
hStab.gamma = 1;                                   %   Horizontal stabilizer airfoil lift curve slope multiplicative constant
hStab.eL = 0.9;                                    %   Horizontal stabilizer lift Oswald efficiency factor
hStab.eD = 0.9;                                    %   Horizontal stabilizer drag Oswald efficiency factor
hStab.aeroCent = 1.9259;                            %   Horizontal stabilizer aero center w/respect to fuse nose

vStab.alpha = vhcl.vStab.alpha.Value;              %   Find index corresponding to 0 AoA
vStab.CD = vhcl.vStab.CD.Value;                    %   Horizontal stabilizer drag coefficient at zero alpha
vStab.S = vhcl.fluidRefArea.Value;                 %   Reference area for horizontal stabilizer
vStab.eD = 0.9;                                    %   Horizontal stabilizer drag Oswald efficiency factor

fuse.CD0 = vhcl.fuse.endDragCoeff.Value;           %   Fuselage drag coefficient at 0° AoA
fuse.CD9 = vhcl.fuse.sideDragCoeff.Value;          %   Fuselage drag coefficient at 90° AoA
fuse.D = vhcl.fuse.diameter.Value;                  %   m - Grid of fuselage diameter values
fuse.L = vhcl.fuse.length.Value;                    %   m - Grid of fusaloge length values

Sys.ratedP = 100;                                   %   kW - System rated power  
Sys.eta = 0.3;                                      %   flight efficiency (can be a function of vf) 
Sys.xg = 0.2;                                       %   Sys center of gravity 
Sys.h = -0.2;                                       %   stability margin                                                   

Env.vFlow = .25;                                    %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater

alpha = 12;
%%  Perform Optimization 
AR0 = 10;                                               %   Aspect ratio initial guess 
b0 = 8;                                                 %   m - Span initial guess 

percDef = 5;                                            %   Maximum wing deflection percentage 

options = optimoptions('fmincon','display','iter',...            %   Optimization options
    'Algorithm','sqp','MaxIterations',1e6,...
    'MaxFunctionEvaluations',1e6);
J = @(U_0)wingPowerCost2(U_0,wing,hStab,vStab,fuse,Env,alpha);
C = [];
lb = [5 8];                                     %   Optimization lower bound
ub = [12 8];                                    %   Optimization upper bound
U = [AR0,b0];                                   %   Optimization initial guess
[uopt,pow,conv_flag] = fmincon(J,U,[],[],[],... %   Perform optimization
    [],lb,ub,[],options);
[Ixx] = airfoil_grid(uopt(1),wing.bw);          %   Obtain current wing moment of inertia
[Ixx_lim] = airfoil_grid_func_skin_web(uopt(1),wing.bw);
[~,Flift] = wingPowerCost1(uopt,wing,hStab,vStab,fuse,Env);
delX = percDef*wing.bw/2/100.0;
Ixx_req = 5*Flift*(wing.aeroCent^3)/(48*wing.E*delX)*(39.37^4);

% uopt(2)*180/pi
%%  Surface ploting  
% surf(Lf_vec,Df_vec,Mw)
% figure(1)
% surf(Lf_vec,Df_vec,AR_mat)
% xlabel('Length [m]','interpreter','latex')
% ylabel('Diameter [m]','interpreter','latex')
% zlabel('Aspect Ratio','interpreter','latex')
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
% zlabel('Area Moment of Inertia[in$^4$]','interpreter','latex')