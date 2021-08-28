function plotResults(tsc,varargin)

pp = inputParser;
addParameter(pp,'Time',tsc.positionVec.Time,@isnumeric);
parse(pp,varargin{:});

tVec = pp.Results.Time;

tiledlayout('flow');
nexttile; plotVec(tVec,tsc.positionVec.Data,'Position [m]');

nexttile; plotVec(tVec,tsc.velocityVec.Data,'Velocity [m/s]');

nexttile; plotVec(tVec,tsc.eulerAngles.Data*180/pi,'Euler [deg]');

nexttile; plotVec(tVec,tsc.angularVel.Data,'Angular velocity [rad/s]');

nexttile; plotVec(tVec,[tsc.ctrlSurfDeflCmd.Data(:,1)...
    tsc.ctrlSurfDeflCmd.Data(:,3:4)],'CS deflection [deg]');

nexttile; plot(tVec,tsc.vhclAngleOfAttack.Data(:),'k-');hold on;grid on;ylabel('Kite AoA [deg]');
aM = mean(tsc.vhclAngleOfAttack.Data(:));yline(aM,'r-'); text(tVec(end)/2,aM+1,num2str(aM));

nexttile; plot(tVec,tsc.turnAngle.Data*180/pi,'k-');hold on;grid on;ylabel('Slip angle [deg]');

nexttile; plot(tVec,tsc.desiredTanRoll.Data*180/pi,'r--','linewidth',1.0);hold on;grid on; 
plot(tVec,tsc.tanRoll.Data*180/pi,'k-'); ylabel('Tangent roll [deg]');

nexttile; plot(tVec,vecnorm(squeeze(tsc.velocityVec.Data)),'k-');hold on;grid on;ylabel('Speed [m/s]');

nexttile; plot(tVec,tsc.tetherLengths.Data(:),'k-');hold on;grid on;ylabel('$L_{thr}$ [m]');

nexttile; plot(tVec,vecnorm(squeeze(tsc.gndNodeTenVecs.Data))./1e3,'k-');hold on;grid on;ylabel('Tension [kN]');

nexttile; plot(tVec,tsc.winchPower.Data./1e3,'k-');hold on;grid on;ylabel('Winch power [kW]');

nexttile; plot(tVec,tsc.turbPow.Data(:)./1e3,'k-');hold on;grid on;ylabel('Turbine power [kW]');

nexttile; plot(tVec,tsc.turbEnrg.Data(:)./1e3,'k-');hold on;grid on;ylabel('Turbine energy [kJ]');

nexttile; plot(tVec,vecnorm(squeeze(tsc.vWindFuseGnd.Data)),'k-');hold on;grid on;ylabel('$v_{flow}$ [m/s]');

nexttile; plot(tVec,tsc.sphericalCoords.Data(:,2)*180/pi,'k-');hold on;grid on;ylabel('Path elevation [deg]');

allAxes = findall(gcf,'type','axes');
linkaxes(allAxes,'x');
xlabel(allAxes,'Time [s]');

end