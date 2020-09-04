%%
flwSpd = .25:.025:.5;                                               %   m/s - Flow speed
fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor','EL30\');
for ii = 1:numel(flwSpd)
    filename = sprintf(strcat('NewTurb2_V-%.3f.mat'),flwSpd(ii));
    load([fpath filename])
    [Idx1,Idx2] = tsc.getLapIdxs(1);
    ran = Idx1:Idx2-1;
    avgPow(ii) = mean(tsc.turbPow.Data(1,1,ran))+mean(tsc.turbPow.Data(1,2,ran));
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
% plot(vFlow,powCurvea,'b--'); xlabel('$V_\mathrm{flow}$ [m/s]'); ylabel('Avg. Power [W]')
plot(.4,P(.4),'r*','markersize',15,'linewidth',3)
plot(vFlow,powCurve,'b-'); xlabel('Flow Velocity [m/s]'); ylabel('Avg. Power/Lap [W]')
% plot(.4,Pa(.4),'r*','markersize',15,'linewidth',3)
legend('Avg. Power for flow between 0-0.5 m/s','location','northwest','autoupdate','off')