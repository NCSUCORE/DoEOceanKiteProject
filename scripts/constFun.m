function [g,ceq] = constFun(AoA,eta,velW,vhcl,thr,thrCD,u)
alpha = AoA;
TSR = u(1:end);
eta = [eta; -eta];
%Initialize Vehicle Parameters

rho = 1000;
% thr.tether1.setDensity(1000,'kg/m^3');
% thr.tether1.setDiameter(0.018,'m');

[CL,CD] = vhcl.getCLCD(thr,0);
CD = CD.kiteThr+thrCD;
alphaVhc = vhcl.stbdWing.alpha.Value;

CP = vhcl.turb1.CpLookup.Value;
CT = vhcl.turb1.CtLookup.Value;
turbDiam = vhcl.turb1.diameter.Value;
turbArea = pi*turbDiam^2/4;
refArea = vhcl.fluidRefArea.Value;
N = vhcl.numTurbines.Value/2; %Num turbines per side
areaRatio = (turbArea)/refArea; %area ratio of each turbine
refTSR = vhcl.turb1.RPMref.Value;

cl = interp1(alphaVhc,CL,alpha);
cd = interp1(alphaVhc,CD,alpha);
cp = N*interp1(refTSR,CP,TSR)*areaRatio.*cos(alpha*pi/180).^3;
ct = N*interp1(refTSR,CT,TSR)*areaRatio;



glideRatio = cl./(ct(1).*(1+eta(1)).^2+ct(2).*(1+eta(2)).^2+cd);
vApp = velW.*glideRatio;
pow = 1/2*rho*(vApp*(1+eta)).^3*refArea.*cp;
tau = pow*turbDiam./(2*(vApp.*(1+eta)).*TSR);

g = tau-vhcl.turb1.torqueLim.Value;%;gamma-5.5;1-gamma];
ceq = [];