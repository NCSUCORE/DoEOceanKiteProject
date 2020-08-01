function [AR, Span, Ixx_lim, Ixx_flag] = AR_limit(Df_in,Lf_in,Preq,v_in)


global Fz Df Lf gammaw eLw Clw0 xg h Cdw_visc Cdw_ind Cfe ClHStall Prated vf eta netaV Cdh_ovrall Cd0h rho
Lscale = 1;
gammaw = 0.9512;
eLw = 0.7019;
Clw0 = 0.16;
xg = 0.2*Lscale;
h = -0.2*Lscale;                                                            %stability margin
Cd0h = 1.7e-4; 
Cdw_visc = 0.0297;
Cdw_ind = 0.2697;
Cdh_ovrall =  0.03917; 
Cfe = 0.003;                                                                %skin-friction drag coefficient
Prated = Preq;                                                               %in kW 
vf = v_in;                                                                     %in m/s 
eta = 0.3;                                                                  %flight efficiency (can be a function of vf) 
netaV = 0.6;                                                              % density of water
rho = 1000.0;
Df = Df_in;
Lf = Lf_in;


% Specifying max Cl,H 
HStall = 10;                                                                %in [deg]
ClHStall = 0.0791.*(HStall) + 0.1553;

% For I beam calculations
% Material properties
E = 69*(10^9); %Aluminium
% Percentage Deflection at centroid
defper = 5.0;

% AR limits
AR_ll = 5.0; AR_ul = 15.0;
%Length of beam
%Span = S/2;

Ixx_flag = false;

AR = 0;Span = 0; Ixx_lim = 0;

while ~Ixx_flag && AR_ul > AR_ll
    U = [(AR_ll+AR_ul)/2.0 8]';
    options = optimoptions('fmincon','Display',...
        'iter','Algorithm','sqp','MaxIterations',1e6,...
        'MaxFunctionEvaluations',1e6);
    J = @(U_0)wingVolumeCost(U_0,Lscale);
    C = @(U_0)powRatedConst(U_0,Lscale);
    lb = [AR_ll 7]';
    ub = [AR_ul 10]'; %Get u(2) upper bound from examining min value of Lamda
    [uopt,~,conv_flag] = fmincon(J,U,[],[],[],[],lb,ub,C,options);
    [Ixx] = airfoil_grid_func(uopt(1),uopt(2));
    
    S = uopt(2)/2.0;
    delx = defper*S/100.0;
    Ixx_req = 5*Fz*(S^3)/(48*E*delx);
    
    if (Ixx_req*(39.37^4) < Ixx && conv_flag == 1)
       Ixx_flag = true;
       AR = uopt(1);
       Span = uopt(2);
       Ixx_lim = Ixx;
       break;
    else
        AR_ul = AR_ul - 1.0;
    end
end
end
