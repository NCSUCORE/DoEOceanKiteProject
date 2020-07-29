function plotPower(obj,vhcl,env,varargin)
p = inputParser;
addOptional(p,'plot1Lap',false,@islogical);
addOptional(p,'plotS',false,@islogical);
addOptional(p,'plotLoyd',false,@islogical);
addOptional(p,'Color',[0 0 1],@isnumeric);
addOptional(p,'Lap1',1,@isnumeric);
parse(p,varargin{:})
color = p.Results.Color;
data = squeeze(obj.currentPathVar.Data);
time = obj.lapNumS.Time;
lap = p.Results.plot1Lap;
con = p.Results.plotS;
L1 = p.Results.Lap1;
%  Determine Single Lap Indices
if lap
    lapNum = squeeze(obj.lapNumS.Data);
    Idx1 = find(lapNum > L1,1,'first');
    Idx2 = find(lapNum > L1+1,1,'first');
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
    power = squeeze(obj.turbPow.Data(1,1,:));
else
    power = squeeze((obj.turbPow.Data(1,1,:)))+squeeze((obj.turbPow.Data(1,2,:)));
end
[CLsurf,CDtot] = getCLCD(obj,vhcl);
PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2;
hold on; grid on
if lap
    if con
        plot(data(ran),power(ran)*1e-3,'-','color',color);  xlabel('Path Position');  ylabel('Power [kW]');
        if p.Results.plotLoyd
            plot(data(ran),PLoyd(ran)*1e-3,'--','color',color);  ylabel('Power [kW]');  legend('Kite','Loyd');
        end
    else
        plot(time(ran),power(ran),'-','color',color);  ylabel('Power [W]');  xlim(lim);
        if p.Results.plotLoyd
            plot(time(ran),PLoyd(ran),'--','color',color);  ylabel('Power [W]');  xlim(lim);  legend('Kite','Loyd');
        end
    end
else
    plot(time,power,'-','color',color);  ylabel('Power [W]');  xlim(lim);
    if p.Results.plotLoyd
        plot(time,PLoyd,'--','color',color);  ylabel('Power [W]');  xlim(lim);  legend('Kite','Loyd');
    end
end
end