function plotLaR(obj,ctrl,varargin)

p = inputParser;
addOptional(p,'Steady',false,@islogical);
parse(p,varargin{:})

if p.Results.Steady
    R = 3;  C = 1;  I1 = 2;  I2 = 3;
    Mwing = squeeze(obj.portWingMoment.Data(2,:,:))+squeeze(obj.stbdWingMoment.Data(2,:,:));
    MhStab = squeeze(obj.hStabMoment.Data(2,:,:));
    MvStab = squeeze(obj.vStabMoment.Data(2,:,:));
    Mfuse = squeeze(obj.MFuseBdy.Data(2,:,:));
    Mstatic = squeeze(obj.MBuoyBdy.Data(2,:,:))+squeeze(obj.MGravBdy.Data(2,:,:));
    Madd = squeeze(obj.MAddedBdy.Data(2,:,:));
    Mthr = squeeze(obj.MThrNetBdy.Data(2,:,:));
    Mnet = squeeze(obj.MNetBdy.Data(2,:,:));
else
    R = 3;  C = 2;  I1 = 3;  I2 = 5;
end
time = obj.MNetBdy.Time;
airNode = squeeze(sqrt(sum(obj.airTenVecs.Data.^2,1)))*1e-3;
gndNode = squeeze(sqrt(sum(obj.gndNodeTenVecs.Data.^2,1)))*1e-3;
coneWidth = ctrl.LaRelevationSPErr.Value;
figure();
%%  Plot Elevation Angle
subplot(R,C,1); hold on; grid on;
if ~p.Results.Steady
    if numel(obj.elevationSP.Data) == 1
        plot(obj.elevationAngle.Time,obj.elevationSP.Data*ones(length(obj.elevationAngle.Time),1),'r-');
        plot(obj.elevationAngle.Time,(obj.elevationSP.Data+coneWidth)*ones(length(obj.elevationAngle.Time),1),'c--');
        plot(obj.elevationAngle.Time,(obj.elevationSP.Data-coneWidth)*ones(length(obj.elevationAngle.Time),1),'c--');
        plot(obj.elevationAngle.Time,(obj.elevationSP.Data+coneWidth/2)*ones(length(obj.elevationAngle.Time),1),'r--');
        plot(obj.elevationAngle.Time,(obj.elevationSP.Data-coneWidth/2)*ones(length(obj.elevationAngle.Time),1),'r--');
    else
        plot(obj.elevationSP.Time,squeeze(obj.elevationSP.Data),'r-');
    end
end
plot(obj.elevationAngle.Time,squeeze(obj.elevationAngle.Data),'b-');  xlabel('Time [s]');  ylabel('Elevation [deg]');  %xlim([1900 2100])
%%  Plot Pitch Angle
subplot(R,C,I1); hold on; grid on;
plot(obj.pitchSP.Time,squeeze(obj.pitchSP.Data),'r-');
plot(obj.pitch.Time,squeeze(obj.pitch.Data)*180/pi,'b-');  xlabel('Time [s]');  ylabel('Pitch [deg]');
legend('Setpoint','AutoUpdate','off','location','northwest')
%%  Plot Elevator Command
subplot(R,C,I2); hold on; grid on;
plot(obj.ctrlSurfDeflCmd.Time,squeeze(obj.ctrlSurfDeflCmd.Data(:,3)),'b-');  xlabel('Time [s]');  ylabel('Elevator [deg]');
if ~p.Results.Steady
    %%  Tether Length
    subplot(R,C,2); hold on; grid on;
    plot(obj.tetherLengths.Time,squeeze(obj.tetherLengths.Data),'b-');  xlabel('Time [s]');  ylabel('Length [m]');  %xlim([1900 2100])
    %%  Plot Spool Command
    subplot(R,C,4); hold on; grid on;
    plot(time,squeeze(obj.wnchCmd.Data),'b-');
    xlabel('Time [s]');  ylabel('Winch [m/s]');  %xlim([1900 2100])
    %%  Plot Tether Tension
    subplot(R,C,6); hold on; grid on;
    plot(time,airNode,'b-');  plot(time,gndNode,'r--');  %ylim([0 .5]);
    xlabel('Time [s]');  ylabel('Tension [kN]');  legend('Kite','Glider');  %xlim([1900 2100])
else
    %%  Plot Tether Tension
    figure; subplot(2,1,1); hold on; grid on;
    plot(time,Mwing,'b');   plot(time,MhStab,'r');
    plot(time,MvStab,'m');  plot(time,Mfuse,'c');
    plot(time,Mthr,'color',[255,153,51]/255);    plot(time,Mstatic,'g');
    plot(time,Madd,'color',[.45,0,0]);    
    xlabel('Time [s]');  ylabel('Moment [Nm]');
    legend('Wing','hStab','vStab','Fuse','Thr','Buoy+Grav','Add');
    subplot(2,1,2); hold on; grid on;
    plot(time,Mnet,'k-');  xlabel('Time [s]');  ylabel('Net Moment [Nm]');
end
end