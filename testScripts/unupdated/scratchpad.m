close all
tsc = tscILC.crop(4000,6000);

AR = 10;
maxCL3CD2 = 70*2;
actCL3CD2 = 60*2;

vfTarget    = 0.25;
PTarget     = 500;
ETargets    = [0.1 0.25 0.5 0.75 1];
PTargets    = [500 750 1000];

FLift       = squeeze(sqrt(sum(tsc.FLiftBdy.Data.^2,1)));
FDrag       = squeeze(sqrt(sum(tsc.FDragBdy.Data.^2,1)));
vApp2       = (squeeze(sqrt(sum(tsc.vAppLclBdy.Data(:,1,:).^2))).^2);
density     = env.water.density.Value;
dynPress    = (0.5*density*vhcl.fluidRefArea.Value*vApp2);
vf          = sqrt(sum(env.water.flowVec.Value.^2));
Aref        = vhcl.fluidRefArea.Value;

CL      = FLift(:)./dynPress(:);
CD      = FDrag(:)./dynPress(:);
CLCD    = CL./CD;
CL3CD2  = (CL.^3./CD.^2);
PUse    = ((2/27)*density*Aref*CL3CD2*vf^3);
PUse(sign(tsc.thrReleaseSpeeds.Data(:))<0) = 0; % Zero useful power when spooling in
PAct    = tsc.winchPower;
E       = (tsc.winchPower.Data)./PUse;

for ii = 1:numel(ETargets)
    ATargets{ii} = PTarget./(ETargets(ii)*(2/27)*density*CL3CD2*vfTarget^3);
end

vApp2   = timesignal(timeseries(vApp2,tsc.vAppLclBdy.Time));
CL      = timesignal(timeseries(CL,tsc.vAppLclBdy.Time));
CD      = timesignal(timeseries(CD,tsc.vAppLclBdy.Time));
CLCD    = timesignal(timeseries(CLCD,tsc.vAppLclBdy.Time));
CL3CD2  = timesignal(timeseries(CL3CD2,tsc.vAppLclBdy.Time));
PUse    = timesignal(timeseries(PUse,tsc.vAppLclBdy.Time));
E       = timesignal(timeseries(E,tsc.vAppLclBdy.Time));
for ii = 1:numel(ETargets)
    ATargets{ii} = timesignal(timeseries(ATargets{ii},tsc.vAppLclBdy.Time));
end

PUseAvg = PUse.mean;
PActAvg = PAct.mean;
EAct    = PActAvg/PUseAvg;

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
ylim([0 20])

annotation('textbox', [0 0.9 1 0.1], ...
    'String', sprintf('$v_{flow}^{Target}$ = %s m/s,  $P_{Target}$ = %s W',num2str(vfTarget),num2str(PTarget)), ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center',...
    'FontSize',18)

set(findall(gcf,'Type','Axes'),'FontSize',16)
linkaxes(findall(gcf,'Type','Axes'),'x')

% savePlot(gcf,pwd,'PowerProjection')
%%
vFlows = linspace(0.2,0.5);
% figure('Position',[-1.0026    0.2435    1.0000    0.4250])
figure

Aax1 = subplot(2,3,1,'NextPlot','add','XGRid','on','YGrid','on');
xlabel('Flow Speed, $v_{flow}$, [m/s]')
ylabel('Required Area, [m$^2$]')
title('Theoretical Minimum')
legend

Aax2 = subplot(2,3,2,'NextPlot','add','XGRid','on','YGrid','on');
xlabel('Flow Speed, $v_{flow}$, [m/s]')
ylabel('Required Area, [m$^2$]')
title('Current $\frac{C_L^3}{C_D^2}$ Controller')
legend

Aax3 = subplot(2,3,3,'NextPlot','add','XGRid','on','YGrid','on');
xlabel('Flow Speed, $v_{flow}$, [m/s]')
ylabel('Required Area, [m$^2$]')
% title('Current $\frac{C_L^3}{C_D^2}$ and Spooling Controllers')
legend

Sax1 = subplot(2,3,4,'NextPlot','add','XGRid','on','YGrid','on');
xlabel('Flow Speed, $v_{flow}$, [m/s]')
ylabel('Required Span, [m]')
% title('Theoretical Minimum')
legend

Sax2 = subplot(2,3,5,'NextPlot','add','XGRid','on','YGrid','on');
xlabel('Flow Speed, $v_{flow}$, [m/s]')
ylabel('Required Span, [m]')
% title('Current $\frac{C_L^3}{C_D^2}$ Controller')
legend

Sax3 = subplot(2,3,6,'NextPlot','add','XGRid','on','YGrid','on');
xlabel('Flow Speed, $v_{flow}$, [m/s]')
ylabel('Required Span, [m]')
% title('Current $\frac{C_L^3}{C_D^2}$ and Spooling Controllers')
legend

set(findall(gcf,'Type','axes'),'XLim',[vFlows(1) vFlows(end)])

for ii = 1:numel(PTargets)
    % Theoretical Minimum (No spool-in, max CL3/CD2)
    ARefReqMin = PTargets(ii)./((2/27)*density*maxCL3CD2*vFlows.^3);
    SReqMin = sqrt(ARefReqMin*AR);
    plot(vFlows,ARefReqMin,...
        'Parent',Aax1,...
        'DisplayName',sprintf('$P=%s$ W',num2str(PTargets(ii))),'LineWidth',2)
    plot(vFlows,SReqMin,...
        'Parent',Sax1,...
        'DisplayName',sprintf('$P=%s$ W',num2str(PTargets(ii))),'LineWidth',2)
    
    % No spool-in, actual CL3/CD2
    ARefReqNoSpool = PTargets(ii)./((2/27)*density*actCL3CD2*vFlows.^3);
    SReqNoSpool = sqrt(ARefReqNoSpool*AR);
    plot(vFlows,ARefReqNoSpool,...
        'Parent',Aax2,...
        'DisplayName',sprintf('$P=%s$ W',num2str(PTargets(ii))),'LineWidth',2)
    plot(vFlows,SReqNoSpool,...
        'Parent',Sax2,...
        'DisplayName',sprintf('$P=%s$ W',num2str(PTargets(ii))),'LineWidth',2)
    
    % Spool-in, actual CL3/CD2
    ARefReqAct = PTargets(ii)./(EAct*(2/27)*density*maxCL3CD2*vFlows.^3);
    SReqAct = sqrt(ARefReqAct*AR);
    plot(vFlows,ARefReqAct,...
        'Parent',Aax3,...
        'DisplayName',sprintf('$P=%s$ W',num2str(PTargets(ii))),'LineWidth',2)
    plot(vFlows,SReqAct,...
        'Parent',Sax3,...
        'DisplayName',sprintf('$P=%s$ W',num2str(PTargets(ii))),'LineWidth',2)
    
end

linkaxes(findall(gcf,'Type','Axes'),'x')
linkaxes([Aax1 Aax2 Aax3],'y')
linkaxes([Sax1 Sax2 Sax3],'y')
set(findall(gcf,'Type','Axes'),'FontSize',16)

% savePlot(gcf,pwd,'Geometry')

