function plotLiftDrag(obj,vhcl,env,varargin)
p = inputParser;
addOptional(p,'plot1Lap',false,@islogical);
addOptional(p,'plotS',false,@islogical);
addOptional(p,'Vapp',false,@islogical);
addOptional(p,'plotBeta',false,@islogical);
addOptional(p,'LiftDrag',false,@islogical);
addOptional(p,'Color',[0 0 1],@isnumeric);
parse(p,varargin{:})
color = p.Results.Color;
data = squeeze(obj.currentPathVar.Data);
time = obj.lapNumS.Time;
lap = p.Results.plot1Lap;
con = p.Results.plotS;
%  Determine Single Lap Indices
if lap
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
FLiftBdyX = sqrt(squeeze(obj.FLiftBdy.Data(1,1,:).^2));
FLiftBdyY = sqrt(squeeze(obj.FLiftBdy.Data(2,1,:).^2));
FLiftBdyZ = sqrt(squeeze(obj.FLiftBdy.Data(3,1,:).^2));
FDragBdyX = sqrt(squeeze(obj.FDragBdy.Data(1,1,:).^2));
FDragBdyY = sqrt(squeeze(obj.FDragBdy.Data(2,1,:).^2));
FDragBdyZ = sqrt(squeeze(obj.FDragBdy.Data(3,1,:).^2));
hold on; grid on
if lap
    if con
        plot(data(ran),FLiftBdyX(ran)./FDragBdyX(ran),'b-');
        plot(data(ran),FLiftBdyY(ran)./FDragBdyY(ran),'r:');
        plot(data(ran),FLiftBdyZ(ran)./FDragBdyZ(ran),'g-');  ylim([0 50]);  ylabel('L/D');  legend('X','Y','Z')
    else
        plot(time(ran),FLiftBdyX(ran)./FDragBdyX(ran),'b-');
        plot(time(ran),FLiftBdyY(ran)./FDragBdyY(ran),'r:');
        plot(time(ran),FLiftBdyZ(ran)./FDragBdyZ(ran),'g-');  ylim([0 50]);  ylabel('L/D');  legend('X','Y','Z')
    end
else
    plot(time,FLiftBdyX./FDragBdyX,'b-');
    plot(time,FLiftBdyY./FDragBdyY,'r:');
    plot(time,FLiftBdyZ./FDragBdyZ,'g-');  ylim([0 50]);  ylabel('L/D');  legend('X','Y','Z')
end
end