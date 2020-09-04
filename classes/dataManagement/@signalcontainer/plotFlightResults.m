function plotFlightResults(obj,vhcl,env,varargin)
%%  Parse Inputs
p = inputParser;
addOptional(p,'plot1Lap',false,@islogical);
addOptional(p,'plotS',false,@islogical);
addOptional(p,'Vapp',false,@islogical);
addOptional(p,'plotBeta',false,@islogical);
addOptional(p,'LiftDrag',false,@islogical);
parse(p,varargin{:})

if p.Results.LiftDrag
    R = 3;  C = 3;
else
    R = 3;  C = 2;
end
data = squeeze(obj.currentPathVar.Data);
time = obj.lapNumS.Time;
lap = p.Results.plot1Lap;
con = p.Results.plotS;
%%  Determine Single Lap Indices
if lap
    lapNum = squeeze(obj.lapNumS.Data);
    Idx1 = find(lapNum > 1,1,'first');
    Idx2 = find(lapNum > 2,1,'first');
    if isempty(Idx1) || isempty(Idx2)
        error('Lap 1 was never started or finished. Simulate longer or reassess the meaning to your life')
    end
    ran = Idx1:Idx2-1;
    lim = [time(Idx1) time(Idx2)];
else
    lim = [time(1) time(end)];
end
%%  Compute Plotting Variables
N = vhcl.numTurbines.Value;
if N == 1
    power = squeeze(obj.turbPow.Data(1,1,:));
    energy = squeeze(obj.turbEnrg.Data(1,1,:))/1000/3600;
else
    power = squeeze((obj.turbPow.Data(1,1,:)))+squeeze((obj.turbPow.Data(1,2,:)));
    energy = squeeze((obj.turbEnrg.Data(1,1,:)))/1000/3600+squeeze((obj.turbEnrg.Data(1,2,:)))/1000/3600;
    speed = (squeeze(obj.turbVel.Data(1,1,:))+squeeze(obj.turbVel.Data(1,2,:)))/2;
end
airNode = squeeze(sqrt(sum(obj.airTenVecs.Data.^2,1)))*1e-3;
gndNode = squeeze(sqrt(sum(obj.gndNodeTenVecs.Data.^2,1)))*1e-3;
Aref = vhcl.fluidRefArea.Value;
Afuse = squeeze(obj.Afuse.Data);
CDfuse = squeeze(obj.CDfuse.Data).*Afuse/Aref;
CDsurf = squeeze(sum(obj.CD.Data(1,1:3,:),2));
CDtot = CDfuse+CDsurf;
CLsurf = squeeze(sum(obj.CL.Data(1,1:3,:),2));
FDragBdyP1 = squeeze(sqrt(sum(obj.FDragBdyPart.Data(:,1,:).^2,1)));
FDragBdyP2 = squeeze(sqrt(sum(obj.FDragBdyPart.Data(:,2,:).^2,1)));
FDragBdyP3 = squeeze(sqrt(sum(obj.FDragBdyPart.Data(:,3,:).^2,1)));
FDragBdyP4 = squeeze(sqrt(sum(obj.FDragBdyPart.Data(:,4,:).^2,1)));
FDragBdy = FDragBdyP1 + FDragBdyP2 + FDragBdyP3 + FDragBdyP4;
FDragFuse = squeeze(sqrt(sum(obj.FFuseBdy.Data.^2,1)));
FDragThr = squeeze(sqrt(sum(obj.thrDragVecs.Data.^2,1)));
FTurbBdy = squeeze(sqrt(sum(obj.FTurbBdy.Data.^2,1)));
FLiftBdyP1 = squeeze(sqrt(sum(obj.FLiftBdyPart.Data(:,1,:).^2,1)));
FLiftBdyP2 = squeeze(sqrt(sum(obj.FLiftBdyPart.Data(:,2,:).^2,1)));
FLiftBdyP3 = squeeze(sqrt(sum(obj.FLiftBdyPart.Data(:,3,:).^2,1)));
FLiftBdy   = FLiftBdyP1 + FLiftBdyP2 + FLiftBdyP3;
% totDrag = (FDragBdy + FTurbBdy + FDragFuse + FDragThr);
% LiftDrag = FLiftBdy./(FDragBdy + FTurbBdy + FDragFuse + FDragThr);
totDrag = (FDragBdy + FTurbBdy + FDragFuse );
LiftDrag = FLiftBdy./(FDragBdy + FTurbBdy + FDragFuse );
C1 = cosd(squeeze(obj.elevationAngle.Data));  C2 = cosd(squeeze(obj.azimuthAngle.Data));
vLoyd = LiftDrag.*env.water.speed.Value.*(C1.*C2);
PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2.*(C1.*C2).^3;
figure();
hold on; grid on
plot(FTurbBdy./(totDrag-FTurbBdy),'b-');  ylabel('$\mathrm{D_t/D_k}$');
figure();
%%  Plot Turbine Power Output
subplot(R,C,1); 
hold on; grid on
yyaxis left
if lap
    if con
        plot(data(ran),power(ran)*1e-3,'b-');  ylabel('Power [kW]');  set(gca,'YColor',[0 0 1])
        plot(data(ran),PLoyd(ran)*1e-3,'b--');  ylabel('Power [kW]');  legend('Kite','Loyd','location','southeast','AutoUpdate','off');  ylim([0 inf]);
    else
        plot(time(ran),power(ran),'b-');  ylabel('Power [W]');  set(gca,'YColor',[0 0 1]);  xlim(lim);  ylim([0 inf]);
    end
else
    plot(time,power,'b-');  ylabel('Power [W]');  set(gca,'YColor',[0 0 1]);  xlim(lim);  ylim([0 inf]);
end
yyaxis right
if lap
    if con
        plot(data(ran),energy(ran)-energy(Idx1),'r-');  ylabel('Energy [kWh]');  set(gca,'YColor',[1 0 0])
    else
        plot(time(ran),energy(ran)-energy(Idx1),'r-');  ylabel('Energy [kWh]');  set(gca,'YColor',[1 0 0]);  xlim(lim)
    end
else
    plot(time,energy,'r-');  ylabel('Energy [kWh]');  set(gca,'YColor',[1 0 0]);  xlim(lim)
end
%%  Plot Tether Tension
subplot(R,C,2); hold on; grid on
if lap
    if con
        plot(data(ran),airNode(ran),'b-');  plot(data(ran),gndNode(ran),'r--');  ylabel('Thr Tension [kN]');  legend('Kite','Glider')
    else
        plot(time(ran),airNode(ran),'b-');  plot(time(ran),gndNode(ran),'r--');  ylabel('Thr Tension [kN]');  legend('Kite','Glider');  xlim(lim)
    end
else
    plot(time,airNode,'b-');  plot(time,gndNode,'r--');  ylabel('Thr Tension [kN]');  legend('Kite','Glider');  xlim(lim)
end
%%  Plot Turbine Flow Speed
subplot(R,C,3); hold on; grid on
if lap
    if con
        plot(data(ran),speed(ran),'b-');  ylabel('Speed [m/s]');
        plot(data(ran),vLoyd(ran),'r--');  ylabel('Speed [m/s]');  legend('Kite','Loyd');
    else
        plot(time(ran),squeeze(obj.vAppLclBdy.Data(1,1,ran)),'b-');  ylabel('Speed [m/s]');  xlim(lim)
        plot(time(ran),vLoyd(ran),'r--');  ylabel('Speed [m/s]');  legend('Kite','Loyd');
    end
else
    plot(time,squeeze(obj.vAppLclBdy.Data(1,1,:)),'b-');  ylabel('Speed [m/s]');  xlim(lim)
    plot(time,vLoyd,'r--');  ylabel('Speed [m/s]');  legend('Kite','Loyd');
end
%%  Plot Angle of attack
subplot(R,C,4); hold on; grid on
if lap
    if con
        plot(data(ran),squeeze(obj.alphaLocal.Data(1,1,ran)),'b-');  ylabel('Port AoA [deg]');
        if p.Results.plotBeta
            plot(data(ran),squeeze(obj.betaBdy.Data(1,1,ran))*180/pi,'r--');  ylabel('Angle [deg]');  legend('Port Alpha','Beta')
        end
    else
        plot(time(ran),squeeze(obj.alphaLocal.Data(1,1,ran)),'b-');  ylabel('Port AoA [deg]');  xlim(lim)
        if p.Results.plotBeta
            plot(time(ran),squeeze(obj.betaBdy.Data(1,1,ran))*180/pi,'r--');  ylabel('Angle [deg]');  legend('Port Alpha','Beta');  xlim(lim)
        end
    end
else
    plot(time,squeeze(obj.alphaLocal.Data(1,1,:)),'b-');  ylabel('Port AoA [deg]');  xlim(lim)
    if p.Results.plotBeta
        plot(time,squeeze(obj.betaBdy.Data(1,1,:))*180/pi,'r--');  ylabel('Angle [deg]');  legend('Port Alpha','Beta');  xlim(lim)
    end
end
%%  Plot CL^3/CD^2
subplot(R,C,5); hold on; grid on
yyaxis left
if lap
    if con
        plot(data(ran),CLsurf(ran).^3./CDtot(ran).^2,'b-');  xlabel('Path Position');  ylabel('$\mathrm{CL^3/CD^2}$');  set(gca,'YColor',[0 0 1]);
    else
        plot(time(ran),CLsurf(ran).^3./CDtot(ran).^2,'b-');  xlabel('Time [s]');  ylabel('$\mathrm{CL^3/CD^2}$');  set(gca,'YColor',[0 0 1]);  xlim(lim)
    end
else
    plot(time,CLsurf.^3./CDtot.^2,'b-');  xlabel('Time [s]');  ylabel('$\mathrm{CL^3/CD^2}$');  set(gca,'YColor',[0 0 1]);  xlim(lim)
end
yyaxis right
if lap
    if con
        plot(data(ran),CLsurf(ran)./CDtot(ran),'r--');  xlabel('Path Position');  ylabel('$\mathrm{CL/CD}$');  set(gca,'YColor',[1 0 0])
    else
        plot(time(ran),CLsurf(ran)./CDtot(ran),'r--');  xlabel('Time [s]');  ylabel('$\mathrm{CL/CD}$');  set(gca,'YColor',[1 0 0]);  xlim(lim)
    end
else
    plot(time,CLsurf./CDtot,'r--');  xlabel('Time [s]');  ylabel('$\mathrm{CL/CD}$');  set(gca,'YColor',[1 0 0]);  xlim(lim)
end
%%  Plot Lift-Drag ratio
subplot(R,C,6); hold on; grid on
if lap
    if con
%         plot(data(ran),LiftDrag(ran),'b-');  xlabel('Path Position');  ylabel('L/D');   
        plot(data(ran),totDrag(ran)*1e-3,'r-');    xlabel('Path Position');  ylabel('Force [kN]');   
        plot(data(ran),FLiftBdy(ran)*1e-3,'b-');   xlabel('Path Position');  ylabel('Force [kN]');  legend('Drag','Lift') 
    else
        plot(time(ran),LiftDrag(ran),'b-');  xlabel('Time [s]');  ylabel('L/D');  xlim(lim);    
    end
else
    plot(time,LiftDrag,'b-');  xlabel('Time [s]');  ylabel('L/D');  xlim(lim);  
end
% figure; hold on; grid on
% plot(data(ran),CDtot(ran),'r-');  xlabel('Path Position');  ylabel('');
% plot(data(ran),CLsurf(ran),'b-');  xlabel('Path Position');  ylabel('');
% legend('CD','CL') 
%%  Assess wing tips
if p.Results.Vapp
    figure;
    subplot(3,1,1); hold on; grid on
    plot(data(ran),squeeze(obj.vAppLclBdy.Data(1,2,ran)),'b-'); ylabel('$\mathrm{V_{app}}$ X [m/s]')
    plot(data(ran),squeeze(obj.vAppWingTip.Data(1,2,ran)),'r--');
    legend('Aero Center','Wing Tip')
    subplot(3,1,2); hold on; grid on
    plot(data(ran),squeeze(obj.vAppLclBdy.Data(2,2,ran)),'b-'); ylabel('$\mathrm{V_{app}}$ Y [m/s]')
    plot(data(ran),squeeze(obj.vAppWingTip.Data(2,2,ran)),'r--');
    subplot(3,1,3); hold on; grid on
    plot(data(ran),squeeze(obj.vAppLclBdy.Data(3,2,ran)),'b-'); xlabel('Path Position'); ylabel('$\mathrm{V_{app}}$ Z [m/s]')
    plot(data(ran),squeeze(obj.vAppWingTip.Data(3,2,ran)),'r--');
end
end