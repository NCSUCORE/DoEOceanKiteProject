function [Mfuse,thk,exitflag] = App_SFDT2(D,L,fuse,~,~,~,loads)
DecVar.L = L;  % shear stress calc
DecVar.D = D; %decision variable 

Forces.FzW = loads.Wp+loads.Ws; 
Forces.FzH = loads.H; 
Forces.Thr = loads.T;
pos.W = fuse.rWing;
pos.H = fuse.rStab;
pos.T = fuse.rBrid;

%% Input parameters 
Inp.fos = 5;              %factor of safety 
Inp.Syield = 2.068427e+9;         %yield stress 

% Internal, external and dynamic pressures
Inp.IntP = 10^5; 
Inp.ExtP = 2.2e5; 
Inp.DynP = 5e4; 

% Densities  
Inp.rhow = 1000; 
Inp.rhoAl = 1800; 
Inp.tarBuoy = 1; 

%% 
lb = 0.01; 
ub = 0.03;
u0 = 0.01; 

J = @(u)DLCalc_cost(DecVar,u);
C = @(u)DLCalc_constraint(u,Forces,DecVar,Inp,pos);

options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',1e7,'MaxIterations',1e7);
[uopt, Jopt, exitflag] = fmincon(J,u0,[],[],[],[],lb,ub,C,options);

Mfuse = Jopt*pi*Inp.rhoAl;
thk = uopt; 

% end 




%% functions 
function J = DLCalc_cost(DecVar,u)
r = 0.5*DecVar.D; 
l = DecVar.L; 

J = (u^2 + 2*u*r)*l; 
end 

function [c_ineq, c_eq] = DLCalc_constraint(u,Forces,DecVar,Inp,Pos)
r = 0.5*DecVar.D; 
l = DecVar.L; 

% Length from shear stress 
ineq1 = (Forces.FzW+Forces.FzH)/(pi*(r^2-(r-u)^2)) - 1/Inp.fos*Inp.Syield; 

% Radius for hoop stress due to shear  
Pdiff = Inp.ExtP + Inp.DynP - Inp.IntP; 
ineq2 = (Pdiff*r)/u - 1/Inp.fos*Inp.Syield; 

% Buckling of fuselage  
BMmax = Forces.FzW*(Pos.T-Pos.W); %max bending moment
SMod = pi*r^2*u; 
ineq3 = BMmax/SMod - 1/Inp.fos*Inp.Syield;

% Neutral buoyancy 
eq4 = Inp.rhoAl*(u^2 + 2*r*u) - Inp.rhow*r^2 - Inp.tarBuoy; 

c_ineq = [ineq1; ineq2; ineq3];  
c_eq = [eq4]; 

end 

end 