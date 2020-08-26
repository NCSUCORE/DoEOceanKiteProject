function App_SetGlobVar(app)
InVarBox = fieldnames(app.InputBoxs);
InVarSlide = fieldnames(app.Sliders);
for iInVar = 1:numel(InVarBox)
    eval(sprintf('%s = app.InputBoxs.%s.Value;',InVarBox{iInVar},InVarBox{iInVar}))   
end

for iInVar = 1:numel(InVarSlide)
    eval(sprintf('%s = app.Sliders.%s.Value;',InVarSlide{iInVar},InVarSlide{iInVar}))   
end


%Main tab
global Preq vin
global AR_llim AR_ulim Span_llim Span_ulim
Preq = 100.0; vin = 1.5;

% Limits on Aspect Ratio
AR_llim = 5; AR_ulim = 12;
Span_llim = 8; Span_ulim = 10;

%-------------------------------------------------------------------
% SFOT variables
global Lscale gammaw eLw Clw0 x_g h_sm Cdw_visc Cdw_ind Cfuse ClHStall
global eta netaV Cdh_ovrall Cd0_h rho 


Lscale = 1; gammaw = 0.95; eLw = 0.71; Clw0 = 0.16; x_g = 0.2*Lscale;
h_sm = -0.2*Lscale; Cd0_h = 1.7*(10^-4); Cdw_visc = 0.03; Cdw_ind = 1/(pi*0.98);
Cdh_ovrall =  0.16;  Cfuse = 0.003; 

eta = 0.3; netaV = 0.8; 
rho = 1000.0;

ClHStall = 0.0791.*(10) + 0.1553;



%------------------------------------------------------------------------
% SWDT variables
global E defper ChrdT rhow
global tar_buoy wmassrat 
global Skmax Sp1max Sp2max Sp3max
global NSparmax
global Wskin Wsp1 Wsp2 Wsp3


ChrdT = 0.12;
tar_buoy = 0.99; wmassrat = 0.4;


% Material properties
E = 69*(10^9); %Aluminium
rhow = 2710.0; %Al

% Percentage Deflection at centroid
defper = 5.0;

NSparmax = 3.0;

Skmax = 0.2; Sp1max = 0.15;  Sp2max = 0.12;  Sp3max = 0.1; 

%Weights on objective function entities
Wskin = 20; Wsp1 = 1; Wsp2 = 5; Wsp3 = 10;

%------------------------------------------------------------------------
global Fthkmax
global x_1 x_2 x_W C_Hstab FOS S_yield Int_P Dyn_P Ext_P
Fthkmax = 0.5;
x_1 = 0.4;x_2 = 0.3;x_W = 0.45;
C_Hstab = 0.2;
FOS = 1.5;
S_yield = 270000000.0;
Int_P = 100000.0;
Ext_P = 220000.0;
Dyn_P = 50000.0;

end