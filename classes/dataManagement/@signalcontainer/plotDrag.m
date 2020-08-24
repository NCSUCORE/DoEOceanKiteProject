function plotDrag(obj,vhcl,env,varargin)
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
FDragBdyX = squeeze(obj.FDragBdy.Data(1,1,:));
FDragBdyY = squeeze(obj.FDragBdy.Data(2,1,:));
FDragBdyZ = squeeze(obj.FDragBdy.Data(3,1,:));
hold on; grid on
if lap
    if con
        plot(data(ran),FDragBdyX(ran),'b-');
        plot(data(ran),FDragBdyY(ran),'r-');
        plot(data(ran),FDragBdyZ(ran),'g-');  ylabel('Drag [N]');  legend('X','Y','Z')
    else
        plot(time(ran),FDragBdyX(ran),'b-');
        plot(time(ran),FDragBdyY(ran),'r-');
        plot(time(ran),FDragBdyZ(ran),'g-');  ylabel('Drag [N]');  legend('X','Y','Z');  xlim(lim)
    end
else
    plot(time,FDragBdyX,'b-');
    plot(time,FDragBdyY,'r-');
    plot(time,FDragBdyZ,'g-');  ylabel('Drag [N]');  legend('X','Y','Z');  xlim(lim)
end
end