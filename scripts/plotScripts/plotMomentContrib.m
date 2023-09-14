tscA=tsc;
tscName='FSK Baseline_';



figure; hold on; grid on;

plotsq(tscA.MNetBdy.Time,tscA.MNetBdy.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MBuoyBdy.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MTurbBdy.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MThrNetBdy.Data(1,:,:));

plotsq(tscA.MNetBdy.Time,tscA.MGravBdy.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MFuseBdy.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MFluidBdy.Data(1,:,:));

legend({'Net','Buoy','Turb','Thr','Grav','Fuse','Fluid'})
xlabel('Time (s)')
ylabel('Roll Moment (N*m)')
title([tscName 'Roll Moment Contributions'])

%%
figure; hold on; grid on;

plotsq(tscA.MNetBdy.Time,tscA.MNetBdy.Data(3,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MBuoyBdy.Data(3,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MTurbBdy.Data(3,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MThrNetBdy.Data(3,:,:));

plotsq(tscA.MNetBdy.Time,tscA.MGravBdy.Data(3,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MFuseBdy.Data(3,:,:));
plotsq(tscA.MNetBdy.Time,tscA.MFluidBdy.Data(3,:,:));

legend({'Net','Buoy','Turb','Thr','Grav','Fuse','Fluid'})
xlabel('Time (s)')
ylabel('Roll Moment (N*m)')
title([tscName 'Yaw Moment Contributions'])

%%
figure; hold on; grid on;


plotsq(tscA.MNetBdy.Time,tscA.MFluidBdy.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.portWingMoment.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.stbdWingMoment.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.vStabMoment.Data(1,:,:));
plotsq(tscA.MNetBdy.Time,tscA.hStabMoment.Data(1,:,:));


legend({'Fluid','Port','Stbd','V-Stab','H-Stab'})
xlabel('Time (s)')
ylabel('Roll Moment (N*m)')
title([tscName 'Fluid Roll Moment Contributions'])

%%
figure;tscA.yaw.diff.plot;ylim([-0.2 0.2])
grid on
title([tscName 'Yaw Rate'])

%%
figure;tscA.eulerAngles.plot;
sgtitle([tscName 'Euler Angles'])

%%
figure;tscA.rollSet.plot('--');hold on;plotsq(tscA.eulerAngles.Time,tscA.eulerAngles.Data(1,:,:));legend({'SP','Roll'})
title([tscName 'Roll Tracking'])

%%

figure;
grid on
tscA.vhclAngleOfAttack.plot;

%%
figure
grid on
tscA.vhclSideSlipAngle.plot;
title([tscName 'Sideslip Angle'])

