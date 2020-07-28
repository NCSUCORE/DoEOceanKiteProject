function [AR, Span, Jopt, Fz_out,exitflag] = Loadcalc_opt1(Df_in,Lf_in)
%%  Main SS Hydro Optimization Function
%u(1) = Aspect ratio
%u(2) = Span (Total Wingspan)
global Fz Df Lf Lscale gammaw eLw Clw0 xg h Cdw_visc Cdw_ind Cfe ClHStall 
global Prated vf eta netaV Cdh_ovrall Cd0h rho ChrdT
Lscale = 1;             %scaling factor
gammaw = 0.9512;        %
eLw = 0.7019;           %
Clw0 = 0.16;            %
xg = 0.2*Lscale;        %center of gravity 
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


% Specifying max Cl,H 
HStall = 10;                          %stall angle??                                      %in [deg]
ClHStall = 0.0791.*(HStall) + 0.1553; %Max lift coeff given stall angle

u0 = [6 10]';  %initial guess for [Aspect ratio,Span]
%fmincon using sqp
options = optimoptions('fmincon','Display','iter','Algorithm','sqp','MaxFunctionEvaluations',1e6,'MaxIterations',1e6);

lb = [4 7]';   %lower bounds on Aspect ratio and span 
ub = [25 12]'; %Get u(2) upper bound from examining min value of Lamda

[uopt,Jopt,exitflag] = fmincon(@SFT_cost,u0,[],[],[],[],lb,ub,@SFT_constraint,options);

Fz_out = Fz;
AR   = uopt(1);
Span = uopt(2)*Lscale;

end

%% Cost function for Aspect ratio and Span
function J = SFT_cost(u)
global Lscale ChrdT

Span = u(2)*Lscale; %span based on scaling

%Wing Volume
J = ChrdT*Span^3/u(1)^2 ; %Objective function based on span aspect ratio 
                          %and chord thickness is the wings volume
end 

%% Constraint functions
function [c_ineq, c_eq] = SFT_constraint(u)

global Fz Df Lf Lscale gammaw eLw Clw0 xg h Cdw_visc Cdw_ind Cfe ClHStall 
global Prated vf eta Cdh_ovrall Cd0h rho netaV
Cd0w = 0.00015.*u(1) + 0.0053;

Len = Lf*Lscale; %scaled length
Dia = Df*Lscale; %scaled diameter
lamda = Len/Dia; %tether attachment length ratio
L = Len*0.7; 

% Angle of atack 
AoA = -12.5:0.5:12;  %range of angle of attack upto stall angles (User defined) 
AoA = AoA.*(pi/180); %angle of attack in radians

Span = u(2)*Lscale; %Scaled span
Sw = (Span^2)/u(1); 
Swet = pi*Len*Dia*((1 - (2/lamda))^(2/3))*(1 + 1/(lamda^2)); 

% Wing 
slopeW = ((2*pi*gammaw)./(1+((2.*pi.*gammaw)./(pi.*eLw.*u(1)))));
Clw = Clw0 + slopeW.*AoA ; 

ClwD0 = 0.0026.*u(1); 
Cd0w = (0.00015.*u(1) + 0.0053);
Cd0w = ones(1,numel(AoA)).*Cd0w; 
Cdw = (Cdw_ind./u(1)+0.0334).*(Clw-ClwD0).^2 + Cd0w;  

% HStab 
Sh = ((xg-h)/(L+h-xg))*Sw;                                                  % Area gotten by satisfying stability margins 
xeta = (ClHStall*Sh)/((Sw*max(Clw)) + (ClHStall*Sh));                       % maximizing lift from H.Stabilizer 
Clh = (Sw*Clw*xeta)./(Sh*(1-xeta));                                         % Lift of H.Stabilizer 
Cdh = Cdh_ovrall.*((Clh*(Sh/Sw)).^2) + Cd0h; 

% Fuselage drag
CD_fuse = Cfe*(Swet/Sw); 

% Net Lift 
CL = Clw + (Clh*(Sh/Sw)); %Kite lift coeff

% Net Drag 
CD = Cdw + (Cdh*(Sh/Sw)) + CD_fuse; %Kite drag coeff

% Performance metric 1: Finding optimal AoA 
Perf_1 = max((CL.^3./CD.^2));

%Power from Miles Loyd
Power = (2/27)*eta*Perf_1*Sw*(vf^3);

% Calculating tensions/Lifts  
splSpeed = vf/3; %1/3 of flow speeds
Fz = 0.5*Power/splSpeed*(10^3); %verticle force on wings

%difference from rated power and given power (want equal)
ineq1 = Prated - Power; 

%power inequality constraint
c_ineq = ineq1;

%no equality constraint
c_eq = []; 

end 
