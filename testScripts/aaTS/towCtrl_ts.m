%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;close all
%%  Select sim scenario
%   3 = Stationary Ground Frame
%   2 = Moving Ground Frame
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);
simScenario = 2;
% Simulation Time
simTime = 600;
%%  Configure Test
thrLength = 20;%[20 35 50];                         % m - Initial tether length
flwSpd = 1e-5;%[0.25:.25:2];                             % m/s - Flow speed
craftSpeed = -0.5% Moving Ground Station Velocity Magnitude m/s
elevation =  30%[0:10:80];  % elevation angle in degrees for tow controller
yaw = 0; %Moving Ground Station Turning Angle deg
flowDirPert = 0;
saveim = 0; %0 - dont save images 1 - save images

%Pitch Control
if simScenario > 2 &&  simScenario < 4
    ctrlPitch = 2; % Controller State 0 - Single Pitch 1 - Lookup Table 2 - Elevator Controller
end
desPitch = 2;%[-8:4:8];   % Desired Pitch in degrees
%Exit Simulation at SS
exit = 0; %0 run for time 1 - exit at SS

%%Flow Perturbation Matrix
stepTime = 150; %Time to rotate flow
rampSlope = 1/30; %slope of disturbance dist/s

%Plot long/lat response over loop
longloop = 0;
latLoopPlot = 0;

%Animate simulation
animate = 0;


for ll = 1:length(yaw)
    el = elevation*pi/180;                                 % rad - Mean elevation angle
    % rDes(mm)
    
    %Ground Station Trajectory
    time = [0 150 165 180 195 210 215 63300  633000];
    vel = craftSpeed*[1 1 1 1 1 1 1 1 1;...
        0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0]';
    angVel = [0 0 0 0 0 0 0 0 0;...
        0 0 0 0 0 0 0 0 0;...
        %     0 0 0 0 0 0 0 0 0]';
        0 0 yaw(ll)/15*pi/180 0 0 0 0 0 0]';
    spiral = 1; %1 for prescribed control 2 for spiral transit
    
    
    %% Initialize Simulation
    %%Flow Disturbance
    
    flowAngle =[0 0 flowDirPert]; %degrees
    flowDir = flowAngle*pi/180; % rotation direction of flow about body z degrees
    
    %%  Load components
    
    %     loadComponent('LaRController');
    loadComponent('slCtrl');
    loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
    if simScenario >= 2 && simScenario < 3
        loadComponent('prescribedGndStn001')
        gndStn.pathVar.setValue(spiral,'')
    else
        loadComponent('pathFollowingGndStn');                       %   Ground station
    end
    loadComponent('winchManta');                                %   Winches
    loadComponent('mantaTether');                           %   Single link tether
end
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8'); 
%%  Environment Properties
loadComponent('constXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');               %   m/s - Flow speed vector
ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines
%%  Set basis parameters for high level controller
loadComponent('constBoothLem');                             %   High level controller
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
if simScenario == 2
    gndStn.setVelVecTrajectory(vel,time,'m/s');
    gndStn.setAngVelTrajectory(angVel,time,'rad/s');
    gndStn.setInitPosVecGnd([0 0 0],'m');
    gndStn.setInitEulAng([0 0 0]*pi/180,'rad')
else
    gndStn.setPosVec([0 0 0],'m');
    gndStn.setVelVec([0 0 0],'m/s');
    gndStn.initAngPos.setValue(0,'rad');
    gndStn.initAngVel.setValue(0,'rad/s');
end
%%  Vehicle Properties
if simScenario < 3 && simScenario >= 2
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.initPosVecGnd.Value,0);
    vhcl.setInitEulAng([0 0 0]*pi/180,'rad');
    vhcl.setInitVelVecBdy([craftSpeed 0 0],'m/s')
else
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0);
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad');
end
%%  Tethers Properties
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
Tmax = 38;
if simScenario < 3 && simScenario >= 2
    thr.tether1.initGndNodePos.setValue(gndStn.thrAttach.posVec.Value(:)+gndStn.initPosVecGnd.Value(:),'m');
else
    thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
end
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([craftSpeed 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(eval(sprintf('AR8b8.length600.tensionValues%d.outerDiam',Tmax)),'m');
%                             vhcl.setRBridle_LE([vhcl.rCM_LE.Value(1)-.2;0;-vhcl.fuse.diameter.Value/2],'m');
%%  Winches Properties
if simScenario >= 2 && simScenario < 3
    wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value,env,thr,env.water.flowVec.Value);
else
    wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
end
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
if simScenario >= 2 && simScenario <3
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
        hiLvlCtrl.basisParams.Value,gndStn.initPosVecGnd.Value);
else
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
        hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
end
if simScenario ~= 2
    fltCtrl.setFirstSpoolLap(1000,'');
end
fltCtrl.rudderGain.setValue(0,'')
if simScenario == 1.1
    fltCtrl.setElevatorReelInDef(-2,'deg')
else
    fltCtrl.setElevatorReelInDef(0,'deg')
end
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
if simScenario >= 2 && simScenario < 4
    fltCtrl.LaRelevationSP.setValue(elevation,'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
    fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller
    fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
    fltCtrl.setNomSpoolSpeed(0,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
    wnch.winch1.elevError.setValue(2,'deg');
%     vhcl.turb1.setPowerCoeff(0,'');
    fltCtrl.initCtrlVec;
end
if simScenario >= 2 && ~isequal(FLIGHTCONTROLLER,'LaRController')
    fltCtrl.rudderCmd.kp.setValue(60,'(deg)/(rad)');
    fltCtrl.rudderCmd.ki.setValue(.1,'(deg)/(rad*s)');
%     fltCtrl.rudderCmd.kd.setValue(0,'(deg)/(rad/s)');
%     
    fltCtrl.rollSP.kp.setValue(2,'(deg)/(deg)');
    fltCtrl.rollSP.ki.setValue(.1,'(deg)/(deg*s)');
%     fltCtrl.rollSP.kd.setValue(0,'(deg)/(deg/s)');
%     
    fltCtrl.alrnCmd.kp.setValue(0,'(deg)/(rad)');
    fltCtrl.alrnCmd.ki.setValue(0,'(deg)/(rad*s)');
    fltCtrl.alrnCmd.kd.setValue(0,'(deg)/(rad/s)');
%     
%     vhcl.portWing.setGainCL(vhcl.portWing.gainCL.Value*4,'1/deg');
%     vhcl.portWing.setGainCD(vhcl.portWing.gainCD.Value*4,'1/deg');
%     vhcl.stbdWing.setGainCL(vhcl.stbdWing.gainCL.Value*4,'1/deg');
%     vhcl.stbdWing.setGainCD(vhcl.stbdWing.gainCD.Value*4,'1/deg');
%     
%     fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)')
%     fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)')
%     fltCtrl.elevCmd.kd.setValue(0,'(deg)/(rad/s)')
    fltCtrl.towCtrlStrat.setValue('yawAz','')
end
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(simTime,'s');  dynamicCalc = '';
%Turn on elevator control
fprintf('Simulating')
trimCtrl=[0 0 0 0];
simWithMonitor('OCTModel')
% simWithMonitor('OCTModel_for_lin')
tsc = signalcontainer(logsout);
% plotCtrlDeflections;
% fig = get(groot,'CurrentFigure');
% filepath = fullfile(fileparts(which('OCTProject.prj')),'output\Manta\');
% filename = sprintf('%del%dturn',elevation(l),yaw(ll));
% if saveim == 1
%     saveas(fig,[filepath filename '.png']);
%     saveplot = true;
% else
%     saveplot = false;
% end
% if saveim == 1
%     close all
% end
%% Lateral Plot Loop
if latLoopPlot == 1
    subplot(3,3,1); hold on; grid on;
    plot(tsc.velocityVec.Time/sqrt(lenScale(mm)),squeeze(tsc.velocityVec.Data(2,:,:)/sqrt(lenScale(mm))),...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, Psi = %d deg, V_flow = %.2f',thrLength(jj),desPitch(kk),flwSpd(ii)))
    xlabel('Time')
    ylabel('Body-Y Velocity')
    %legend('Location','southwest','FontSize',16)
    
    subplot(3,3,2); hold on; grid on;
    plot(tsc.positionVec.Time/sqrt(lenScale(mm)),squeeze(tsc.positionVec.Data(2,:,:)/lenScale(mm)),...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time')
    ylabel('Ground-Y Position')
    
    subplot(3,3,4); hold on; grid on;
    plot(tsc.angularVel.Time/sqrt(lenScale(mm)),squeeze(tsc.angularVel.Data(1,:,:))*180/pi*sqrt(lenScale(mm)),...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time')
    ylabel('Roll Rate [deg]')
    
    subplot(3,3,5); hold on; grid on;
    plot(tsc.eulerAngles.Time/sqrt(lenScale(mm)),squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time')
    ylabel('Roll Angle [deg]')
    
    subplot(3,3,7); hold on; grid on;
    plot(tsc.angularVel.Time/sqrt(lenScale(mm)),squeeze(tsc.angularVel.Data(3,:,:))*180/pi*sqrt(lenScale(mm)),...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time')
    ylabel('Yaw Rate')
    
    subplot(3,3,8); hold on; grid on;
    plot(tsc.eulerAngles.Time/sqrt(lenScale(mm)),squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time, [s]')
    ylabel('Yaw Angle [deg]')
    
    
    
    
    subplot(3,3,[3 6 9]); hold on; grid on;
    axis off;
    plot(0,0,'LineWidth',0.5,'DisplayName',...
        sprintf('Length Scale = %.2f',...
        lenScale(mm)))
    legend('Location','west','FontSize',16)
    
    set(findall(gcf,'Type','axes'),'FontSize',20)
    linkaxes(findall(gcf,'Type','axes'),'x')
end
%     close all
%% Longitudinal Plot Loop
if longloop == 1
    
    subplot(3,2,1); hold on; grid on;
    plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(1,:,:)),...
        'LineWidth',0.5,'DisplayName',sprintf('Tether Length = %d m',thrLength(jj)))
    xlabel('Time, [s]')
    ylabel('Body-X Velocity [m/s]')
    legend('Location','southwest')
    
    subplot(3,2,2); hold on; grid on;
    plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(1,:,:)),...
        'LineWidth',0.5,'DisplayName',sprintf('Tether Length = %d m',thrLength(jj)))
    xlabel('Time, [s]')
    ylabel('Ground-X Position [m]')
    
    subplot(3,2,3); hold on; grid on;
    plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(3,:,:)),...
        'LineWidth',0.5,'DisplayName',sprintf('Tether Length = %d m',thrLength(jj)))
    xlabel('Time, [s]')
    ylabel('Body-Z Velocity [m/s]')
    
    subplot(3,2,4); hold on; grid on;
    plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(3,:,:)),...
        'LineWidth',0.5,'DisplayName',sprintf('Tether Length = %d m',thrLength(jj)))
    xlabel('Time, [s]')
    ylabel('Ground-Z Position [m]')
    
    subplot(3,2,5); hold on; grid on;
    plot(tsc.angularVel.Time,squeeze(tsc.angularVel.Data(2,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('Tether Length = %d m',thrLength(jj)))
    xlabel('Time, [s]')
    ylabel('Pitch Rate [deg/s]')
    
    subplot(3,2,6); hold on; grid on;
    plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(2,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('Tether Length = %d m',thrLength(jj)))
    xlabel('Time, [s]')
    ylabel('Pitch Angle [deg]')
    
    set(findall(gcf,'Type','axes'),'FontSize',20)
    linkaxes(findall(gcf,'Type','axes'),'x')
    close all
end

%% ANIMATE
plotCtrlDeflections
if animate == 1
    vhcl.animateSim(tsc,2,...
        'GifTimeStep',1,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
        'ZoomInMove',true,'SaveGIF',true,'GifFile','animation.gif',...
        'View',[0,90]);
    vhcl.animateSim(tsc,2,...
        'GifTimeStep',1,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
        'ZoomInMove',false,'SaveGIF',true,'GifFile','animation.gif',...
        'View',[30,30]);
end

