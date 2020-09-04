function App_SetGlobVar()

%Main tab Parameters
MTParams.Preq   = 100.0;
MTParams.vin    = 1.5;

MTParams.Dfll   = 0.5;
MTParams.Dful   = 1.2;
MTParams.Dfll   = 6.5;
MTParams.Lful   = 8;
MTParams.ARll   = 5;
MTParams.ARul   = 12;
MTParams.Spanll = 8;
MTParams.Spanul = 10;
MTParams.tar_buoy = 0.99; 
MTParams.wmassrat = 0.4;

%-------------------------------------------------------------------
% SFOT Parameters

SFOTParams.Lscale = 1; SFOTParams.gammaw = 0.95; SFOTParams.eLw = 0.71;
SFOTParams.Clw0 = 0.16; SFOTParams.x_g = 0.2*SFOTParams.Lscale;
SFOTParams.h_sm = -0.2*SFOTParams.Lscale; SFOTParams.Cd0_h = 1.7*(10^-4);
SFOTParams.Cdw_visc = 0.03; SFOTParams.Cdw_ind = 1/(pi*0.98);
SFOTParams.Cdh_ovrall =  0.16;  SFOTParams.Cfuse = 0.003; 

SFOTParams.eta = 0.3; SFOTParams.netaV = 0.8; 
SFOTParams.rho = 1000.0;

SFOTParams.ClHStall = 0.0791.*(10) + 0.1553;



%------------------------------------------------------------------------
% SWDT variables
SWDTParams.ChrdT = 0.12;

% Material properties
SWDTParams.E = 69*(10^9); %Aluminium
SWDTParams.rhow = 2710.0; %Al

% Percentage Deflection at centroid
SWDTParams.defper = 5.0;

SWDTParams.NSparmax = 3.0;

SWDTParams.Skmax = 0.2; SWDTParams.Sp1max = 0.15; 
SWDTParams.Sp2max = 0.12;  SWDTParams.Sp3max = 0.1; 

%Weights on objective function entities
SWDTParams.Wskin = 20; SWDTParams.Wsp1 = 1; 
SWDTParams.Wsp2 = 5; SWDTParams.Wsp3 = 10;

%------------------------------------------------------------------------
SFDTParams.Fthkmax = 0.5;
SFDTParams.x_1 = 0.4;SFDTParams.x_2 = 0.3;SFDTParams.x_W = 0.45;
SFDTParams.C_Hstab = 0.2;
SFDTParams.FOS = 1.5;
SFDTParams.S_yield = 270000000.0;
SFDTParams.Int_P = 100000.0;
SFDTParams.Ext_P = 220000.0;
SFDTParams.Dyn_P = 50000.0;

end