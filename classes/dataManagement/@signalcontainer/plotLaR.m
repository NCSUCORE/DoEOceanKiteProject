function plotLaR(obj)
time = obj.MNetBdy.Time;
airNode = squeeze(sqrt(sum(obj.airTenVecs.Data.^2,1)))*1e-3;
gndNode = squeeze(sqrt(sum(obj.gndNodeTenVecs.Data.^2,1)))*1e-3;
figure();
%%  Plot Elevation Angle 
subplot(5,1,1); hold on; grid on;
if numel(obj.elevationSP.Data) == 1
    plot(obj.elevationAngle.Time,obj.elevationSP.Data*ones(length(obj.elevationAngle.Time),1),'r-');
else
    plot(obj.elevationSP.Time,squeeze(obj.elevationSP.Data),'r-');
end
plot(obj.elevationAngle.Time,squeeze(obj.elevationAngle.Data),'b-');  xlabel('Time [s]');  ylabel('Elevation [deg]');
%%  Plot Pitch Angle 
subplot(5,1,2); hold on; grid on;
plot(obj.pitchSP.Time,squeeze(obj.pitchSP.Data),'r-');
plot(obj.pitch.Time,squeeze(obj.pitch.Data)*180/pi,'b-');  xlabel('Time [s]');  ylabel('Pitch [deg]');  
legend('Setpoint','AutoUpdate','off','location','northwest')
%%  Plot Elevator Command 
subplot(5,1,3); hold on; grid on;
plot(obj.elevCmd.Time,squeeze(obj.elevCmd.Data),'b-');  xlabel('Time [s]');  ylabel('Elevator [deg]');
%%  Plot Tether Tension
subplot(5,1,4); hold on; grid on;
plot(time,airNode,'b-');  plot(time,gndNode,'r--');  
xlabel('Time [s]');  ylabel('Tension [kN]');  legend('Kite','Glider');
%%  Plot Spool Command 
subplot(5,1,5); hold on; grid on;
plot(time,squeeze(obj.wnchCmd.Data),'b-');
xlabel('Time [s]');  ylabel('Winch [m/s]');
end