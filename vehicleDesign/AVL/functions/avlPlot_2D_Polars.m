function h = avlPlot_2D_Polars(fileName)
basePath = fileparts(which('avl.exe'));
load(fullfile(basePath,'designLibrary',[fileName '.mat']))


alphas      = CLtot_2D_Tbl.Breakpoints(1).Value;
betas       = CLtot_2D_Tbl.Breakpoints(2).Value;

% Plot things vs alpha
figure('Position',[0    0.0370    1.0000    0.8917])
subplot(2,3,1)
plot(alphas,interp2(alphas,betas,...
    CLtot_2D_Tbl.Table.Value,alphas,0),'Marker','o','LineWidth',1.5)
xlabel('$\alpha$, [deg]')
ylabel('Lift Coefficient $C_L$')

subplot(2,3,2)
plot(alphas,interp2(alphas,betas,...
    CDtot_2D_Tbl.Table.Value,alphas,0),'Marker','o','LineWidth',1.5)
xlabel('$\alpha$, [deg]')
ylabel('Drag Coefficient $C_D$')


subplot(2,3,3)
plot(alphas,interp2(alphas,betas,...
    Cmtot_2D_Tbl.Table.Value,alphas,0),'Marker','o','LineWidth',1.5)
xlabel('$\alpha$, [deg]')
ylabel({'Pitching Moment','Coefficient $C_m$'})

subplot(2,3,4)
plot(interp2(alphas,betas,...
    CDtot_2D_Tbl.Table.Value,alphas,0),interp2(alphas,betas,...
    CLtot_2D_Tbl.Table.Value,alphas,0),'Marker','o','LineWidth',1.5)
xlabel('$C_D$')
ylabel('$C_L$')

subplot(2,3,5)
plot(betas,interp2(alphas,betas,...
    Cltot_2D_Tbl.Table.Value,0,betas),'Marker','o','LineWidth',1.5)
xlabel('$\beta$, [deg]')
ylabel({'Roll Moment','Coefficient $C_l$'})

subplot(2,3,6)
plot(betas,interp2(alphas,betas,...
    Cntot_2D_Tbl.Table.Value,0,betas),'Marker','o','LineWidth',1.5)
xlabel('$\beta$, [deg]')
ylabel({'Yaw Moment','Coefficient $C_n$'})

set(findall(gcf,'Type','axes'),'FontSize',24)

end