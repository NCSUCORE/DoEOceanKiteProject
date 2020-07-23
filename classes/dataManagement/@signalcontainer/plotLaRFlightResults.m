function h = plotLaRFlightResults(tsc,vhcl,varargin)
figure()
%%  Plot Elevation Angle
subplot(3,2,1)
hold on;    grid on
if numel(tsc.elevationSP.Data) == 1
    plot(tsc.elevationAngle.Time,tsc.elevationSP.Data*ones(numel(tsc.elevationAngle.Time),1),'r-');
else
    plot(tsc.elevationSP.Time,squeeze(tsc.elevationSP.Data),'r-');
end
plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data),'b-');
ylabel('Elevation [deg]');
legend('$\Theta_\mathrm{des}$','$\Theta_\mathrm{act}$')
%%  Plot Tether Tension 
subplot(3,2,2)
hold on;    grid on
plot(tsc.airTenVecs.Time,squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1))),'r-');
plot(tsc.gndNodeTenVecs.Time,squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1))),'b--');
ylabel('Thr Tension [N]');
legend('Kite','Gnd')
%%  Plot Euler Angles 
subplot(3,2,3)
hold on;    grid on
% plot(tsc.rollSP.Time,squeeze(tsc.rollSP.Data),'r-');
% plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,1,:))*180/pi,'r--');
plot(tsc.pitchSP.Time,squeeze(tsc.pitchSP.Data),'b-');
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(2,1,:))*180/pi,'b--');
% plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(3,1,:))*180/pi,'g--');
legend('Pitch SP','Pitch','Yaw')
% legend('Roll SP','Roll','Pitch SP','Pitch','Yaw')
xlabel('Time [s]'); ylabel('Angle [deg]');
% text(100,5,sprintf('H-Stab Incidence = %.1f deg',vhcl.hStab.incidence.Value))
%%  Plot body forces and moments
subplot(3,2,4)
hold on;    grid on
yyaxis left
plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(1,1,:)),'r-');
% plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(2,1,:)),'b-');
plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(3,1,:)),'g-');
ylabel('Net Force [N]'); set(gca,'YColor',[.15 .15 .15])
yyaxis right
% plot(tsc.MNetBdy.Time,squeeze(tsc.MNetBdy.Data(1,1,:)),'r-');
plot(tsc.MNetBdy.Time,squeeze(tsc.MNetBdy.Data(2,1,:)),'b-');
% plot(tsc.MNetBdy.Time,squeeze(tsc.MNetBdy.Data(3,1,:)),'g-');
ylabel('Net Torque [Nm]'); set(gca,'YColor',[.15 .15 .15])
legend('$\mathrm{F_b^x}$','$\mathrm{F_b^z}$','$\mathrm{M_b^y}$')
%%  Plot control surface deflections
subplot(3,2,5)
hold on;    grid on
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(1,1,:)),'r-');
plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(3,1,:)),'b-');
% plot(tsc.ctrlSurfDeflCmd.Time,squeeze(tsc.ctrlSurfDeflCmd.Data(4,1,:)),'g-');
legend('P-Aileron','Elevator','Rudder')
xlabel('Time [s]'); ylabel('Angle [deg]');
%%  Plot Lift-Drag ratio 
subplot(3,2,6)
hold on;    grid on
plot(tsc.FDragBdy.Time,squeeze(sqrt(sum(tsc.FLiftBdy.Data.^2,1)))./squeeze(sqrt(sum(tsc.FDragBdy.Data.^2,1))),'b-')
xlabel('Time [s]'); ylabel('L/D');
%%  Plot Lift-Drag ratio 
% subplot(3,2,6)
% hold on;    grid on
% plot(tsc.angularVel.Time,squeeze(tsc.angularVel.Data(2,1,:))*180/pi,'b-')
% xlabel('Time [s]'); ylabel('Pitch Rate [deg/s]');

h = gcf;
end

