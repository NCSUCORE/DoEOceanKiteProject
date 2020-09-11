function[CL,CD] = XFLRHStabCalc_Ind(AoA_deg,Sw,Sh,AoA_inc)

% Sw = wing planform area 
% Sh = hStab planform area
% AoA_deg = Angle of attack in deg 
% AoA_inc = Angle of incidence of Hstab 

%% Lift Coefficienct 

HStab_CL_XFLRw = 0.08253.*(AoA_deg+AoA_inc) + 0.0009738;
HStab_CL_XFLR = HStab_CL_XFLRw*(Sh/Sw);
CL = HStab_CL_XFLR; 

%% Drag Coefficient 

HStab_CD_XFLR = 0.04596.*(HStab_CL_XFLRw.^2) + 0.003945; 
HStab_CD_XFLR = HStab_CD_XFLR*(Sh/Sw);
CD = HStab_CD_XFLR; 

end 