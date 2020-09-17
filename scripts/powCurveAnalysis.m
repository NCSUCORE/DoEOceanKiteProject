%%
flwSpd = .25:.025:.5;                                               %   m/s - Flow speed
fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','400 m Tether XFlr\');
for ii = 1:numel(flwSpd)
    filename = sprintf(strcat('Turb1.3_V-%.3f.mat'),flwSpd(ii));
    load([fpath filename])
    lap = max(tsc.lapNumS.Data)-1;
    [Idx1,Idx2] = tsc.getLapIdxs(lap);
    ran = Idx1:Idx2-1;
    Pow = tsc.rotPowerSummary(vhcl,env);
    avgPow(ii) = Pow.avg;
end
%%
p = polyfit(flwSpd,avgPow,3);
P = @(x) p(1)*x.^3+p(2).*x.^2+p(3).*x+p(4);
pa = polyfit(flwSpd,avgPowa,3);
Pa = @(x) pa(1)*x.^3+pa(2).*x.^2+pa(3).*x+pa(4);
vFlow = .1:.01:.5;
powCurve = P(vFlow);
powCurvea = Pa(vFlow);
figure; hold on; grid on ;
plot(vFlow,powCurvea,'b--'); xlabel('$V_\mathrm{flow}$ [m/s]'); ylabel('Avg. Power [kW]')
plot(vFlow,powCurve,'b-'); xlabel('Flow Velocity [m/s]'); ylabel('Avg. Power/Lap [kW]')
plot(.315,P(.315),'r*','markersize',12,'linewidth',2)
plot(.315,Pa(.315),'r*','markersize',12,'linewidth',2)
legend('AVL','XFlr5','location','northwest','autoupdate','off')