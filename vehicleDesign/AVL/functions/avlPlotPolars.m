function h = avlPlotPolars(fileName)
basePath = fileparts(which('avl.exe'));
load(fullfile(basePath,'designLibrary',[fileName '.mat']))



alphas      = CLtotTbl.Breakpoints(1).Value;
betas       = CLtotTbl.Breakpoints(2).Value;
flaps       = CLtotTbl.Breakpoints(3).Value;
ailerons    = CLtotTbl.Breakpoints(4).Value;
elevators   = CLtotTbl.Breakpoints(5).Value;
rudders     = CLtotTbl.Breakpoints(6).Value;


% Plot things vs alpha
figure('Position',[0    0.0370    1.0000    0.8917])
subplot(2,3,1)
plot(alphas,interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CLtotTbl.Table.Value,alphas,0,0,0,0,0),'Marker','o','LineWidth',1.5)
xlabel('$\alpha$, [deg]')
ylabel('Lift Coefficient $C_L$')

subplot(2,3,2)
plot(alphas,interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CDtotTbl.Table.Value,alphas,0,0,0,0,0),'Marker','o','LineWidth',1.5)
xlabel('$\alpha$, [deg]')
ylabel('Drag Coefficient $C_D$')


subplot(2,3,3)
plot(alphas,interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CmtotTbl.Table.Value,alphas,0,0,0,0,0),'Marker','o','LineWidth',1.5)
xlabel('$\alpha$, [deg]')
ylabel({'Pitching Moment','Coefficient $C_m$'})

subplot(2,3,4)
plot(alphas,interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CLtotTbl.Table.Value,alphas,0,0,0,0,0)./interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CDtotTbl.Table.Value,alphas,0,0,0,0,0),'Marker','o','LineWidth',1.5)
xlabel('$C_D$')
ylabel('$C_L$')

subplot(2,3,5)
plot(betas,interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CltotTbl.Table.Value,0,betas,0,0,0,0),'Marker','o','LineWidth',1.5)
xlabel('$\beta$, [deg]')
ylabel({'Roll Moment','Coefficient $C_l$'})

subplot(2,3,6)
plot(betas,interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CntotTbl.Table.Value,0,betas,0,0,0,0),'Marker','o','LineWidth',1.5)
xlabel('$\beta$, [deg]')
ylabel({'Yaw Moment','Coefficient $C_n$'})

set(findall(gcf,'Type','axes'),'FontSize',24)

figure('Position',[0    0.0370    1.0000    0.8917])
subplot(2,3,1)
plot(flaps,squeeze(interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CLtotTbl.Table.Value,0,0,flaps,0,0,0)),'Marker','o','LineWidth',1.5)
xlabel('$\delta_{flap}$, [deg]')
ylabel('Lift Coefficient $C_L$')

subplot(2,3,2)
plot(flaps,squeeze(interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CmtotTbl.Table.Value,0,0,flaps,0,0,0)),'Marker','o','LineWidth',1.5)
xlabel('$\delta_{flap}$, [deg]')
ylabel({'Pitch Moment','Coefficient $C_m$'})

subplot(2,3,3)
plot(ailerons,squeeze(interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CltotTbl.Table.Value,0,0,0,ailerons,0,0)),'Marker','o','LineWidth',1.5)
xlabel('$\delta_{aileron}$, [deg]')
ylabel({'Roll Moment','Coefficient $C_l$'})

subplot(2,3,4)
plot(elevators,squeeze(interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CmtotTbl.Table.Value,0,0,0,0,elevators,0)),'Marker','o','LineWidth',1.5)
xlabel('$\delta_{elvators}$, [deg]')
ylabel({'Pitch Moment','Coefficient $C_m$'})

subplot(2,3,5)
plot(rudders,squeeze(interpn(alphas,betas,flaps,ailerons,elevators,rudders,...
    CntotTbl.Table.Value,0,0,0,0,0,rudders)),'Marker','o','LineWidth',1.5)
xlabel('$\delta_{rudder}$, [deg]')
ylabel({'Yaw Moment','Coefficient $C_n$'})


set(findall(gcf,'Type','axes'),'FontSize',24)
end