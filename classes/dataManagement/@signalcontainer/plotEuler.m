function plotEuler(obj,varargin)
p = inputParser;
addOptional(p,'plot1Lap',false,@islogical);
addOptional(p,'plotS',false,@islogical);
addOptional(p,'Vapp',false,@islogical);
addOptional(p,'plotBeta',false,@islogical);
addOptional(p,'LiftDrag',false,@islogical);
addOptional(p,'Color',[0 0 1],@isnumeric);
parse(p,varargin{:})
time = obj.MNetBdy.Time;
lap = p.Results.plot1Lap;
con = p.Results.plotS;
%  Determine Single Lap Indices
if lap
    data = squeeze(obj.currentPathVar.Data);
    lapNum = squeeze(obj.lapNumS.Data);
    Idx1 = find(lapNum > 0,1,'first');
    Idx2 = find(lapNum > 1,1,'first');
    if isempty(Idx1) || isempty(Idx2)
        error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
    end
    ran = Idx1:Idx2-1;
    lim = [time(Idx1) time(Idx2)];
else
    lim = [time(1) time(end)];
end
roll = squeeze(obj.eulerAngles.Data(1,1,:))*180/pi;
pitch = squeeze(obj.eulerAngles.Data(2,1,:))*180/pi;
yaw = squeeze(obj.eulerAngles.Data(3,1,:))*180/pi;
hold on; grid on
if lap
    if con
        plot(data(ran),roll(ran),'b-');  ylabel('Euler [deg]');
        plot(data(ran),pitch(ran),'r-');  ylabel('Euler [deg]');
        plot(data(ran),yaw(ran),'g-');  xlabel('Path Position');  ylabel('Euler [deg]');  legend('roll','pitch','yaw')
    else
        plot(time(ran),roll(ran),'b-');  ylabel('Euler [deg]');
        plot(time(ran),pitch(ran),'r-');  ylabel('Euler [deg]');
        plot(time(ran),yaw(ran),'g-');  xlabel('Time [s]');  ylabel('Euler [deg]');  legend('roll','pitch','yaw');  xlim(lim)
    end
else
    plot(time,roll,'b-');  ylabel('Euler [deg]');
    plot(time,pitch,'r-');  ylabel('Euler [deg]');
    plot(time,yaw,'g-');  xlabel('Time [s]');  ylabel('Euler [deg]');  legend('roll','pitch','yaw');  xlim(lim)
end
end