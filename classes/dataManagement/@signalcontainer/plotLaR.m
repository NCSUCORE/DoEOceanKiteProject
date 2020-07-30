function plotLaR(obj)
subplot(3,1,1); hold on; grid on;
if numel(obj.elevationSP.Data) == 1
    plot(obj.elevationAngle.Time,obj.elevationSP.Data*ones(length(obj.elevationAngle.Time),1),'r-');
else
    plot(obj.elevationSP.Time,squeeze(obj.elevationSP.Data),'r-');
end
plot(obj.elevationAngle.Time,squeeze(obj.elevationAngle.Data),'b-');  xlabel('Time [s]');  ylabel('Elevation [deg]');
subplot(3,1,2); hold on; grid on;
plot(obj.pitchSP.Time,squeeze(obj.pitchSP.Data),'r-');
plot(obj.pitch.Time,squeeze(obj.pitch.Data),'b-');  xlabel('Time [s]');  ylabel('Pitch [deg]');
end