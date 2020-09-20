%%
flwSpd1 = .25:.025:.5;                                               %   m/s - Flow speed
fpath1 = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','400 m Tether AVL\');
for ii = 1:numel(flwSpd1)
    filename1 = sprintf(strcat('Turb1.1_V-%.3f.mat'),flwSpd1(ii));
    load([fpath1 filename1])
    lap = max(tsc.lapNumS.Data)-1;
    [Idx1,Idx2] = tsc.getLapIdxs(lap);
    ran = Idx1:Idx2-1;
    Pow = tsc.rotPowerSummary(vhcl,env);
    avgPowa(ii) = Pow.avg;
end
%%
p = polyfit(flwSpd1,avgPow,3);
P = @(x) p(1)*x.^3+p(2).*x.^2+p(3).*x+p(4);
pa = polyfit(flwSpd1,avgPowa,3);
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