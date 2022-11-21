function plotTurbPerformance(obj,vAppMax,imp)

if ~exist('vAppMax')
    vAppMax = 3;
    fprintf('Max apparent velocity set to 3 m/s. Declare vAppMax in function call to specify peak apparent velocity presented to turbines in m/s\n')
end

turb = obj.turb1;
tauLim = turb.torqueLim.Value;
diam = turb.diameter.Value;
figure; hold on; grid on;
plot(turb.RPMref.Value,turb.CpLookup.Value,'k','LineWidth',1)
plot(turb.RPMref.Value,turb.CtLookup.Value,'r','LineWidth',1)
plot(turb.RPMref.Value,turb.CpLookup.Value./turb.CtLookup.Value,'--k','LineWidth',1)
%             plot(turb.RPMref.Value,turb.CpLookup.Value./turb.CtLookup.Value.^3,':k','LineWidth',1)
legend('$C_\mathrm{P}$','$C_\mathrm{T}$','$C_\mathrm{P}/C_\mathrm{T}$','$C_p/C_t^3$')
xlabel 'TSR'
ylabel 'Coefficient'
ylim([0 inf])
set(gca,'FontSize',12)

% Rotor Performance Surface
vApp = 0.1:0.01:vAppMax;
idx = 10*turb.optTSR.Value;

TSR = turb.optTSR.Value;
TSRRef = turb.RPMref.Value;
ind = find(TSR==TSRRef);
cP = turb.CpLookup.Value;
cT = turb.CtLookup.Value;

tRot = 1/2*1000.*vApp.^3*pi/4*diam^2.*cP(ind)./(vApp.*TSR/(pi*diam)*2*pi);
tRot(tRot>tauLim) = tauLim;
cTau = turb.tauCoefLookup.Value;
cTauLookup = turb.tauCoefTSR.Value;

cTauReq = tRot./(pi*diam^3/8*1/2*1000.*vApp.^2);

gamma = interp1(cTau,cTauLookup,cTauReq);
gamma(isnan(gamma))=TSR;
cPRot = interp1(TSRRef,cP,gamma);

rotPow = 1/2*1000*vApp.^3*pi/4*diam^2.*cPRot;
RPM = gamma.*vApp*60/(pi*diam);
gbLoss = RPM*obj.gearBoxLoss.Value;
genSpeed = RPM*obj.gearBoxRatio.Value*2*pi/60;
genPowerIn = rotPow-gbLoss;
genTorque = genPowerIn./genSpeed/1.3558*12*16;
genCurrent = genTorque./obj.genKt.Value;
genLoss = genCurrent.^2*obj.genR.Value;
genPowerOut = rotPow-genLoss-gbLoss;
genEff = genPowerOut./genPowerIn;
gbEff = 1- gbLoss./rotPow; 
if ~exist('imp')
    imp = 0;
    fprintf('Plotting in metric units by default. Declare imp = 1 in function call to plot in imperial units\n')
end

if imp == 1
    tRot = tRot/1.356;
    xlab = 'Rotor Torque [ft-lbf]';
    vApp = vApp*1.94384;
    xlabV = 'Apparent Velocity [knots]';
else
    xlab = 'Rotor Torque [Nm]';
    xlabV = 'Apparent Velocity [m/s]';
end

%         figure
%         plot(vApp,tRot)
%         xlabel(xlabV)
%         ylabel(xlab)

figure
plot(vApp,RPM)
xlabel(xlabV)
ylabel('Rotor Speed [RPM]')


figure
plot(RPM,genPowerOut./rotPow,'DisplayName','System')
hold on
plot(RPM,1-gbLoss./rotPow,'DisplayName','Gearbox Efficiency')
plot(RPM,genPowerOut./genPowerIn,'DisplayName','Motor Efficiency')
xlabel('Rotor Speed [RPM]')
ylabel('Conversion Efficiency')
ylim([0 1])
xlim([0 inf])
legend
grid on

figure
plot(vApp,genPowerOut./rotPow,'DisplayName','System')
hold on
plot(vApp,1-gbLoss./rotPow,'DisplayName','Gearbox Efficiency')
plot(vApp,genPowerOut./genPowerIn,'DisplayName','Motor Efficiency')
xlabel('Apparent Velocity [m/s]')
ylabel('Conversion Efficiency')
ylim([0 1])
xlim([0 inf])
legend
grid on

figure(459)
hold on
plot(vApp,genPowerOut)

figure
tiledlayout(2,1)
nexttile
plot(RPM,tRot)
xlabel('Rotor Speed [RPM]')
ylabel(xlab)
set(gca,'FontSize',12)
yyaxis right
hold on
plot(RPM,rotPow)
plot(RPM,genPowerOut)
ylabel('Power [W]')
set(gca,'FontSize',12)
legend('Torque Curve','Mechanical Power','Electrical Power','Location','southeast')
nexttile
plot(RPM,vApp)
ylabel(xlabV)
xlabel('Rotor Speed [RPM]')
set(gca,'FontSize',12)
end
