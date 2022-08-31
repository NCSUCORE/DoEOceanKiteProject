function J = perfInd(AoA,eta,velW,vhcl,thr,thrL,u)
%Load Optimization Inputs
alpha = AoA;
TSR = u(1:end);
eta = [eta; -eta];
%Initialize Vehicle Parameters
gbLoss = vhcl.gearBoxLoss.Value; %Gearbox loss W/RPM
kt = vhcl.genKt.Value; %Armature torque constant Nm/A
R = vhcl.genR.Value; %Motor resistance Ohms
gbRat = vhcl.gearBoxRatio.Value; %gearbox ratio

%Assumed fluid density
rho = 1000;

%Calculate Vehicle Coefficients
[CL,CD] = vhcl.getCLCD(thr,thrL*4);
%CD of tether and kite only
CD = CD.kiteThr;

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
vApp = velW.*glideRatio;
vAppTurb = vApp.*(1+eta);

% Term used to normalize coefficients in future calculations
powNorm = 1/2*rho*vApp.^3*refArea;

%Gearbox Losses
RPM = TSR.*vAppTurb*(60/(pi*turbDiam));
gbEta = RPM.*gbLoss./powNorm;

%Generator Losses
motOmega = RPM*gbRat*2*pi/60;
genPow = (cp-gbEta)/N.*powNorm;
genT = genPow./motOmega/1.3558*12*16;
genC = genT/kt;
genL = genC.^2*R;
genEta = N*genL./powNorm;

%Calculate effective coefficient of power accounting for gearbox and
%generator efficiencies
Cp = sum((1+eta).^3.*cp);
Cpeff = Cp-sum(gbEta-genEta);
Cpeff(Cpeff<0) = 0;
cpSys = glideRatio.^3.*Cpeff;

%Calculate power
J = -1/2*1000*velW.^3.*cpSys*refArea;