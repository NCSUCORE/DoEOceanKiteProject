function[CL,CD] = XFLRWingCalc(AoA_deg,AR,gammaw,eLw,Clw0,Cdw_visc,Cdw_ind,wingAirfoil)
% AR = Aspect Ratio
% gammaw = slope effiency factor
% eLw = oswald efficiency factor
% Clw0 = lift at 0 AoA
% Cdw_visc = viscous drag ceofficient factor
% Cdw_ind = induced drag ceofficient factor

if ~strcmp(wingAirfoil,'NACA2412')
    warning('XFLR values are only applicable to wingAirfoil.Value=NACA2412');
end


% Camber factor (fit to AR)
ClwD0 = 0.0026*AR;
% Lift at zero drag (fit to AR)
Cd0w = 0.00015*AR + 0.0053;

%slope of lift curve
slopeW = ((2*pi*gammaw)./(1+((2.*pi.*gammaw)./(pi.*eLw.*AR))))*(pi/180);

% preallocate matrices
CL = AoA_deg*nan;
CD = AoA_deg*nan;
% loop over all values of AaA_deg
for ii = 1:numel(AoA_deg)
    % lift coefficient
    CL(ii) = Clw0 + slopeW*AoA_deg(ii);
    % Drag Coefficient
    CD(ii) = (Cdw_ind/AR+Cdw_visc)*(CL(ii)-ClwD0)^2 + Cd0w;
    
end

end
