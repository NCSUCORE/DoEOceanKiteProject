% clear all
% close all
% clc
thrCD = 0:.1:1;
AoA = 5:1:20;
%Initialize Vehicle
loadComponent('ultDoeKiteTSR');

vhcl.turb1.diameter.setValue(0.4,'m')
vhcl.turb2.diameter.setValue(0.4,'m')
vhcl.turb3.diameter.setValue(0.4,'m')
vhcl.turb4.diameter.setValue(0.4,'m')
loadComponent('pathFollowingTether');
% vhcl.gearBoxLoss.setValue(0,'');
thr.tether1.setDensity(1000,'kg/m^3');
thr.tether1.setDiameter(0.022,'m');
gamma0 = vhcl.turb1.optTSR.Value*ones(2,1);

eta = 0;%:0.025:.1;
rho = 1000;
velW = 1;
lb = vhcl.turb1.optTSR.Value*ones(2,1);
ub = [8.5;8.5];
opts = optimoptions('fmincon','Display','none');
opts1 = optimoptions('fminunc','Display','none');
vhcl.turb1.torqueLim.setValue(42,'(N*m)')

for j = 1:numel(eta)
    fprintf(sprintf('%d Percent Complete\n',round((j-1)/numel(eta)*100)))
    for k = 1:numel(velW)
        for ii = 1:numel(thrCD)
            for i = 1:numel(AoA)
                if i == 1
                    u0 = gamma0;
                else
                    u0 = TSR;
                end
            J = @(u)perfIndNoGB(AoA(i),eta(j),velW(k),vhcl,thr,thrCD(ii),u);
            g = @(u)constFun(AoA(i),eta(j),velW(k),vhcl,thr,thrCD(ii),u);
            [TSR,pow(j,k,ii,i),exitCond(j,k,ii)] = fmincon(J,u0,[],[],[],[],lb,ub,g,opts);
            [TSRbnd,powbnd(j,k,ii,i)] = fminbnd(J,vhcl.turb1.optTSR.Value,8.5);
            powNiave(j,k,ii,i) = J(gamma0);
            gamStbd(j,k,ii,i) = TSR(1);
            gamPort(j,k,ii,i) = TSR(2);
            gamBnd(j,k,ii,i) = TSRbnd;
%             gamUnc(j,k,ii,i) = TSRunc(1);
            end
        end
    end
end


fprintf('Finished!')
% squeeze(-pow)
% squeeze(-powbnd)
% squeeze(gamStbd)
gammaDes = squeeze(gamBnd)
% squeeze(alpha)
% squeeze(alphaUnc)

%%
figure('Position',[100 100 800 500])
tl = tiledlayout(1,2);
nexttile
contourf(AoA,thrCD,(squeeze(-powbnd./-powNiave)-1)*100)
ylabel '$C_{D_{thr}}$'
xlabel 'Angle of Attack [deg]'
h = colorbar;
h.Label.String =  'Percent Improvement in $C_{P_{Sys}}$';
h.Label.Interpreter = 'latex';
% h.Location = 'southoutside';
set(gca,'FontSize',14)
nexttile
contourf(AoA,thrCD,squeeze(gamBnd))
ylabel '$C_{D_{thr}}$'
xlabel 'Angle of Attack [deg]'
h = colorbar;
% h.Location = 'southoutside';
h.Label.String =  '$\gamma$';
h.Label.Interpreter = 'latex';
set(gca,'FontSize',14)

tl.Padding = 'compact';
tl.TileSpacing = 'compact';
save tsrMod.mat gammaDes thrCD AoA
%%
