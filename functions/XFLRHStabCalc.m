function[CL,CD] = XFLRHStabCalc(AoA_deg,Sw,Sh,AoA_inc)

% Sw = wing planform area 
% Sh = hStab planform area
% AoA_deg = Angle of attack in deg 
% AoA_inc = Angle of incidence of Hstab 

%% Lift Coefficienct 

HStab_CL_XFLRw = 0.0791.*(AoA_deg+AoA_inc) + 0.1553;
HStab_CL_XFLR = HStab_CL_XFLRw*(Sh/Sw);
CL = HStab_CL_XFLR; 

%% Drag Coefficient 

HStab_CD_XFLR = 0.03917.*(HStab_CL_XFLRw.^2) + 0.057; 
HStab_CD_XFLR = HStab_CD_XFLR*(Sh/Sw);
CD = HStab_CD_XFLR; 

end 