function plotLiftDragComponents(obj,vhcl,env,varargin)
%%  Parse Inputs
p = inputParser;
addOptional(p,'plot1Lap',true,@islogical);
addOptional(p,'lapNum',1,@isnumeric);
addOptional(p,'xLim',[0 inf],@isnumeric);
addOptional(p,'Vapp',false,@islogical);
addOptional(p,'plotBeta',false,@islogical);
addOptional(p,'LiftDrag',false,@islogical);
addOptional(p,'dragChar',false,@islogical);
parse(p,varargin{:})

[Idx1,Idx2] = getLapIdxs(obj,max(obj.lapNumS.Data)-1);
if p.Results.plot1Lap
    ran = Idx1:Idx2-1;
    xLim = [0 1];
else
    ran = 1:length(obj.lapNumS.Time);
    xLim = p.Results.xLim;
end
pathPos = squeeze(obj.currentPathVar.Data(ran));
time = obj.lapNumS.Time(ran);
power = squeeze((obj.turbPow.Data(1,1,ran)))+squeeze((obj.turbPow.Data(1,2,ran)));
speed = (squeeze(obj.turbVel.Data(1,1,ran))+squeeze(obj.turbVel.Data(1,2,ran)))/2;
vKite = -squeeze(obj.velCMvec.Data(1,:,ran));
[CLtot,CDtot] = obj.getCLCD(vhcl);
CLtot = CLtot(ran);    CDtot = CDtot(ran);
Lwing = squeeze(obj.portWingLift.Data(:,1,ran)+obj.stbdWingLift.Data(:,1,ran));
Lstab = squeeze(obj.hStabLift.Data(:,1,ran));
Dwing = squeeze(obj.portWingDrag.Data(:,1,ran)+obj.stbdWingDrag.Data(:,1,ran));
Dstab = squeeze(obj.hStabDrag.Data(:,1,ran));
Dvert = squeeze(obj.vStabDrag.Data(:,1,ran));
Dfuse = squeeze(obj.FFuseBdy.Data(:,1,ran));
Dthr = squeeze(obj.thrDragVecs.Data(:,1,ran));
Dturb = squeeze(obj.FTurbBdy.Data(:,1,ran));
Ltot = Lwing+Lstab;
Dtot = Dwing+Dstab+Dvert+Dfuse+Dturb;
Lmag = squeeze(sqrt(sum(Ltot.^2,1)))';
Dmag = squeeze(sqrt(sum(Dtot.^2,1)))';
C1 = cosd(squeeze(obj.elevationAngle.Data(:,:,ran)));  C2 = cosd(squeeze(obj.azimuthAngle.Data(:,:,ran)));
PLoyd = 2/27*env.water.density.Value*env.water.speed.Value^3*vhcl.fluidRefArea.Value*CLtot.^3./CDtot.^2.*(C1.*C2).^3/vhcl.turb1.axialInductionFactor.Value;
vLoyd = Lmag./Dmag.*env.water.speed.Value.*(C1.*C2);
AoAport = squeeze(obj.portWingAoA.Data(1,1,ran));
AoAstbd = squeeze(obj.stbdWingAoA.Data(1,1,ran));
if p.Results.plot1Lap
    data = pathPos;
    xlab = 'Path Position';
else
    data = time;
    xlab = 'Time [s]';
end
%%  Plotting
figure(); subplot(3,2,1); hold on; grid on;
plot(data,power,'b-');
plot(data,PLoyd,'r--'); xlabel(xlab); ylabel('Power [W]'); legend('Turb','Loyd'); xlim(xLim);
subplot(3,2,2); hold on; grid on;
plot(data,vKite,'b-');   plot(data,speed,'g-');
plot(data,vLoyd,'r--');  xlabel(xlab); ylabel('Speed [m/s]'); xlim(xLim);
legend('CM','Turb','Loyd','location','southeast'); ylim([0,inf]);
subplot(3,2,3); hold on; grid on;
plot(data,AoAport,'b-');
plot(data,AoAstbd,'r-'); xlabel(xlab); ylabel('AoA [deg]'); legend('Port','Stbd'); xlim(xLim);
subplot(3,2,4); hold on; grid on; yyaxis left
plot(data,Ltot(1,:)+Dtot(1,:),'b-');  ylabel('Fluid Force [N]');  set(gca,'YColor',[0 0 1]);  yyaxis right
plot(data,(Ltot(3,:)+Dtot(3,:))*1e-3,'r-');  ylabel('Fluid Force [kN]');  set(gca,'YColor',[1 0 0]);
legend('$\hat{i}$','$\hat{k}$'); xlabel(xlab); ylabel('Fluid Force [N]'); xlim(xLim);
subplot(3,2,5); hold on; grid on; yyaxis left
plot(data,CLtot.^3./CDtot.^2,'b-');  xlabel(xlab);  ylabel('$\mathrm{CL^3/CD^2}$');
set(gca,'YColor',[0 0 0]);  xlim(xLim);  yyaxis right
plot(data,CLtot./CDtot,'r-');  plot(data,Lmag./Dmag,'k-');  legend('$\mathrm{CL^3/CD^2}$','CL/CD','L/D','location','southeast');
xlabel(xlab);  ylabel('Ratios');  set(gca,'YColor',[0 0 0]);  xlim(xLim);
subplot(3,2,6); hold on; grid on; yyaxis left
plot(data,Lmag*1e-3,'b-');  xlabel(xlab);  ylabel('Force [kN]'); xlim(xLim);
plot(data,Dmag*1e-3,'r-');  set(gca,'YColor',[0 0 0]);  legend('Lift','Drag');  yyaxis right;
plot(data,CLtot,'b--');  xlabel(xlab);  ylabel('CD and CL');  set(gca,'YColor',[0 0 0])
plot(data,CDtot,'r--');  legend('$\mathrm{F_{lift}}$','$\mathrm{F_{drag}}$','CL','CD');  xlim(xLim);
end