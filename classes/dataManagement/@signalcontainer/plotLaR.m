function plotLaR(obj)
time = obj.MNetBdy.Time;
airNode = squeeze(sqrt(sum(obj.airTenVecs.Data.^2,1)))*1e-3;
gndNode = squeeze(sqrt(sum(obj.gndNodeTenVecs.Data.^2,1)))*1e-3;
figure();
%%  Plot Elevation Angle 
subplot(3,2,1); hold on; grid on;
if numel(obj.elevationSP.Data) == 1
    plot(obj.elevationAngle.Time,obj.elevationSP.Data*ones(length(obj.elevationAngle.Time),1),'r-');
else
    plot(obj.elevationSP.Time,squeeze(obj.elevationSP.Data),'r-');
end
plot(obj.elevationAngle.Time,squeeze(obj.elevationAngle.Data),'b-');  xlabel('Time [s]');  ylabel('Elevation [deg]');
%%  Tether Length
subplot(3,2,2); hold on; grid on;
plot(obj.tetherLengths.Time,squeeze(obj.tetherLengths.Data),'b-');  xlabel('Time [s]');  ylabel('Length [m]');  
%%  Plot Pitch Angle 
subplot(3,2,3); hold on; grid on;
plot(obj.pitchSP.Time,squeeze(obj.pitchSP.Data),'r-');
plot(obj.pitch.Time,squeeze(obj.pitch.Data)*180/pi,'b-');  xlabel('Time [s]');  ylabel('Pitch [deg]');  
legend('Setpoint','AutoUpdate','off','location','northwest')
%%  Plot Spool Command 
subplot(3,2,4); hold on; grid on;
plot(time,squeeze(obj.wnchCmd.Data),'b-');
xlabel('Time [s]');  ylabel('Winch [m/s]');
%%  Plot Elevator Command 
subplot(3,2,5); hold on; grid on;
plot(obj.ctrlSurfDeflCmd.Time,squeeze(obj.ctrlSurfDeflCmd.Data(3,:,:)),'b-');  xlabel('Time [s]');  ylabel('Elevator [deg]');
%%  Plot Tether Tension
subplot(3,2,6); hold on; grid on;
plot(time,airNode,'b-');  plot(time,gndNode,'r--');  %ylim([0 .5]);
xlabel('Time [s]');  ylabel('Tension [kN]');  legend('Kite','Glider');
end