clear all
close all
clc
thrL = [0 20 40 60 80 100];

%Initialize Vehicle
loadComponent('Manta71522');
loadComponent('pathFollowingTether');
% vhcl.gearBoxLoss.setValue(0,'');
thr.tether1.setDensity(1000,'kg/m^3');
thr.tether1.setDiameter(0.018,'m');
gamma0 = [vhcl.turb1.optTSR.Value*ones(2,1); 10];

eta = 0:0.025:0.2;
rho = 1000;
velW = 0.2:0.05:0.5;
lb = [vhcl.turb1.optTSR.Value*ones(2,1); 4];
ub = [7;7;16];
opts = optimoptions('fmincon','Display','none');
opts1 = optimoptions('fminunc','Display','none');
vhcl.turb1.torqueLim.setValue(42,'(N*m)')

for j = 1:numel(eta)
    for k = 1:numel(velW)
        fprintf(sprintf('%d Percent Complete\n',round((k-1)/numel(velW)*100)))
        for ii = 1:numel(thrL)
            J = @(u)perfInd(eta(j),velW(k),vhcl,thr,thrL(ii),u);
            g = @(u)constFun(eta(j),velW(k),vhcl,thr,thrL(ii),u);
            [TSR,pow(j,k,ii),exitCond(j,k,ii)] = fmincon(J,gamma0,[],[],[],[],lb,ub,g,opts);
            [TSRunc,powUnc(j,k,ii)] = fminunc(J,gamma0,opts1);
            powNiave(j,k,ii) = J(gamma0);
            gamStbd(j,k,ii) = TSR(1);
            gamPort(j,k,ii) = TSR(2);
            alpha(j,k,ii) = TSR(3);
            gamUnc(j,k,ii) = TSRunc(1);
            alphaUnc(j,k,ii) = TSRunc(3);
        end
    end
end


fprintf('Finished!')
squeeze(-pow)
squeeze(-powUnc)
squeeze(gamStbd)
squeeze(gamUnc)
squeeze(alpha)
squeeze(alphaUnc)
%%

[x,y] = meshgrid(velW,thrL(thrL>=0))

% ind1 = find(alpha>=4)
ind2 = find(eta==0)
ind3 = find(velW>0)
ind4 = find(thrL>=0)


figure('Position',[100 100 1200 500])
tL1 = tiledlayout(1,3);
ax(1)=nexttile;
contour(y,x,squeeze(alpha(ind2,ind3,ind4,1))','Fill','on','LineColor','k')
h1 = colorbar
h1.Label.Interpreter = 'latex';
h1.Label.FontSize = 12
xlabel 'Tether Length [m]'
ylabel 'Flow Velocity [m/s]'
h1.Label.String = 'AoA [deg]';
set(gca,"FontSize",14)
ax(2)=nexttile;
contour(y,x,squeeze(gamStbd(ind2,ind3,ind4,1))','Fill','on','LineColor','k')
h = colorbar;
xlabel 'Tether Length [m]'
% ylabel 'Flow Velocity [m/s]'
h.Label.String = 'Tip Speed Ratio';
h.Label.Interpreter = 'latex';
h.Label.FontSize = 12
title ''
% set(ax, 'CLim', [0.9 1.1])
tL1.Padding = 'compact';
tL1.TileSpacing = 'compact';
set(gca,"FontSize",14)

ax(3)=nexttile;
contour(y,x,-squeeze(pow(ind2,ind3,ind4,1))','Fill','on','LineColor','k')
h = colorbar;
xlabel 'Tether Length [m]'
% ylabel 'Flow Velocity [m/s]'
h.Label.String = 'Power [W]';
h.Label.Interpreter = 'latex';
h.Label.FontSize = 12
title ''
% set(ax, 'CLim', [0.9 1.1])
tL1.Padding = 'compact';
tL1.TileSpacing = 'compact';
set(gca,'FontSize',14)
% title(tL1,'Effective Tether Length = 500m','Interpreter','Latex','FontSize',20)
%%

figure('Position',[100 100 600 600])
contour(y,x,squeeze(powUnc(ind1,ind2,ind3,ind4,1))'./squeeze(powNiave(ind1,ind2,ind3,ind4,1))','Fill','on','LineColor','k')
h1 = colorbar;
h1.Label.String = 'Tip Speed Ratio';
h1.Label.Interpreter = 'latex';
title 'Constrained $\tau_{max} = 65$ Nm'
xlabel 'Wind Velocity [m/s]'
ylabel 'Angle of Attack [deg]'
%%

figure('Position',[100 100 1200 500])
tL1 = tiledlayout(1,2);
ax(1)=nexttile;
contour(y,x,squeeze(gamStbd(ind1,ind2,ind3,ind4,1))','Fill','on','LineColor','k')
h1 = colorbar;
h1.Label.String = 'Tip Speed Ratio';
h1.Label.Interpreter = 'latex';
title 'Constrained $\tau_{max} = 65$ Nm'
xlabel 'Effective Tether Length [m]'
ylabel 'Angle of Attack [deg]'
set(gca,'FontSize',12)
ax(2)=nexttile;
set(gca,'CLim', [2.5 7.5])
contour(y,x,squeeze(gamUnc(ind1,ind2,ind3,ind4,1))','Fill','on','LineColor','k')

% contour(y,x,(squeeze(powUnc(ind1,ind2,ind3,ind4,1)./powNiave(ind1,ind2,ind3,ind4,1))'-1)*100,'Fill','on','LineColor','k')
h = colorbar;
set(gca, 'CLim', [2.5 7.5])
xlabel 'Effective Tether Length [m]'
% ylabel 'Angle of Attack [deg]'
h.Label.String = 'Tip Speed Ratio';
h.Label.Interpreter = 'latex';
h.Ticks = [2.5:.5:7.5];
h.LimitsMode = 'manual'
h.Limits = [2.5 7.5]
title 'Unconstrained'
tL1.Padding = 'compact';
tL1.TileSpacing = 'compact';
set(gca,'FontSize',12)