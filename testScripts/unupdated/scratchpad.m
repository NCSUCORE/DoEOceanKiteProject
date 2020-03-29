close all
tsc = tscILC;

FLift = sqrt(sum(tsc.FLiftBdy.Data.^2,1));
FDrag = sqrt(sum(tsc.FDragBdy.Data.^2,1));
vApp  = squeeze(sqrt(sum(tsc.vAppLclBdy.Data(:,1,:).^2)));
vApp2 = timesignal(timeseries(vApp.^2,tsc.vAppLclBdy.Time));
density = env.water.density.Value;
dynPress = (0.2*density*vhcl.fluidRefArea.Value*vApp2.Data);
vf = sqrt(sum(env.water.flowVec.Value.^2));
Aref = vhcl.fluidRefArea.Value;
vfTarget = 0.25;
PTarget = 750;
ETargets = [0.1 0.25 0.5 0.75 1];

CL = FLift(:)./dynPress(:);
CD = FDrag(:)./dynPress(:);
CLCD = CL./CD;
CL3CD2 = (CL.^2./CD.^3);
PUse = ((2/27)*density*Aref*CL3CD2*vf^3);
PAct = tsc.winchPower;
E = (tsc.winchPower.Data)./PUse;
for ii = 1:numel(ETargets)
    ATargets{ii} = PTarget./(ETargets(ii)*(2/27)*density*CL3CD2*vfTarget^3);
end

CL = timesignal(timeseries(CL,tsc.vAppLclBdy.Time));
CD = timesignal(timeseries(CD,tsc.vAppLclBdy.Time));
CLCD = timesignal(timeseries(CLCD,tsc.vAppLclBdy.Time));
CL3CD2 = timesignal(timeseries(CL3CD2,tsc.vAppLclBdy.Time));
PUse = timesignal(timeseries(PUse,tsc.vAppLclBdy.Time));
E = timesignal(timeseries(E,tsc.vAppLclBdy.Time));
for ii = 1:numel(ETargets)
    ATargets{ii} = timesignal(timeseries(ATargets{ii},tsc.vAppLclBdy.Time));
end

subplot(4,2,1)
CL.plot
xlabel('Time, [s]')
ylabel('$C_L$')

subplot(4,2,3)
CD.plot
xlabel('Time, [s]')
ylabel('$C_D$')

subplot(4,2,5)
CLCD.plot
xlabel('Time, [s]')
ylabel('$C_L/C_D$')

subplot(4,2,7)
CL3CD2.plot
xlabel('Time, [s]')
ylabel('$C_L^3/C_D^2$')

subplot(4,2,2)
plot(PAct/1000)
xlabel('Time, [s]')
ylabel('kW')
title('Actual Power Output')

subplot(4,2,4)
plot(PUse/1000)
xlabel('Time, [s]')
ylabel('kW')
title('Loyd, Useful Power, $P = \frac{2}{27} \rho A_{ref} \frac{C_L^3}{C_D^2} v_f^3$')
subplot(4,2,2)
plot(PAct/1000)
xlabel('Time, [s]')
ylabel('kW')
title('Actual Power Output')

subplot(4,2,6)
E.plot
xlabel('Time, [s]')
title('Efficiency, Actual Power Produced Over Loyd Useful Power') 

subplot(4,2,8,'NextPlot','add')
for ii = 1:numel(ETargets)
    plot(ATargets{ii},'DisplayName',...
        sprintf('$A_{ref}^{E = %s}$',num2str(ETargets(ii))));
end
xlabel('Time, [s]')
ylabel('$m^2$')
legend
ylim([0 75])

annotation('textbox', [0 0.9 1 0.1], ...
    'String', sprintf('$v_{flow}^{Target}$ = %s m/s,  $P_{Target}$ = %s W,  $E^{Target}$ = %s',num2str(vfTarget),num2str(PTarget),num2str(ETarget)), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center',...
    'FontSize',18)

set(findall(gcf,'Type','Axes'),'FontSize',16)
linkaxes(findall(gcf,'Type','Axes'),'x')

