[idx1,idx2] = tsc.getLapIdxs(8);
ran = idx1:idx2;

% acc = sqrt(sum(tsc.caccel.Data(3,1,ran).^2,1));
Tg = (tsc.gndNodeTenVecs+tsc.airTenVecs);
Tnet = Tg.mag.Data(:,:,ran);
va = tsc.vhclVapp.mag.Data(:,:,ran);
l = (Tnet)./(1/2*1000*va.^2*1.2*0.018)


drag = squeeze(tsc.nodeDrag.mag.Data(1,2:end,ran))
drag2 = sqrt(sum(sum(tsc.nodeDrag.Data(:,:,ran),2).^2,1))
vApp = squeeze(tsc.vhclVapp.mag.Data(1,1,ran))';
ratio = drag./vApp.^2;
thrLen2 = sum(2/(1000*1.2*0.018)*ratio);
s2 = tsc.closestPathVariable.Data(ran);
air = squeeze(tsc.airTenVecs.mag.Data(1,1,ran));
gnd = squeeze(tsc.gndNodeTenVecs.mag.Data(1,1,ran));
tVec = tsc.gndNodeTenVecs.Time(ran);
thrLen = sum(2/(1000*1.2*0.018)*ratio);
rotorEff = tsc.rotorEff.Data(:,1,ran);
aoa = tsc.vhclAngleOfAttack.Data(ran);
rms(thrLen)
rms(l)
mean(l)
figure;
plotsq(s2,l)
hold on
plotsq(s2,thrLen)
yyaxis right
plotsq(s2,aoa)
xlabel 'Time [s]'
ylabel '$l_{eff}$'
legend('$T_{net}/D$','Paper Integral')

figure;
plotsq(tVec,l)
hold on
plotsq(tVec,thrLen)
yyaxis right
plotsq(tVec,vApp)
xlabel 'Time [s]'
ylabel '$l_{eff}$'
legend('$T_{net}/D$','Paper Integral')