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
Preq = Prated; vin = vf;

% Limits on Aspect Ratio
AR_llim = ARll; AR_ulim = ARul;
Span_llim = Spanll; Span_ulim = Spanul;

%-------------------------------------------------------------------
% SFOT variables
global Lscale gammaw eLw Clw0 x_g h_sm Cdw_visc Cdw_ind Cfuse ClHStall
global eta netaV Cdh_ovrall Cd0_h rho 


Lscale = 1; gammaw = yW; eLw = eW; Clw0 = CL0; x_g = xg*Lscale;
h_sm = h*Lscale; Cd0_h = Cd0h; Cdw_visc = Kvisc; Cdw_ind = 1/(pi*eDW);
Cdh_ovrall =  Cdh;  Cfuse = Cfe; 

eta = 0.3; netaV = 0.8; 
rho = 1000.0;

ClHStall = 0.0791.*(Hstall) + 0.1553;



%------------------------------------------------------------------------
% SWDT variables
global E defper ChrdT rhow
global tar_buoy wmassrat 
global Skmax Sp1max Sp2max Sp3max
global Wskin Wsp1 Wsp2 Wsp3


ChrdT = 0.12;
tar_buoy = TarB; wmassrat = MassF;


% Material properties
E = 69*(10^9); %Aluminium
rhow = 2710.0; %Al

% Percentage Deflection at centroid
defper = WingDef;


Skmax = 0.2; Sp1max = 0.1;  Sp2max = 0.1;  Sp3max = 0.1; 

%Weights on objective function entities
Wskin = 20; Wsp1 = 1; Wsp2 = 5; Wsp3 = 10;

%------------------------------------------------------------------------
global Fthkmax
global x_1 x_2 x_W C_Hstab FOS S_yield Int_P Dyn_P Ext_P
Fthkmax = 0.5;
x_1 = x1;x_2 = x2;x_W = xW;
C_Hstab = Hstab_c;
FOS = fos;
S_yield = Syield;
Int_P = IntP;
Ext_P = ExtP;
Dyn_P = DynP;

end