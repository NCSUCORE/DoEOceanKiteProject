%% Script to run ILC path optimization
 tetherLengths = [ 50 125 200];
 flowSpeeds = [ 2 1.5 1 .5 ];
 for ppp = 2:2
     for qqq = 3:3
clc;close all
clearvars -except ppp qqq flowSpeeds tetherLengths
if ~slreportgen.utils.isModelLoaded('OCTModel')
    OCTModel
end
lengthScaleFactor = 1/1;
densityScaleFactor = 1/1;
duration_s  = 3600*sqrt(lengthScaleFactor);
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
% loadComponent('constXYZ_varT_SineWave');
%loadComponent('constX_YZvarT_CNAPSTurb');
%loadComponent('constX_YZvarT_ADCPTurb');
%loadComponent('constXY_ZvarT_ADCP');
loadComponent('constXYZT');
 SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipse';
PATHGEOMETRY = 'ellipse';
%% Set basis parameters for high level controller
%hiLvlCtrl.basisParams.setValue([1,.7,.36,0,tetherLengths(ppp)],'') % Lemniscate of Booth
 hiLvlCtrl.basisParams.setValue([.8,.7,.36,0,tetherLengths(ppp)],'');   
% [3*pi/8,pi/8,pi/8,0,125]% ellipse
%% Environment IC's and dependant properties
 env.water.flowVec.setValue([flowSpeeds(qqq) 0 0]','m/s')

%% Ground Station IC's and dependant properties
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
% vhcl.setICsOnPath(...
%     0,... % Initial path position
%     PATHGEOMETRY,... % Name of path function
%     hiLvlCtrl.basisParams.Value,... % Geometry parameters
%     (11.5/2)*norm(env.water.flowVec.Value)) % Initial speed
% vhcl.setAddedMISwitch(false,'');
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    (11.5/2)*norm([flowSpeeds(qqq)  0 0])) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,env,thr,[flowSpeeds(qqq),0,0]);

%% Controller User Def. Parameters and dependant properties
% fltCtrl.setFcnName(PATHGEOMETRY,''); 
 fltCtrl.setFcnName('ellipse','');% PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value)
% fltCtrl.winchSpeedIn.setValue(-norm(env.water.flowVec.Value)/3,'m/s');
% fltCtrl.winchSpeedOut.setValue(norm(env.water.flowVec.Value)/3,'m/s');


%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout;

%% 
tsc.LThr.plot
grid on
hold on
tsc.LThrSP.plot

title('Tether Length vs. Tether Length SP')
xlabel('Time (s)')
ylabel('Length (m)')
legend('Tether Length','Tether Length SP')
 
%% power
% timestepStart = 80.04
% time = tsc.winchPower.time;
% dt = diff(tsc.winchPower.time);


%  save('adcpTurbSave','-v7.3')

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
%     'PowerBar',false,...
%     'ColorTracer',true);
% % 
% 

avgFlowMag =[ mean( diff(tsc.vhclFlowVecs.time)); diff(tsc.vhclFlowVecs.time)]' .* sqrt(sum(squeeze(tsc.vhclFlowVecs.data(:,5,:)).^2));

rAvg = sum(avgFlowMag)/tsc.vhclFlowVecs.time(end);

% avgPowerMag =[ mean( diff(tsc.vhclFlowVecs.time)); diff(tsc.vhclFlowVecs.time(3771:end))] .* tsc.winchPower.data(3771:end);
% 
% rPAvg = sum(avgPowerMag)/(tsc.vhclFlowVecs.time(end)- tsc.vhclFlowVecs.time(3771))



avgCAMag =[ mean( diff(tsc.vhclFlowVecs.time)); diff(tsc.vhclFlowVecs.time)] .* tsc.central_angle.data;

rCAvg = sum(avgCAMag)/(tsc.vhclFlowVecs.time(end))

k = find(tsc.winchPower.data);
P = min(k)

% avgPowerMag =[ mean( diff(tsc.vhclFlowVecs.time)); diff(tsc.vhclFlowVecs.time)] .* tsc.winchPower.data;
% 
% rPAvg = sum(avgPowerMag)/tsc.vhclFlowVecs.time(end)



%% POWER PLOT

figure; 
plot(tsc.vhclFlowVecs.time, tsc.winchPower.data)
title('Power vs. Time ' ) 
xlabel('Time (s) ' ) 
ylabel('Power (Watts)')
timevec=tsc.winchPower.Time;
xlim([0,timevec(end)])

 [~,i1]=min(abs(timevec - 600));
 [~,i2]=min(abs(timevec -1000)); %(timevec(end)/2)));
 [~,poweri1]=min(tsc.winchPower.Data(i1:i2));
 poweri1 = poweri1 + i1;
[~,i3]=min(abs(timevec - (timevec(end)/2)));
[~,i4]=min(abs(timevec - timevec(end)));
i4=i4-1;
[~,poweri2]=min(tsc.winchPower.Data(i3:i4));
poweri2 = poweri2 + i3;
% Manual Override. Rerun with this to choose times
%           t1 = input("time for first measurement");
%             [~,poweri1]=min(abs(timevec - t1));
%             t2 = input("time for second measurement");
%             [~,poweri2]=min(abs(timevec - t2));
hold on
ylims=ylim;
plot([timevec(poweri1) timevec(poweri1)], [-1e6 1e6],'r--')
plot([timevec(poweri2) timevec(poweri2)], [-1e6 1e6],'r--')
ylim(ylims);

avgPowerMag =[ mean( diff(tsc.winchPower.time)); diff(tsc.winchPower.time(poweri1:poweri2))] .* tsc.winchPower.data(poweri1:poweri2);

rPAvg = sum(avgPowerMag)/(tsc.winchPower.time(poweri2)- tsc.vhclFlowVecs.time(poweri1))

title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',rPAvg ));

%% mean power over laps
% timeMat = [];
% lapNum = tsc.lapNumS.data;
% lapTime = tsc.lapNumS.time; 
% for i = 1:length(lapNum)-1
%      
%     if lapNum(i + 1) > lapNum(i)
%         
%         timeMat = [timeMat,lapTime(i)];
%         
%     end
%     
% end
% iterPower = resample(tsc.avgPower, timeMat);
% figure
% stairs(iterPower.Data,...
%     'Color','k',...
%     'LineStyle','-',...
%     'LineWidth',2)
% xlabel('Iteration Number')
% ylabel({'Mean','Power'})
% title('Mean Power vs. Iteration Number')
% set(findall(gcf,'Type','axes'),'FontSize',24)
% xlim([2,lapNum(end)])


%% INCORRECT POWER
% figure
%  timevec=tsc.velocityVec.Time;
%  ten=squeeze(sqrt(sum(tsc.FThrNetBdy.Data.^2,1)));
% plot(tsc.cmdThrReleaseSpeeds.Time,tsc.cmdThrReleaseSpeeds.Data.*ten)
% xlabel('time (s)')
% ylabel('Power (Watts)')
%  [~,i1]=min(abs(timevec - 600));
%  [~,i2]=min(abs(timevec -1000)); %(timevec(end)/2)));
%  [~,poweri1]=min(tsc.cmdThrReleaseSpeeds.Data(i1:i2).*ten(i1:i2));
% poweri1 = poweri1 + i1;
% [~,i3]=min(abs(timevec - (timevec(end)/2)));
% [~,i4]=min(abs(timevec - timevec(end)));
% i4=i4-1;
% [~,poweri2]=min(tsc.cmdThrReleaseSpeeds.Data(i3:i4).*ten(i3:i4));
% poweri2 = poweri2 + i3;
% % Manual Override. Rerun with this to choose times
% %           t1 = input("time for first measurement");
% %             [~,poweri1]=min(abs(timevec - t1));
% %             t2 = input("time for second measurement");
% %             [~,poweri2]=min(abs(timevec - t2));
% hold on
% ylims=ylim;
% plot([timevec(poweri1) timevec(poweri1)], [-1e6 1e6],'r--')
% plot([timevec(poweri2) timevec(poweri2)], [-1e6 1e6],'r--')
% ylim(ylims);
%  meanPower = mean(tsc.cmdThrReleaseSpeeds.Data(poweri1:poweri2).*ten(poweri1:poweri2));
% title(sprintf('Power vs Time; Average Power between lines = %4.2f Watts',meanPower));
% % 
% %%  Flow Speed PLOT
% 
% figure; 
% 
% plot(tsc.vhclFlowVecs.time, squeeze(tsc.vhclFlowVecs.data(:,5,:)))
% title('Flow Speed vs. Time ' ) 
% xlabel('Time (s) ' ) 
% ylabel('Flow Speed (m/s)') 
% legend(' U Velocity', 'V Velocity', 'W velocity')
% 
% %% Central Angle 
% 
% 
% figure; 
% 
% plot(tsc.vhclFlowVecs.time, tsc.central_angle.data)
% title('Central Angle vs. Time ' ) 
% xlabel('Time (s) ' ) 
% ylabel('Central Angle (rad)') 
% 
% 
% 




%%
% figure
% plot(vhcl.aeroSurf4.alpha.Value, vhcl.aeroSurf4.CL.Value)
% grid on 
% title('CL vs. Alpha') 
% ylabel('CL')
% xlabel('Alpha')
% figure
% plot(vhcl.aeroSurf4.alpha.Value, vhcl.aeroSurf4.CD.Value)
% grid on 
% title('CD vs. Alpha') 
% ylabel('CD')
% xlabel('Alpha')
% figure
% plot(vhcl.aeroSurf4.alpha.Value, (vhcl.aeroSurf4.CL.Value./vhcl.aeroSurf3.CD.Value))
% grid on 
% title('CL/CD vs. Alpha') 
% ylabel('CL/CD')
% xlabel('Alpha')
% 
% figure
% plot(vhcl.vStab.alpha.Value, vhcl.vStab.CL.Value)
% grid on 
% title('CL vs. Alpha') 
% ylabel('CL')
% xlabel('Alpha')
% xlim([-40,40])
% figure
% plot(vhcl.vStab.alpha.Value, vhcl.vStab.CD.Value)
% grid on 
% title('CD vs. Alpha') 
% ylabel('CD')
% xlabel('Alpha')
% xlim([-40,40])
% figure
% plot(vhcl.vStab.alpha.Value, (vhcl.vStab.CL.Value./vhcl.vStab.CD.Value))
% grid on 
% title('CL/CD vs. Alpha') 
% ylabel('CL/CD')
% xlabel('Alpha')
% xlim([-40,40])
%%


% 
% fprintf('\nRunning stopcallback.m \nParsing logsout\n')
% parseLogsout
% 
% % Create folder name to dump all results
% folderName = strcat('figure 8_',num2str(tetherLengths(ppp)),'_',num2str(10*flowSpeeds(qqq)))  %datestr(now,'ddmmmyy_HHMMSS');
% folderName = fullfile(fileparts(which('OCTModel')),'output',folderName);
% % If the folder doesn't exist, create it
% if ~(7==exist(fullfile(folderName),'dir'))
%     fprintf('Creating directory  %s\n',folderName)
%     mkdir(fullfile(folderName))
% end
% 
% % Save data
% fprintf('Saving all data to workspace.mat \n')
% save(fullfile(folderName,'workspace.mat'))
% 
% % Plot Everything
% fprintf('Running all plot script in ./scripts/plotScripts \n')
% plotEverything
% 
% % Get handles to all the figures
% fprintf('Saving all resulting plots. \n')
% saveAllPlots('Folder',folderName)
% fprintf('Done. \n')


     end
 end