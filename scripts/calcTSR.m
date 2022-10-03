clear val ind
loadComponent('ultDoeKite')
loadComponent('pathFollowingTether');                       %   Manta Ray tether
thr.tether1.setDensity(1000,'kg/m^3')
thr.tether1.diameter.setValue(0.022,'m')
alph = 10:0.1:20;
T = 1:.1:7;
eta1 = -0.2:0.01:.2;


[alpha,TSR,TSR1,eta]=ndgrid(alph,T,T,eta1);
eta2 = -eta;
[CL,CD] = vhcl.getCLCD(thr,3500);
CD = CD.kiteThr;
alphaVhc = vhcl.stbdWing.alpha.Value;

CP = vhcl.turb1.CpLookup.Value;
CT = vhcl.turb1.CtLookup.Value;
[ref,refInd] = max(CP./CT)
refTSR = vhcl.turb1.RPMref.Value;
compInd = find(T==refTSR(refInd))
cpRef = CP(compInd);
ctRef = CT(compInd);
cpctTSR = refTSR(refInd);
turbDiam = vhcl.turb1.diameter.Value;
refArea = vhcl.fluidRefArea.Value;
areaRatio = 2*pi*turbDiam^2/4/refArea;

cl = interp1(alphaVhc,CL,alpha);
cd = interp1(alphaVhc,CD,alpha);
cp = interp1(refTSR,CP,TSR)*areaRatio;
ct = interp1(refTSR,CT,TSR)*areaRatio;
cp1 = interp1(refTSR,CP,TSR1)*areaRatio;
ct1 = interp1(refTSR,CT,TSR1)*areaRatio;
coeff = cl.^3.*2.*cp./(2.*ct+cd).^3;
coeff1 = cl.^3.*((1+eta2).^3.*cp+(1+eta).^3.*cp1)...
    ./(ct.*(1+eta2).^2+ct1.*(1+eta).^2+cd).^3;
coeffRatio = cl.^3.*((1+eta2).^3.*cp+(1+eta).^3.*cp1)...
    ./(ct.*(1+eta2).^2+ct1.*(1+eta).^2+cd).^3./...
    (cl.^3.*((1+eta2).^3.*cpRef+(1+eta).^3.*cpRef)...
    ./(ctRef.*(1+eta2).^2+ctRef.*(1+eta).^2+cd).^3);
max(coeff1,[],'all')/coeff1(51,21,21,21)
[m,n] = size(alpha);


figure
contour(squeeze(TSR(1,:,:,1)),squeeze(TSR1(1,:,:,1)),...
    squeeze(coeffRatio(1,:,:,1)),'Fill','on','LineColor','k')
colorbar
xlabel 'TSR1'
ylabel 'TSR2'

%%
figure
contour(squeeze(TSR(5,:,:,31)),squeeze(TSR1(5,:,:,31)),squeeze(coeff1(45,:,:,41)),'Fill','on','LineColor','k')
colorbar
xlabel 'TSR'
ylabel 'TSR1'


%%
s = size(alpha)
% for i = 1:s(1)
%     for j = 1:s(4)
%
%     end
% end
[val,ind] = max(coeff1,[],[2 3],'linear');

mCoeff = squeeze(coeff1(ind));
nomCoeff = squeeze(coeff(:,compInd,compInd,:));
tsrOut = squeeze(TSR(ind));
tsr1Out = squeeze(TSR1(ind));
etaOut = squeeze(eta(ind));
alphaOut = squeeze(alpha(ind));

figure
contour(alphaOut,etaOut,tsrOut(:,end:-1:1),'Fill','on')
colorbar

figure
contour(alphaOut,etaOut,tsr1Out-vhcl.turb1.optTSR.Value,'Fill','on')
colorbar
xlabel '$\alpha$ [deg]'
ylabel 'Normalized Yaw Rate $\omega_{x}r_y/v_{app}$'
h = colorbar
h.Label.String = '$\Delta_{TSR}$ vs Max $C_p/C_t$ strategy'
h.Label.Interpreter = 'latex'

figure
contour(alphaOut,etaOut,(mCoeff./nomCoeff-1)*100,'Fill','on'...
    ,'LineColor','k','ShowText','on')
xlabel '$\alpha$ [deg]'
ylabel 'Normalized Yaw Rate $\omega_{x}r_y/v_{app}$'
h = colorbar
h.Label.String = 'Improvement over max $C_p/C_t$ [$\%$]'
h.Label.Interpreter = 'latex'
clear TSRLookup
tsr = tsr1Out

TSRLookup(2).tsr = tsr1Out;
TSRLookup(1).tsr = tsrOut(:,end:-1:1);