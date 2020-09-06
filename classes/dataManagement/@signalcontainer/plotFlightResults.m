function plotFlightResults(obj,vhcl,env,varargin)
%%  Parse Inputs
p = inputParser;
addOptional(p,'plot1Lap',false,@islogical);
addOptional(p,'lapNum',1,@isnumeric);
addOptional(p,'plotS',false,@islogical);
addOptional(p,'Vapp',false,@islogical);
addOptional(p,'plotBeta',false,@islogical);
addOptional(p,'LiftDrag',false,@islogical);
parse(p,varargin{:})

R = 3;  C = 2;
data = squeeze(obj.currentPathVar.Data);
time = obj.lapNumS.Time;
lap = p.Results.plot1Lap;
con = p.Results.plotS;
turb = isprop(obj,'turbPow');
%%  Determine Single Lap Indices
if lap
    [Idx1,Idx2] = getLapIdxs(obj,1);
    ran = Idx1:Idx2-1;
    lim = [time(Idx1) time(Idx2)];
else
    lim = [time(1) time(end)];
end
%%  Compute Plotting Variables
if turb
    N = vhcl.numTurbines.Value;
    if N == 1
        power = squeeze(obj.turbPow.Data(1,1,:));
        energy = squeeze(obj.turbEnrg.Data(1,1,:))/1000/3600;
    else
        power = squeeze((obj.turbPow.Data(1,1,:)))+squeeze((obj.turbPow.Data(1,2,:)));
        energy = squeeze((obj.turbEnrg.Data(1,1,:)))/1000/3600+squeeze((obj.turbEnrg.Data(1,2,:)))/1000/3600;
        speed = (squeeze(obj.turbVel.Data(1,1,:))+squeeze(obj.turbVel.Data(1,2,:)))/2;
    end
else
    power = squeeze(obj.winchPower.Data(:,1));
    energy = cumtrapz(time,power)/1000/3600;
end
vKite = -squeeze(obj.velCMvec.Data(1,:,:));
%   Tether tension
airNode = squeeze(sqrt(sum(obj.airTenVecs.Data.^2,1)))*1e-3;
gndNode = squeeze(sqrt(sum(obj.gndNodeTenVecs.Data.^2,1)))*1e-3;
%   Hydrocharacteristics
[CLsurf,CDtot] = getCLCD(obj,vhcl);
FLiftBdyP1 = squeeze(sqrt(sum(obj.portWingLift.Data(:,1,:).^2,1)));
FLiftBdyP2 = squeeze(sqrt(sum(obj.stbdWingLift.Data(:,1,:).^2,1)));
FLiftBdyP3 = squeeze(sqrt(sum(obj.hStabLift.Data(:,1,:).^2,1)));
FLiftBdy   = FLiftBdyP1 + FLiftBdyP2 + FLiftBdyP3;
FDragBdyP1 = squeeze(sqrt(sum(obj.portWingDrag.Data(:,1,:).^2,1)));
FDragBdyP2 = squeeze(sqrt(sum(obj.stbdWingDrag.Data(:,1,:).^2,1)));
FDragBdyP3 = squeeze(sqrt(sum(obj.hStabDrag.Data(:,1,:).^2,1)));
FDragBdyP4 = squeeze(sqrt(sum(obj.vStabDrag.Data(:,1,:).^2,1)));
FDragBdy = FDragBdyP1 + FDragBdyP2 + FDragBdyP3 + FDragBdyP4;
FDragFuse = squeeze(sqrt(sum(obj.FFuseBdy.Data.^2,1)));
FDragThr = squeeze(sqrt(sum(obj.thrDragVecs.Data.^2,1)));
if turb
    FTurbBdy = squeeze(sqrt(sum(obj.FTurbBdy.Data.^2,1)));
    totDrag = (FDragBdy + FTurbBdy + FDragFuse + FDragThr);
    LiftDrag = FLiftBdy./(FDragBdy + FTurbBdy + FDragFuse );
else
    totDrag = (FDragBdy + FDragFuse + FDragThr);
    LiftDrag = FLiftBdy./(FDragBdy + FDragFuse);
end
C1 = cosd(squeeze(obj.elevationAngle.Data));  C2 = cosd(squeeze(obj.azimuthAngle.Data));
vLoyd = LiftDrag.*env.water.speed.Value.*(C1.*C2);
PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLsurf.^3./CDtot.^2.*(C1.*C2).^3/vhcl.turb1.axialInductionFactor.Value;
% figure();
% hold on; grid on
% plot(FTurbBdy./(totDrag-FTurbBdy),'b-');  ylabel('$\mathrm{D_t/D_k}$');
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
        plot(time(ran),power(ran)*1e-3,'b-');  ylabel('Power [kW]');  set(gca,'YColor',[0 0 1]);  xlim(lim);  ylim([0 inf]);
        plot(time(ran),PLoyd(ran)*1e-3,'b--');  ylabel('Power [kW]');  legend('Kite','Loyd','location','southeast','AutoUpdate','off');  ylim([0 inf]);
    end
else
    plot(time,power*1e-3,'b-');  ylabel('Power [kW]');  set(gca,'YColor',[0 0 1]);  xlim(lim);  ylim([0 inf]);
    plot(time,PLoyd*1e-3,'b--');  ylabel('Power [kW]');  legend('Kite','Loyd','location','southeast','AutoUpdate','off');  ylim([0 inf]);
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
%%  Plot Speed
subplot(R,C,3); hold on; grid on
if lap
    if con
        if turb
            plot(data(ran),speed(ran),'g-');  ylabel('Speed [m/s]');
            plot(data(ran),vKite(ran),'b-');  ylabel('Speed [m/s]');
            plot(data(ran),vLoyd(ran),'r--');  ylabel('Speed [m/s]');  legend('Turb','Kite','Loyd');
        else
            plot(data(ran),vKite(ran),'b-');  ylabel('Speed [m/s]');
            plot(data(ran),vLoyd(ran),'r--');  ylabel('Speed [m/s]');  legend('Kite','Loyd');
        end
    else
        if turb
            plot(time(ran),speed(ran),'g-');  ylabel('Speed [m/s]');  xlim(lim)
            plot(time(ran),vKite(ran),'b-');  ylabel('Speed [m/s]');
            plot(time(ran),vLoyd(ran),'r--');  ylabel('Speed [m/s]');  legend('Turb','Kite','Loyd');
        else
            plot(time(ran),vKite(ran),'b-');  ylabel('Speed [m/s]');
            plot(time(ran),vLoyd(ran),'r--');  ylabel('Speed [m/s]');  legend('Kite','Loyd');
        end
    end
else
    if turb
        plot(time,speed,'g-');  ylabel('Speed [m/s]');  xlim(lim)
        plot(time,vKite,'b-');  ylabel('Speed [m/s]');
        plot(time,vLoyd,'r--');  ylabel('Speed [m/s]');  legend('Turb','Kite','Loyd');
    else
        plot(time,vKite,'b-');  ylabel('Speed [m/s]');
        plot(time,vLoyd,'r--');  ylabel('Speed [m/s]');  legend('Kite','Loyd');
    end
end
%%  Plot Angle of attack
subplot(R,C,4); hold on; grid on
if lap
    if con
        plot(data(ran),squeeze(obj.portWingAoA.Data(1,1,ran)),'b-');
        plot(data(ran),squeeze(obj.stbdWingAoA.Data(1,1,ran)),'r-');  ylabel('Angle [deg]');  legend('Port AoA','Stbd AoA')
        if p.Results.plotBeta
            plot(data(ran),squeeze(obj.betaBdy.Data(1,1,ran))*180/pi,'g-');  ylabel('Angle [deg]');  legend('Port AoA','Stbd AoA','Beta')
        end
    else
        plot(time(ran),squeeze(obj.portWingAoA.Data(1,1,ran)),'b-');
        plot(time(ran),squeeze(obj.stbdWingAoA.Data(1,1,ran)),'r-');  ylabel('Angle [deg]');  xlim(lim);  legend('Port AoA','Stbd AoA')
        if p.Results.plotBeta
            plot(time(ran),squeeze(obj.betaBdy.Data(1,1,ran))*180/pi,'g-');  ylabel('Angle [deg]');  legend('Port AoA','Stbd AoA','Beta');  xlim(lim)
        end
    end
else
    plot(time,squeeze(obj.portWingAoA.Data(1,1,:)),'b-');
    plot(time,squeeze(obj.stbdWingAoA.Data(1,1,:)),'r-');  ylabel('Angle [deg]');  xlim(lim);  legend('Port AoA','Stbd AoA')
    if p.Results.plotBeta
        plot(time,squeeze(obj.betaBdy.Data(1,1,:))*180/pi,'g-');  ylabel('Angle [deg]');  legend('Port AoA','Stbd AoA','Beta');  xlim(lim)
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
yyaxis left
if lap
    if con
        plot(data(ran),totDrag(ran)*1e-3,'r-');    xlabel('Path Position');  ylabel('Force [kN]');  set(gca,'YColor',[0 0 0])
        plot(data(ran),FLiftBdy(ran)*1e-3,'b-');   xlabel('Path Position');  ylabel('Force [kN]');  legend('Drag','Lift') 
    else
        plot(time(ran),totDrag(ran)*1e-3,'r-');    xlabel('Time [s]');  ylabel('Force [kN]');  set(gca,'YColor',[0 0 0])
        plot(time(ran),FLiftBdy(ran)*1e-3,'b-');   xlabel('Time [s]');  ylabel('Force [kN]');  legend('Drag','Lift') ;  xlim(lim);
    end
else
    plot(time,totDrag*1e-3,'r-');    xlabel('Time [s]');  ylabel('Force [kN]');  set(gca,'YColor',[0 0 0])
    plot(time,FLiftBdy*1e-3,'b-');   xlabel('Time [s]');  ylabel('Force [kN]');  legend('Drag','Lift') ;  xlim(lim);
end
yyaxis right
if lap
    if con
        plot(data(ran),CDtot(ran),'r--');    xlabel('Path Position');  set(gca,'YColor',[0 0 0])
        plot(data(ran),CLsurf(ran),'b--');   xlabel('Path Position');  ylabel('CD and CL');  legend('Drag','Lift','CD','CL')
    else
        plot(time(ran),CDtot(ran),'r--');    xlabel('Time [s]');  set(gca,'YColor',[0 0 0])
        plot(time(ran),CLsurf(ran),'b--');   xlabel('Time [s]');  ylabel('CD and CL');  legend('Drag','Lift','CD','CL') ;  xlim(lim);
    end
else
    plot(time,CDtot,'r--');    xlabel('Time [s]');  set(gca,'YColor',[0 0 0])
    plot(time,CLsurf,'b--');   xlabel('Time [s]');  ylabel('CD and CL');  legend('Drag','Lift','CD','CL') ;  xlim(lim);
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