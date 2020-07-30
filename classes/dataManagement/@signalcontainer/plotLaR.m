function plotLaR(obj)
figure();
%%  Plot Elevation Angle 
subplot(3,1,1); hold on; grid on;
if numel(obj.elevationSP.Data) == 1
    plot(obj.elevationAngle.Time,obj.elevationSP.Data*ones(length(obj.elevationAngle.Time),1),'r-');
else
    plot(obj.elevationSP.Time,squeeze(obj.elevationSP.Data),'r-');
end
plot(obj.elevationAngle.Time,squeeze(obj.elevationAngle.Data),'b-');  xlabel('Time [s]');  ylabel('Elevation [deg]');
%%  Plot Pitch Angle 
subplot(3,1,2); hold on; grid on;
plot(obj.pitchSP.Time,squeeze(obj.pitchSP.Data),'r-');
plot(obj.pitch.Time,squeeze(obj.pitch.Data)*180/pi,'b-');  xlabel('Time [s]');  ylabel('Pitch [deg]');
%%  Plot Elevator Command 
subplot(3,1,3); hold on; grid on;
plot(obj.elevCmd.Time,squeeze(obj.elevCmd.Data),'b-');  xlabel('Time [s]');  ylabel('Elevator [deg]');
end