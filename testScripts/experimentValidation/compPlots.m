% superimpose plots from simulation and experiment

load 'data_19_Nov_2019_19_08_19.mat' 

plotPropsSim = plotProps;
plotPropsExp = plotProps;
plotPropsExp{2} = '--';

% define time to observe 
tscExp = tsc;
timeExp = tscExp.roll_rad.Time;
tStart = 100; %change to 0 if needed.
tEnd = numel(timeExp);
% tEnd = 15001;
tPlot = tStart:tEnd;
% tend => end;  -- change if needed  


% % % euler angles
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))
vectorPlotter(timeSim,sol_euler*180/pi,plotPropsSim,...
    {'$\phi_{sim}$','$\theta_{sim}$','$\psi_{sim}$'},'Angle (deg)','Euler Angles');
% % % setpoints
if Lscale == 1 && Dscale == 1
subplot(3,1,1)
plot(timeSim,squeeze(tscSim.rollSetpoint.Data),'k--',...
    'DisplayName','$\phi_{sp}$');
subplot(3,1,2)
plot(timeSim,squeeze(tscSim.pitchSetpoint.Data),'k--',...
    'DisplayName','$\theta_{sp}$');
subplot(3,1,3)
plot(timeSim,squeeze(tscSim.yawSetpoint.Data),'k--',...
    'DisplayName','$\theta_{sp}$');
end

%filter bad data
badData = find(tscExp.yaw_rad.Data>100);
tscExp.yaw_rad.Data(badData) = 0.5*(tscExp.yaw_rad.Data(badData-1) + tscExp.yaw_rad.Data(badData+1));

vectorPlotter(timeExp(tPlot),(180/pi)*[tscExp.roll_rad.Data(tPlot)';...
    tscExp.pitch_rad.Data(tPlot)';...
    tscExp.yaw_rad.Data(tPlot)'],plotPropsExp,...
    {'$\phi_{exp}$','$\theta_{exp}$','$\psi_{exp}$'},'Angle (deg)','');

subplot(3,1,1)
plot(timeExp(tPlot),(180/pi)*tsc.RollSetpoint.Data(tPlot),'k--','linewidth',0.75)
legend('$\phi$','SP')
title('Euler angles')


% % % % CM positions 
fn = fn+1;
figure(fn);
set(gcf,'Position',locs(fn,:))
vectorPlotter(timeSim,sol_Rcm_o,plotPropsSim,...
    {'$x_{cm,sim}$','$y_{cm,sim}$','$z_{cm,sim}$'},'Position (m)','CM position');

figure(fn)
set(gcf,'Position',locs(fn,:));
Rconfluence_o = [-10;0;0];

cmDat = 0.6*gndStn.posVec.Value(:) + squeeze(tscExp.CoMPosVec_cm.data)./100;

vectorPlotter(timeExp(tPlot),cmDat(:,tPlot),plotPropsExp,...
    {'$x_{cm,exp}$','$y_{cm,exp}$','$z_{cm,exp}$'},'Position (m)','');

subplot(3,1,1)
title('CM position');

% % % % controller command
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))
vectorPlotter(timeSim,tscSim.thrReleaseSpeeds.Data'.*(1/Lscale^0.5),plotPropsSim,...
    {'$u_{port}$','$u_{aft}$','$u_{stbd}$'},'Speed (m/s)','Tether release speeds');

mtrCmd = squeeze(tscExp.mtrCmds.Data);
mtrCmd = mtrCmd([2 3 1],:);
mtrCmd(mtrCmd>1) = 1;
mtrCmd(mtrCmd<-1) = -1;
mtrCmd = wnch.winch1.maxSpeed.Value.*mtrCmd;

vectorPlotter(timeExp(tPlot),mtrCmd(:,tPlot),plotPropsExp,...
    {'$u_{port}$','$u_{aft}$','$u_{stbd}$'},'Speed (m/s)','Tether release speeds');


% Velocity tracking  
% % % % Velocity tracking  
Vx = diff(cmDat(1,:))./0.01; 
Vy = diff(cmDat(2,:))./0.01; 
Vz = diff(cmDat(3,:))./0.01; 

windowSize_vel = 20; 
b = (1/windowSize_vel)*ones(1,windowSize_vel);
a = 1;
Vz_f = filter(b,a,Vz);
Vx_f = filter(b,a,Vx);
Vy_f = filter(b,a,Vy);

Vcm = [Vx_f;Vy_f;Vz_f];

% % cm velocity
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))
vectorPlotter(timeSim,sol_Vcmo,plotProps,...
    {'$V_{x}$','$V_{y}$','$V_{z}$'},'Velocity (m/s)','CM velocity');

vectorPlotter(timeExp(tPlot(1:end-2)),Vcm(:,tPlot(1:end-2)),plotPropsExp,...
    {'$V_{x}$','$V_{y}$','$V_{z}$'},'Velocity (m/s)','CM velocity');

subplot(3,1,1)
title('CM velocity')

%%%%%%
set(findobj('Type','axes'),'XLim',[0 timeSim(end)]);
