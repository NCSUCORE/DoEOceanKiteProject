%% Script to run ILC path optimization
clc;clear;close all
lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 1000*sqrt(lengthScaleFactor);
dynamicCalc = '';

% set_param('OCTModel','Profile','off')

%% Load components
% Flight Controller
loadComponent('pathFollowingForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('fig8ILC')
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('fiveNodeSingleTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
% loadComponent('constT_XYZvarZ_Ramp');
loadComponent('constXYZT');

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([1,1.1,20*pi/180,0,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1,1.1,20*pi/180,0,125 0.25 0.09],'') % Lemniscate of Booth

%% Environment IC's and dependant properties
% env.water.nominal100mFlowVec.setValue([2 0 0]','m/s')
env.water.flowVec.setValue([2 0 0]','m/s')

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    (11.5/2)*norm(env.water.flowVec.Value)) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
fltCtrl.winchSpeedIn.setValue(-2/3,'m/s');
fltCtrl.winchSpeedOut.setValue(2/3,'m/s');

%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;

%% Plot basis parameters vs time and iteration number
iterBasisParams = resample(tsc.basisParams,tsc.estGradient.Time);
figure('Name','Basis Parameters')
subplot(2,1,1)
plot(tsc.basisParams.Time,...
    squeeze(tsc.basisParams.Data(1,:,:)),...
    'DisplayName','$b_1$',...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
hold on
grid on
plot(tsc.basisParams.Time,...
    squeeze(tsc.basisParams.Data(2,:,:)),...
    'DisplayName','$b_2$',...
    'Color','k',...
    'LineStyle','--',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Basis','Parameters'})
legend

subplot(2,1,2)
stairs(squeeze(iterBasisParams.Data(1,:,:)),...
    'DisplayName','$b_1$',...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
hold on
grid on
stairs(squeeze(iterBasisParams.Data(2,:,:)),...
    'DisplayName','$b_2$',...
    'Color','k',...
    'LineStyle','--',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Basis','Parameters'})
legend 

set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot Performance Index
% Resample to plot against iteration index
figure('Name','Performance Index')
iterPerf = resample(tsc.perfIndx,tsc.estGradient.Time);
subplot(2,1,1)
iterPerf.plot('Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Performance','Index'})

subplot(2,1,2)
stairs(iterPerf.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Performance','Index'})
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot Mean Power
figure('Name','Mean Power')
iterPower = resample(tsc.meanPower,tsc.estGradient.Time);
subplot(2,1,1)
iterPower.plot('Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Mean','Power'})

subplot(2,1,2)
stairs(iterPower.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Mean','Power'})
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot Mean Distance To Path
figure('Name','Mean Ang To Path')
iterDist = resample(tsc.meanDistToPath,tsc.estGradient.Time);
subplot(2,1,1)
iterDist.plot('Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Time, [s]')
ylabel({'Mean Ang.','To Path, [rad]'})

subplot(2,1,2)
stairs(iterDist.Data,...
    'Color','k',...
    'LineStyle','-',...
    'LineWidth',2)
xlabel('Iteration Number')
ylabel({'Mean Ang.','To Path, [rad]'})
set(findall(gcf,'Type','axes'),'FontSize',24)

%% Plot initial and final path geometry
iterations = [1 5 10 24 25];
lineStyles = {'-','--','-.',':',':'};
pathFcn = @(x) eval(sprintf('%s(linspace(0,1,100),x)',fltCtrl.fcnName.Value));
iterBasisParams = resample(tsc.basisParams,tsc.estGradient.Time);
figure('Name','Path Geometry Comparison')
for ii = 1:length(iterations)
    iterNum = min(iterations(ii),numel(iterBasisParams.Time));
   pathPts = pathFcn(iterBasisParams.Data(:,:,iterNum));
   plot3(pathPts(1,:),pathPts(2,:),pathPts(3,:),...
       'Color','k',...
       'LineWidth',1.5,...
       'DisplayName',sprintf('Iteration %d',iterNum),...
       'LineStyle',lineStyles{ii})
   hold on
   grid on
end
legend
xlabel('X Position')
ylabel('Y Position')
zlabel('Z Position')
daspect([1 1 1])
view([63.256 32.88])
set(gca,'FontSize',24)

% 
figure
tsc.tetherLengths.plot

%% Save all the plots
% saveAllPlots

%% Animate the results
% vhcl.animateSim(tsc,1,...
%     'PathFunc',fltCtrl.fcnName.Value,...
%     'PathPosition',false,...
%     'NavigationVecs',false,...
%     'Pause',false,...
%     'SaveGif',true,...
%     'GifTimeStep',0.05,...
%     'ZoomIn',false,...
%     'FontSize',24,...
%     'PowerBar',true,...
%     'ColorTracer',true);


