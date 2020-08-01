function [c_ineq, c_eq] = powRatedConst(u,Lscale)

global Fz Df Lf gammaw eLw Clw0 xg h Cdw_visc Cdw_ind Cfe ClHStall Prated vf eta Cdh_ovrall Cd0h rho netaV
Cd0w = 0.00015.*u(1) + 0.0053;

Len = Lf*Lscale; 
Dia = Df*Lscale; 
lamda = Len/Dia;
L = Len*0.7; 

% Angle of atack 
AoA = -12.5:0.5:12;                                                         % upto stall angles (User defined) 
AoA = AoA.*(pi/180); 

% u(1) = AR 
% u(2) = X (Len Wing-Teth/Len HStab-Teth)

% Areas  
% Sh = 2;                 %(for AR 8)
Span = u(2)*Lscale; 
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

% Fuselage 
CD_fuse = Cfe*(Swet/Sw); 

% Net Lift 
CL = Clw + (Clh*(Sh/Sw)); 

% Net Drag 
CD = Cdw + (Cdh*(Sh/Sw)) + CD_fuse; 

% Performance metric 1: Finding optimal AoA 
Perf_1 = max((CL.^3./CD.^2));


Power = (2/27)*eta*Perf_1*Sw*(vf^3); 
% Calculating tensions/Lifts  
splSpeed = vf/3; 
Fz = 0.5*Power/splSpeed*(10^3);


ineq1 = Prated - Power; 

c_ineq = ineq1;
c_eq = []; 

end 