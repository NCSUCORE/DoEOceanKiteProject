function plotFlightError(obj,vhcl,env,varargin)
%%  Parse Inputs
p = inputParser;
addOptional(p,'plot1Lap',false,@islogical);
addOptional(p,'lapNum',1,@isnumeric);
addOptional(p,'plotS',false,@islogical);
addOptional(p,'Vapp',false,@islogical);
addOptional(p,'plotBeta',false,@islogical);
addOptional(p,'LiftDrag',false,@islogical);
addOptional(p,'dragChar',false,@islogical);
parse(p,varargin{:})

R = 2;  C = 2;
data = squeeze(obj.currentPathVar.Data);
time = obj.lapNumS.Time;
lap = p.Results.plot1Lap;
con = p.Results.plotS;
turb = isprop(obj,'turbPow');
%%  Determine Single Lap Indices
if lap
    [Idx1,Idx2] = getLapIdxs(obj,p.Results.lapNum);
    ran = Idx1:Idx2-1;
    lim = [time(Idx1) time(Idx2)];
else
    lim = [time(1) time(end)];
end
%%  Compute Plotting Variables
tanRollErr = squeeze(obj.tanRollError.Data);
cenAngleErr = squeeze(obj.centralAngle.Data);
betaErr = squeeze(obj.betaErr.Data);
velAngErr = squeeze(obj.velAngleError.Data);

figure();
%%  Plot Power Output
subplot(R,C,1);
hold on; grid on
if lap
        plot(data(ran),tanRollErr(ran)*180/pi,'b-');  ylabel('Tangent Roll Error [deg]');  
end  
%%  Plot Power Output
subplot(R,C,2);
hold on; grid on
if lap
        plot(data(ran),cenAngleErr(ran)*180/pi,'b-');  ylabel('Central Angle Error [deg]');
end  

%%  Plot Power Output
subplot(R,C,3);
hold on; grid on
if lap
        plot(data(ran),betaErr(ran)*180/pi,'b-');  ylabel('Side Slip Error [deg]');  
end  
xlabel('Path Position')
%%  Plot Power Output
subplot(R,C,4);
hold on; grid on
if lap
        plot(data(ran),velAngErr(ran)*180/pi,'b-');  ylabel('Velocity Angle Error [deg]');  
end  
xlabel('Path Position')
%%  Plot Tether Tension



end