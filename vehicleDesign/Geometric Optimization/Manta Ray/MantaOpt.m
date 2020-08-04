%%  Kite Design optimization
clc;clear;clear;

%%  Input definitions 
loadComponent('Manta2rot0WingGeom');                %   Load vehicle 
wing.alphaw = vhcl.portWing.alpha.Value;            %   Wing alpha vec
wing.ARw = vhcl.portWing.AR.Value;                  %   Wing alpha vec
wing.bw = 8;                                        %   Wing span
wing.Sw = vhcl.fluidRefArea.Value;                  %   Reference area for wing
wing.CLw = vhcl.portWing.CL.Value;                  %   Wing lift coefficient at zero alpha
wing.CDw = vhcl.portWing.CD.Value;                  %   Wing drag coefficient at zero alpha
wing.CDw_visc = 0.0297;                             %   Wing viscous drag coefficient
wing.CDw_ind = 0.2697;                              %   Wing induced drag coefficient
wing.Cfe = 0.003;                                   %   Wing skin-friction drag coefficient
wing.gammaw = 1;                                    %   Wing airfoil lift curve slope multiplicative constant
wing.eLw = 0.9;                                     %   Wing lift Oswald efficiency factor
wing.eDw = 0.9;                                     %   Wing drag Oswald efficiency factor
wing.aeroCent = 1.9259;                             %   Wing aerodynamic center 
wing.E = 69e9;                                      %   Wing modulus of elasticity 

hStab.alphah = vhcl.hStab.alpha.Value;              %   Horizontal stabilizer alpha vec
hStab.CLh = vhcl.hStab.CL.Value;                    %   Horizontal stabilizer lift coefficient
hStab.CDh = vhcl.hStab.CD.Value;                    %   Horizontal stabilizer drag coefficient
hStab.ARh = vhcl.hStab.AR.Value;                    %   Horizontal stabilizer aspect ratio 
hStab.Sh = vhcl.fluidRefArea.Value;                 %   Reference area for horizontal stabilizer
hStab.gammah = 1;                                   %   Horizontal stabilizer airfoil lift curve slope multiplicative constant
hStab.eLh = 0.9;                                    %   Horizontal stabilizer lift Oswald efficiency factor
hStab.eDh = 0.9;                                    %   Horizontal stabilizer drag Oswald efficiency factor
hStab.aeroCent = 1.9259;                            %   Horizontal stabilizer aero center w/respect to fuse nose

vStab.alphav = vhcl.vStab.alpha.Value;              %   Find index corresponding to 0 AoA
vStab.CDv = vhcl.vStab.CD.Value;                    %   Horizontal stabilizer drag coefficient at zero alpha
vStab.Sv = vhcl.fluidRefArea.Value;                 %   Reference area for horizontal stabilizer
vStab.eDv = 0.9;                                    %   Horizontal stabilizer drag Oswald efficiency factor

fuse.CD0f = vhcl.fuse.endDragCoeff.Value;           %   Fuselage drag coefficient at 0° AoA
fuse.CD9f = vhcl.fuse.sideDragCoeff.Value;          %   Fuselage drag coefficient at 90° AoA

Sys.ratedP = 100;                                   %   kW - System rated power  
Sys.eta = 0.3;                                      %   flight efficiency (can be a function of vf) 
Sys.xg = 0.2;                                       %   Sys center of gravity 
Sys.h = -0.2;                                       %   stability margin                                                   

Env.vFlow = .25;                                    %   m/s - Flow speed 
Env.rho = 1000;                                     %   kg/m^3 - density of seawater

%%  Perform Optimization 
AR0 = 10;                                               %   Aspect ratio initial guess 
alpha0 = 10*pi/180;                                     %   rad - Angle of attack initial guess 

percDef = 5;                                            %   Maximum wing deflection percentage 

Df_vec = linspace(.35,.65,10);                          %   m - Grid of fuselage diameter values
Lf_vec = linspace(6,8,10);                              %   m - Grid of fusaloge length values

AR_mat = zeros(length(Df_vec),length(Lf_vec));          %   Initialize aspect ratio matrix 
Ixx_lim_mat = zeros(length(Df_vec),length(Lf_vec));     %   Initialize aspect ratio matrix 

for ii = 1:1%length(fuse.D)
    for jj = 1:1%length(fuse.L)
        fuse.D = Df_vec(ii);                            %   m - Grid of fuselage diameter values
        fuse.L = Lf_vec(jj);                            %   m - Grid of fusaloge length values
        options = optimoptions('fmincon','display','iter',...            %   Optimization options
            'Algorithm','sqp','MaxIterations',1e6,...
            'MaxFunctionEvaluations',1e6);
        J = @(U_0)wingPowerCost1(U_0,wing,hStab,vStab,fuse,Env);
        J = @(U_0)wingPowerCost2(U_0,wing,hStab,vStab,fuse,Env);
        C = [];
        lb = [5 0];                                     %   Optimization lower bound
        ub = [12 20*pi/180];                            %   Optimization upper bound
        U = [AR0,alpha0];                               %   Optimization initial guess
        [uopt,pow,conv_flag] = fmincon(J,U,[],[],[],... %   Perform optimization 
            [],lb,ub,[],options);
        [Ixx] = airfoil_grid(uopt(1),wing.bw);          %   Obtain current wing moment of inertia 
        [Ixx_lim] = airfoil_grid_func_skin_web(uopt(1),wing.bw);
        [~,Flift] = wingPowerCost1(uopt,wing,hStab,vStab,fuse,Env);
        delX = percDef*wing.bw/2/100.0;
        Ixx_req = 5*Flift*(wing.aeroCent^3)/(48*wing.E*delX)*(39.37^4);
    end
end
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