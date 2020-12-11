function [Ixx_opt,Mw_out,exitflag,Wopt] = App_SWDT2(AR_opt, S_opt, Volwing, Ixx_req,Df, Lf)
% DoE Project
% I beam dimensions optimization
% Author: Sumedh Beknalkar

in.Wskin = 20; in.Wsp1 = 1; in.Wsp2 = 5; in.Wsp3 = 10;
in.Skmax = 0.2; in.Sp1max = 0.2;  in.Sp2max = 0.2;  in.Sp3max = 0.2; 
in.rho = 1000.0;
in.rhow = 2710.0; %Al
in.wmassrat = .4;
%Length of beam
in.SpanW = S_opt/4;

%Airfoil parameters
in.ChrdL = S_opt/AR_opt; %Chord Length

% Ixx calculation
in.Ixx = Ixx_req/(39.37^4);

% Total Volume and Volume of wing
in.Volw = Volwing;
in.eff_fuse = 0.8;
in.Volfuse = (0.25*pi*Df*Df*Lf*in.eff_fuse);
in.Voltot = in.Volfuse + in.Volw;

% Optimization
J = @(u)costfunc(u,in);
C = @(u)constraintfunc(u,in);
u0 = [0.18 0.01 0.01 0.005]';
lb = [0.001 0 0 0]'; % Lower limits
ub = [1 1 1 0.001]';   % upper limits
options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',10000000);
[uopt, ~, exitflag] = fmincon(J,u0,[],[],[],[],lb,ub,C,options);

%Wt_opt = rhow*Span*(2*(uopt(4)*uopt(2))+(uopt(3)*(uopt(1)-(2*(uopt(4))))));
[Ixx_opt, area_skin,area_spar1,area_spar2,area_spar3] = App_Wing_MoICalc_old(in.ChrdL, uopt(1), uopt(2), uopt(3), uopt(4));

Ixx_opt = Ixx_opt*(39.37^4);

area_opt = area_skin+area_spar1+area_spar2+area_spar3;
Mw_out = area_opt*S_opt*in.rhow;
Wopt = uopt;

end

function [J] = costfunc(u,in)

% Cost = Weight of beam
[~, area_skin,area_spar1,area_spar2,area_spar3] =...
    App_Wing_MoICalc_old(in.ChrdL,u(1),u(2),u(3),u(4));
% vol = area*Span;

% J = area + 5*u(1) + 10*u(2)+ 15*u(3) + 20*u(4);
J = in.Wskin*area_skin + in.Wsp1*area_spar1+area_spar2+area_spar3;

end

function [c_ineq, c_eq] = constraintfunc(u,in)

% Constraints
ineq1 = u(1) - in.Skmax;
ineq2 = u(2) - in.Sp1max;
ineq3 = u(3) - in.Sp2max;
ineq4 = u(4) - in.Sp3max;
ineq5 = -eye(4)*u;

[Ixx_calc,~,~,~,~] = ...
    App_Wing_MoICalc_old(in.ChrdL, u(1), u(2),u(3),u(4));


% Constraint type 1 (Dr. Bryant)
% ineq6 = (((rho*Volw/(vol*rhow)) - tar_buoy)^2.0) - 0.1;

% Constraint type 2 (Dr. Vermillion)
ineq6 = in.wmassrat - ((in.Volw*in.rhow)/in.rho*(in.Voltot));

ineq7 = -Ixx_calc + in.Ixx;

c_ineq=[ineq1;ineq2;ineq3;ineq4;ineq5;ineq6;ineq7];
c_eq= [];
end
