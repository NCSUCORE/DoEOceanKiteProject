function J = perfInd(AoA,eta,velW,vhcl,thr,thrCD,u)
%Load Optimization Inputs
alpha = AoA;
TSR = u(1:end);
eta = [eta; -eta];
%Initialize Vehicle Parameters

%Assumed fluid density
rho = 1000;

%Calculate Vehicle Coefficients
[CL,CD] = vhcl.getCLCD(thr,0);
%CD of tether and kite only
CD = CD.kiteThr+thrCD;

%Interpolate coefficients - CL and CD
alphaVhc = vhcl.stbdWing.alpha.Value;
cl = interp1(alphaVhc,CL,alpha);
cd = interp1(alphaVhc,CD,alpha);

%Interpolate coefficients - CP and CT
CP = vhcl.turb1.CpLookup.Value;
CT = vhcl.turb1.CtLookup.Value;
turbDiam = vhcl.turb1.diameter.Value;
turbArea = pi*turbDiam^2/4;
refArea = vhcl.fluidRefArea.Value;
N = vhcl.numTurbines.Value/2; %Num turbines per side
areaRatio = (turbArea)/refArea; %area ratio of each turbine
refTSR = vhcl.turb1.RPMref.Value;

%Interpolate and scale to vehicle ref area. Note that perf index accounts
%for 12 deg tilt in turbine rotor
cp = N*interp1(refTSR,CP,TSR)*areaRatio.*cos((12-alpha)*pi/180).^3;
ct = N*interp1(refTSR,CT,TSR)*areaRatio.*cos((12-alpha)*pi/180).^3;

%Account for impact of normalized angular velocity (eta = 0 in straight
%flight)
ctVal = sum(ct.*(1+eta).^2);
glideRatio = cl./(ctVal+cd);

%Calculate effective coefficient of power accounting for gearbox and
%generator efficiencies
Cp = sum((1+eta).^3.*cp);
cpSys = glideRatio.^3.*Cp;

%Calculate power
J = -cpSys;