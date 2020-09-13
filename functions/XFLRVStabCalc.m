function[CL,CD] = XFLRVStabCalc(AoA_deg,Sw,Sv)

% Sw = wing planform area 
% Sh = hStab planform area
% AoA_deg = Angle of attack in deg 


%% Lift Coefficienct 

VStab_CL_XFLRw = 0.08258.*(AoA_deg) + 0.0009433;
VStab_CL_XFLR = VStab_CL_XFLRw*(Sv/Sw);
CL = VStab_CL_XFLR*0.5; 

%% Drag Coefficient 

VStab_CD_XFLR = 0.04698.*(VStab_CL_XFLRw.^2) + 0.00427; 
VStab_CD_XFLR = VStab_CD_XFLR*(Sv/Sw);
CD = VStab_CD_XFLR*0.5; 

end 