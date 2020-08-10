function plotEnergy(obj,vhcl,env,varargin)
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
%  Compute Plotting Variables
N = vhcl.numTurbines.Value;
if N == 1
    energy = squeeze(obj.turbEnrg.Data(1,1,:))/1000/3600;
else
    energy = squeeze((obj.turbEnrg.Data(1,1,:)))/1000/3600+squeeze((obj.turbEnrg.Data(1,2,:)))/1000/3600;
end
hold on; grid on
if lap
    if con
        plot(data(ran),energy(ran)-energy(Idx1),'-','color',color);  ylabel('Energy [kWh]');
    else
        plot(time(ran),energy(ran)-energy(Idx1),'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
    end
else
    plot(time,energy,'-','color',color);  ylabel('Energy [kWh]');  xlim(lim)
end
end