function [J,Flift,CL,CD,Power] = SFOTcost(u,SFOT,OPT,Tow)

condition = exist('Tow','var');

alpha = 0:.25:20;

SFOT.W.AR = u(1); 
SFOT.W.b = u(2);

SFOT.W.wing = xfoil_AR_func_noflap(SFOT.W);

Sw = SFOT.W.b^2/SFOT.W.AR;
Sh = SFOT.H.A;
Sv = SFOT.V.A;
Sf = SFOT.F.D^2*pi/4*cosd(alpha)+(SFOT.F.D^2*pi/4+SFOT.F.D*SFOT.F.L)*(1-cosd(alpha));
St = SFOT.T.A;

CLw =         interp1(SFOT.W.wing.alfa_c,SFOT.W.wing.CL_c,alpha,'linear','extrap');
CLh = (Sh/Sw)*interp1(SFOT.H.hStab.alfa_c,SFOT.H.hStab.CL_c,alpha,'linear','extrap');

CDw =         interp1(SFOT.W.wing.alfa_c,SFOT.W.wing.CD_c,alpha,'linear','extrap');
CDh = (Sh/Sw)*interp1(SFOT.H.hStab.alfa_c,SFOT.H.hStab.CD_c,alpha,'linear','extrap');
CDv = (Sv/Sw)*interp1(SFOT.V.vStab.alfa_c,SFOT.V.vStab.CD_c,alpha,'linear','extrap');
CDf = (Sf/Sw).*(SFOT.F.CD.*cosd(alpha)+(1-cosd(alpha).*SFOT.F.CS));
CDt = (St/Sw)*cosd(alpha).^2*SFOT.T.CD;

CL = CLw + CLh;
CD = CDw + CDh + CDv + CDf;
CDtot = CDw + CDh + CDv + CDf + CDt;

if condition 
    vApp = Tow;
else
    vApp = (CL./CDtot.*OPT.vin)*.3;
end

Flift = 1./2.*OPT.rho.*vApp.^2.*CLw.*Sw;

Power = 2./27.*OPT.rho.*OPT.vin.^3.*CL.^3./CD.^2.*Sw;

% J = -max(Power);
J = -max(Flift);

% figure; subplot(3,1,1); hold on; grid on;
% plot(alpha,-J*1e-3,'b-'); xlabel('Alpha [deg]'); ylabel('Power [kW]')
% subplot(3,1,2); hold on; grid on;
% plot(alpha,Flift*1e-3,'b-'); xlabel('Alpha [deg]'); ylabel('Lift [kN]')
% subplot(3,1,3); hold on; grid on;
% plot(alpha,vApp,'b-'); xlabel('Alpha [deg]'); ylabel('$\mathrm{V_{app}}$ [m/s]')

end 