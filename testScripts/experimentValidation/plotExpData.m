
% superimpose plots from simulation and experiment
datFileName = 'data_24_Jan_2020_16_23_38.mat';
fullFileName = strcat(cd,'\Jan24DataFiles\',datFileName);

tscExp = processExpData(fullFileName,...
    'Ro_c_in_meters',[22;0;-3.9]./100,...
    'yawOffset',1*2.5,...
    'ycmOffset',-0.0075);

% define time to observe
timeExp = tscExp.roll_rad.Time;
tStart = 100; %change to 0 if needed.
tEnd = numel(timeExp);
% tEnd = 15001;
tPlot = tStart:tEnd;

% plotting data range
plotDataRange = [0 300];

locs = getFigLocations(560,420);

% % % euler angles %%%%%%%%%%%%%%%%%%%%%%%%%
fn = 0;
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))
% % % % experiment
vectorPlotter(timeExp(tPlot),(180/pi)*[tscExp.roll_rad.Data(tPlot)';...
    tscExp.pitch_rad.Data(tPlot)';...
    tscExp.yaw_rad.Data(tPlot)'],...
    'lineSpec','-',...
    'legends',{'$\phi_{exp}$','$\theta_{exp}$','$\psi_{exp}$'},...
    'ylabels',{'Roll','Pitch','Yaw'},...
    'yUnits','(deg)',...
    'figureTitle','Euler angles');
% % % % setpoints
subplot(3,1,1)
plot(timeExp(tPlot),(180/pi)*tscExp.RollSetpoint.Data(tPlot),'k--','linewidth',0.75)
legend('$\phi$','SP')


% % % % CM positions  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fn = fn+1;
figure(fn);
set(gcf,'Position',locs(fn,:))
% % % % experiment
vectorPlotter(timeExp(tPlot),squeeze(tscExp.CoMPosVec_cm.Data(:,tPlot)),...
    'lineSpec','-',...
    'legends',{'$x_{exp}$','$y_{exp}$','$z_{exp}$'},...
    'ylabels',{'$x_{cm}$','$y_{cm}$','$z_{cm}$'},...
    'yUnits','(m)',...
    'figureTitle','CM position');

subplot(3,1,1)
title('CM position');

% % % % controller command
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))
% % % % experiment
vectorPlotter(timeExp(tPlot),0.028.*squeeze(tscExp.mtrCmds.Data(:,tPlot)),...
    'lineSpec','-',...
    'legends',{'$u_{port,exp}$','$u_{aft,exp}$','$u_{stbd,exp}$'},...
    'ylabels',{'$u_{port}$','$u_{aft}$','$u_{stbd}$'},...
    'yUnits','(m/s)',...
    'figureTitle','Tether release speeds');

% % % % cm velocity
fn = fn+1;
figure(fn)
set(gcf,'Position',locs(fn,:))
% % % % experiment
vectorPlotter(timeExp(tPlot(1:end-2)),tscExp.CoMVelVec_cm.Data(:,tPlot(1:end-2)),...
    'lineSpec','-',...
    'legends',{'$V_{x,sim}$','$V_{y,sim}$','$V_{z,sim}$'},...
    'ylabels',{'$V_x$','$V_y$','$V_z$'},...
    'yUnits','(m/s)',...
    'figureTitle','CM velocity');
subplot(3,1,1)
title('CM velocity')

%%%%%%
set(findobj('Type','axes'),'XLim',plotDataRange);
set(findobj('Type','legend'),'Visible','off');
