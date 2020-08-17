function  [optimalAoA] = App_AoA_opt_calc(optAR,optSpan,optD,optL)

% global Fz Df Lf Lscale gammaw eLw Clw0 xg h Cdw_visc Cdw_ind Cfe ClHStall 
% global Prated vf eta netaV Cdh_ovrall Cd0h rho ChrdT

global Fz Df Lf Lscale gammaw eLw Clw0 x_g h_sm Cdw_visc Cdw_ind Cfuse ClHStall
global eta netaV Cdh_ovrall Cd0_h rho Preq vin
global Power

% Lscale = 1;
% gammaw = 0.9512;
% eLw = 0.7019;
% Clw0 = 0.16;
% xg = 0.2*Lscale;
% h = -0.2*Lscale;                                                            %stability margin
% Cd0h = 1.7e-4; 
% Cdw_visc = 0.0297;
% Cdw_ind = 0.2697;
% Cdh_ovrall =  0.03917; 
% Cfe = 0.003;                                                                %skin-friction drag coefficient
%                                                                  %flight efficiency (can be a function of vf) 
% netaV = 0.8;                                                                %density of water
% rho = 1000.0;
% ChrdT = 0.12;

Len = optL*Lscale; 
Dia = optD*Lscale; 
lamda = Len/Dia;
L = Len*0.7; 

% Angle of atack 
AoA = -12.0:0.5:12;                                                         % upto stall angles (User defined) 
AoA = AoA.*(pi/180); 

% u(1) = AR 
% u(2) = X (Len Wing-Teth/Len HStab-Teth)

% Areas  
% Sh = 2;                 %(for AR 8)
Span = optSpan*Lscale; 
Sw = (Span^2)/optAR; 
Swet = pi*Len*Dia*((1 - (2/lamda))^(2/3))*(1 + 1/(lamda^2)); 

% Wing 
slopeW = ((2*pi*gammaw)./(1+((2.*pi.*gammaw)./(pi.*eLw.*optAR))));
Clw = Clw0 + slopeW.*AoA ; 

ClwD0 = 0.0026.*optAR; 
Cd0w = (0.00015.*optAR + 0.0053);
Cd0w = ones(1,numel(AoA)).*Cd0w; 
Cdw = (Cdw_ind./optAR+0.0334).*(Clw-ClwD0).^2 + Cd0w;  

% HStab 
Sh = ((x_g-h_sm)/(L+h_sm-x_g))*Sw;                                                  % Area gotten by satisfying stability margins 
xeta = (ClHStall*Sh)/((Sw*max(Clw)) + (ClHStall*Sh));                       % maximizing lift from H.Stabilizer 
Clh = (Sw*Clw*xeta)./(Sh*(1-xeta));                                         % Lift of H.Stabilizer 
Cdh = Cdh_ovrall.*((Clh*(Sh/Sw)).^2) + Cd0_h; 

% Fuselage 
CD_fuse = Cfuse*(Swet/Sw); 

% Net Lift 
CL = Clw + (Clh*(Sh/Sw)); 

% Net Drag 
CD = Cdw + (Cdh*(Sh/Sw)) + CD_fuse; 

% Performance metric 1: Finding optimal AoA 
Perf_1 = (CL.^3./CD.^2);

[maxVal AoAindex] = max(Perf_1); 
AoA = AoA.*(180/pi); 
optimalAoA = AoA(AoAindex); 
% Plotting 
% figure; 
% app.Plots.DrawPlot.Plot = plot(app.PlotAxes.DrawPlot,AoA,Perf_1)
% xline(optimalAoA,'--')

end 



