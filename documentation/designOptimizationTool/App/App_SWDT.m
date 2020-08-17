function [Ixx_opt,Mw_out,exitflag,Wopt] = SWDT(AR_opt, S_opt, Volwing, Ixx_req,Df, Lf)
% DoE Project
% I beam dimensions optimization
% Author: Sumedh Beknalkar

global SpanW ChrdL rhow Ixx 
global Volw Voltot eff_fuse Volfuse

%Length of beam
SpanW = S_opt/2;

%Airfoil parameters
ChrdL = S_opt/AR_opt; %Chord Length

% Ixx calculation
Ixx = Ixx_req/(39.37^4);


% Total Volume and Volume of wing
Volw = Volwing;
eff_fuse = 0.8;
Volfuse = (0.25*pi*Df*Df*Lf*eff_fuse);
Voltot = Volfuse + Volw;

% Optimization
u0 = [0.18 0.01 0.01 0.01]';
lb = [0.001 0 0 0]'; % Lower limits
ub = 1.0*ones(4,1);   % upper limits
options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',10000000);
[uopt Jopt exitflag] = fmincon(@costfunc,u0,[],[],[],[],lb,ub,@constraintfunc,options);

%Wt_opt = rhow*Span*(2*(uopt(4)*uopt(2))+(uopt(3)*(uopt(1)-(2*(uopt(4))))));
[Ixx_opt, area_skin,area_spar1,area_spar2,area_spar3] = App_Wing_MoICalc(ChrdL, uopt(1), uopt(2), uopt(3),uopt(4));

Ixx_opt = Ixx_opt*(39.37^4);

area_opt = area_skin+area_spar1+area_spar2+area_spar3;
Mw_out = area_opt*S_opt*rhow;
Wopt = uopt

end

function [J] =costfunc(u)
global ChrdL
global Wskin Wsp1 Wsp2 Wsp3


% Cost = Weight of beam
[Ixx_calc, area_skin,area_spar1,area_spar2,area_spar3] =...
    App_Wing_MoICalc(ChrdL, u(1), u(2), u(3),u(4));
% vol = area*Span;

% J = area + 5*u(1) + 10*u(2)+ 15*u(3) + 20*u(4);
J = Wskin*area_skin + Wsp1*area_spar1 + Wsp2*area_spar2+ Wsp3*area_spar3;

end

function [c_ineq, c_eq] = constraintfunc(u)
global ChrdL Ixx rho rhow Volw Voltot wmassrat
global Skmax Sp1max Sp2max Sp3max

% Constraints
ineq1 = u(1) - Skmax;
ineq2 = u(2) - Sp1max;
ineq3 = u(3) - Sp2max;
ineq4 = u(4) - Sp3max;
ineq5 = -eye(4)*u;

[Ixx_calc, area_skin,area_spar1,area_spar2,area_spar3] = ...
    App_Wing_MoICalc(ChrdL, u(1), u(2), u(3),u(4));


% Constraint type 1 (Dr. Bryant)
% ineq6 = (((rho*Volw/(vol*rhow)) - tar_buoy)^2.0) - 0.1;

% Constraint type 2 (Dr. Vermillion)
ineq6 = wmassrat - ((Volw*rhow)/rho*(Voltot));

eq1 = Ixx_calc - Ixx;

c_ineq=[ineq1;ineq2;ineq3;ineq4;ineq5;ineq6];
c_eq= eq1;
end
