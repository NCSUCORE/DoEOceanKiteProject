clc 
clear all
close all
loadComponent('ultDoeKiteTSR')
loadComponent('pathFollowingTether');

n = vhcl.numTurbines.Value;
alph = 0:0.1:20;
eta1 = 0:0.01:.2;
cdThr1 = 0:0.01:0.5;

[cdThr,eta]=ndgrid(cdThr1,eta1);
[CL,CD] = vhcl.getCLCD(thr,0);
CL = CL;
CD = CD.kite;
alphaVhc = vhcl.stbdWing.alpha.Value;

CP = vhcl.turb1.CpLookup.Value;
CT = vhcl.turb1.CtLookup.Value;
ind = find(vhcl.turb1.RPMref.Value == vhcl.turb1.optTSR.Value);
turbDiam = vhcl.turb1.diameter.Value;
refArea = vhcl.fluidRefArea.Value;
areaRatio = pi*turbDiam^2/4/refArea;


cp = CP(ind)*areaRatio;
ct = CT(ind)*areaRatio;
cp1 = cp;
ct1 = ct;
% figure
for i = 1:numel(eta1)
    for j = 1:numel(cdThr1)
        f = @(a) costFun(cdThr(j,i),eta(j,i),cp,ct,a,CL,CD,alphaVhc,n);
        [AoA(j,i),fMin(j,i)] = fminbnd(f,0,20);
    end
end

figure
contourf(cdThr,eta,-fMin)
a = colorbar;
a.Label.Interpreter = 'latex';
a.Label.String = '$C_\mathrm{P_{eff}}$';
a.Label.FontSize = 14;
set(gca,'FontSize',14)
ylabel '$\xi$'
xlabel '$C_\mathrm{D_{thr}}$'

figure
contourf(cdThr,eta,AoA)
a = colorbar;
a.Label.Interpreter = 'latex';
a.Label.String = 'AoA [deg]';
a.Label.FontSize = 14;
set(gca,'FontSize',14)
ylabel '$\xi$'
xlabel '$C_\mathrm{D_{thr}}$'


function J = costFun(cdThr,eta,cp,ct,a,CL,CD,alphaVhc,n)

cl = interp1(alphaVhc,CL,a);
cd = interp1(alphaVhc,CD,a);

cpEff = n/2*cp*((1+eta)^3+(1-eta)^3);
ctEff = n/2*ct*((1+eta)^2+(1-eta)^2);
cd+ctEff;

J = -cl.^3.*(cpEff)./(ctEff+cd+cdThr).^3;
end