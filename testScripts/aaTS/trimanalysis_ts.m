%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;close all
%%  Select sim scenario
%   0 = fig8;
%   1 = fig8-2rot DOE-M;  1.1 = fig8-2rot AVL;  1.2 = fig8-2rot XFoil;  1.3 = fig8-2rot XFlr5;
%   2 = fig8-winch DOE;
%   3 = steady Old;       3.1 = steady AVL;     3.2 = steady XFoil      3.3 = Steady XFlr5      3.4 = Steady XFlr5 Passive ;
%   4 = LaR Old;          4.1 = LaR AVL;        4.2 = LaR XFoil;        4.3 = LaR XFlr5 
h = 10*pi/180;  w = 40*pi/180;                     % rad - Path width/height
[a,b] = boothParamConversion(w,h);                 % Build Path
simScenario = 2.3;
simScenariosub = (simScenario - floor(simScenario))*10
%%  Set Physical Test Parameters
thrLength = 20;%[20 35 50];                         % m - Initial tether length
flwSpd = [1e-30];%[0.25:.25:2];                             % m/s - Flow speed
elevation = [20];  % elevation angle in degrees for tow controller
yaw = 20;
flowDirPert = [0];
saveim = 0;
craftSpeed = -1.54;

for l = 1:length(elevation)
    for ll = 1:length(yaw)
el = elevation(l)*pi/180;                                 % rad - Mean elevation angle


if simScenario > 2 &&  simScenario < 4
ctrlPitch = 2; % Controller State 0 - Single Pitch 1 - Lookup Table 2 - Elevator Controller
end
desPitch = 0;%[0:2:16];                            % Desired Pitch in degrees

%Sim Time
simTime = 600

%Exit at SS
exit = 0

%Linearization Inputs
openLoop = 0 %1 = open loop linearization 0 = closed loop linearization
linCtrl = 0; %0 - Normal Control; 1 - Freeze Control inputs for linearization
linearize = 0;%0 - No linearization; 1 - Linearization turned on 
saveLin = 0;% 1 to save,

%%Flow Perturbation Matrix
stepTime = 150; %Time to rotate flow
rampSlope = 1/30; %slope of disturbance dist/s
%Controller Freeze
ctrlFreeze = 0; %Freeze Control Surface Deflections 0 = normal operation 1 = freeze @ ctrlFreezeTime
ctrlFreezeTime = stepTime-10; %Sim time to freeze control surface deflections

%Ground Station Trajectory
time = [0 150 165 180 195 210 215 63300  633000];
vel = craftSpeed*[1 1 1 1 1 1 1 1 1;...
    0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0]';
angVel = [0 0 0 0 0 0 0 0 0;...
    0 0 0 0 0 0 0 0 0;...
%     0 0 0 0 0 0 0 0 0]';
    0 0 yaw(ll)/15*pi/180 0 0 0 0 0 0]';

longloop = 0;
latLoopPlot = 0;
animate = 0;

if longloop == 1 || latLoopPlot == 1
figure
subplot(3,2,1);
end
%% Initialize Simulation
for qq = 1:numel(flowDirPert)
    %%Flow Disturbance
    
    flowAngle =[0 0 flowDirPert(qq)]; %degrees
    flowDir = flowAngle*pi/180 % rotation direction of flow about body z degrees

for kk = 1:numel(desPitch)
for jj = 1:numel(thrLength)
for ii =1:numel(flwSpd)
    linCtrl = 0; %0 - Normal Control; 1 - Controller Manipulation
    %%  Load components
    if simScenario >= 3 || simScenario == 2.3
        loadComponent('slCtrl');                         %   Launch and recovery controller
%         loadComponent('LaRController');                         %   Launch and recovery controller
    elseif simScenario == 2
        loadComponent('pathFollowingCtrlForILC');
    else
        loadComponent('pathFollowWithAoACtrl');             %   Path-following controller
    end
    loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
    if simScenario > 2 && simScenario < 3
        loadComponent('prescribedGndStn001')
%         gndStn.pathVar.setValue(2,'')
    else
        loadComponent('pathFollowingGndStn');                       %   Ground station
    end
    loadComponent('winchManta');                                %   Winches
    if simScenario >= 4
        minLinkDeviation = .1;
        minSoftLength = 0;
        minLinkLength = 1;                                      %   Length at which tether rediscretizes
        loadComponent('shortTether');                           %   Tether for reeling
    else
%         loadComponent('shortTether');                           %   Tether for reeling        
        loadComponent('MantaTether');                           %   Single link tether
    end
    loadComponent('idealSensors')                               %   Sensors
    loadComponent('idealSensorProcessing')                      %   Sensor processing
    
    if simScenario == 0
        loadComponent('MantaKiteAVL_DOE');                                  %   Manta kite old
    elseif simScenario == 2
        loadComponent('fullScale1thr');                                     %   DOE kite 
    elseif simScenario == 1 || simScenario == 3 || simScenario == 4
        loadComponent('Manta2RotAVL_DOE');                                  %   Manta DOE kite with AVL 
    elseif simScenario == 1.1 || simScenario == 3.1 || simScenario == 4.1
        loadComponent('Manta2RotAVL_Thr075');                               %   Manta kite with AVL
    elseif simScenario == 1.2 || simScenario == 2.2 || simScenario == 3.2 || simScenario == 4.2
        loadComponent('Manta2RotXFoil_AR8_b8_expt');                             %   Manta kite with XFoil
        vhcl.scale(.1,1);
        vhcl.turb1.setDiameter(0,'m');
        vhcl.turb2.setDiameter(0,'m');
        vhcl.setBuoyFactor(1,'');
    elseif simScenario == 1.3 || simScenario == 2.3 || simScenario == 3.3 || simScenario == 3.4 || simScenario == 4.3
        loadComponent('Manta2RotXFoil_AR8_b8');                              %   Manta kite with XFlr5 
    end
    %%  Environment Properties
    loadComponent('constXYZT');                                 %   Environment
    env.water.setflowVec([flwSpd(ii) 0 0],'m/s');               %   m/s - Flow speed vector
    if simScenario == 0
        ENVIRONMENT = 'environmentManta';                       %   Single turbine
    elseif simScenario == 2
        ENVIRONMENT = 'environmentDOE';                         %   No turbines
    else
        ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines
    end
    %%  Set basis parameters for high level controller
    loadComponent('constBoothLem');                             %   High level controller
    if strcmpi(PATHGEOMETRY,'ellipse')
        hiLvlCtrl.basisParams.setValue([w,h,el,0*pi/180,thrLength(jj)],'[rad rad rad rad m]') % Ellipse
    else
        hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength(jj)],'[rad rad rad rad m]') % Lemniscate of Booth
    end
    %%  Ground Station Properties
    if simScenario == 2.3
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
    if simScenario < 3 && simScenario > 2
        vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.initPosVecGnd.Value,0);
            vhcl.setInitEulAng([0 0 0]*pi/180,'rad');
    elseif simScenario > 3
        vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0);
        vhcl.setInitEulAng([0,desPitch(kk),0]*pi/180,'rad');
    else
        vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))
    end
    if simScenario == 0
        vhcl.turb1.setDiameter(0,'m')
    end
    %%  Tethers Properties
    if simScenario < 3 && simScenario > 2
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttach.posVec.Value(:)+gndStn.initPosVecGnd.Value(:),'m');
    else
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
    end
    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
    thr.tether1.initGndNodeVel.setValue([2 0 0]','m/s');
    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
    if simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
        thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
        thr.tether1.setDiameter(0.0076,thr.tether1.diameter.Unit);
    end
    thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
    %%  Winches Properties
    if simScenario >2 && simScenario < 3
        wnch.setTetherInitLength(vhcl,gndStn.initPosVecGnd.Value,env,thr,env.water.flowVec.Value);
    else
        wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
    end
    wnch.winch1.LaRspeed.setValue(1,'m/s');
    %%  Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
    if simScenario > 2 && simScenario <3
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
        fltCtrl.LaRelevationSP.setValue(elevation(l),'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
        fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller
        fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
        fltCtrl.setNomSpoolSpeed(0,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
        wnch.winch1.elevError.setValue(2,'deg');
        vhcl.turb1.setPowerCoeff(0,'');
        fltCtrl.initCtrlVec;
        fltCtrl.pitchCtrl.setValue(ctrlPitch,'')
        fltCtrl.pitchConst.setValue(desPitch,'deg')
    end
    if simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
%         fltCtrl.rollMoment.kp.setValue(21,'(N*m)/(rad)');
%         fltCtrl.rollMoment.kd.setValue(191,'(N*m)/(rad/s)');
    end 
    fltCtrl.rudderCmd.kp.setValue(10,'(deg)/(rad)');
    fltCtrl.rudderCmd.ki.setValue(0,'(deg)/(rad*s)');
    fltCtrl.rudderCmd.kd.setValue(1,'(deg)/(rad/s)');

    fltCtrl.rollSP.kp.setValue(3,'(deg)/(deg)');
    fltCtrl.rollSP.ki.setValue(.05,'(deg)/(deg*s)');
    fltCtrl.rollSP.kd.setValue(6,'(deg)/(deg/s)');

    fltCtrl.alrnCmd.kp.setValue(5,'(deg)/(rad)');   
    fltCtrl.alrnCmd.ki.setValue(.08,'(deg)/(rad*s)');
    fltCtrl.alrnCmd.kd.setValue(5,'(deg)/(rad/s)');
%     thr.tether1.dragEnable.setValue(1,'');
%%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(simTime,'s');  dynamicCalc = '';
    %Turn on elevator control
    fprintf('Simulating')
    trimCtrl=[0 0 0 0];
if linearize == 0
%     set_param(bdroot,'SimulationMode','accelerator')
%     simWithMonitor('OCTModel')
    simWithMonitor('OCTModel_for_lin')
    tsc = signalcontainer(logsout);
end
%%
    if linearize == 1
        set_param(bdroot,'SimulationMode','accelerator')
        sim('OCTModel_for_lin')
        tsc = signalcontainer(logsout);
        if openLoop == 1
            linCtrl = 1;
        end
        linState = 1;
            set_param(bdroot,'SimulationMode','normal')
        %Get control inputs at steady state
        len = tsc.azimuthAngle.Length
        trimCtrl = tsc.ctrlSurfDeflCmd.getsamples(len).Data;
        set_param(bdroot,'SimulationCommand','Update')
        fprintf('Linearizing')
        [A,B,C,D] = linmod('OCTModel_for_lin',xFinal,[0 0 0 0 0]);
        sys = ss(A,B,C,D);
        linsys.ss = sys;
        linsys.title = sprintf('Flow Speed %.2f m/s Tether Length %d m Pitch SP %d',...
            flwSpd(ii), thrLength(jj), desPitch(kk));
        linsys.timeseries = tsc;
        linsys.xFinal = xFinal
        varNam = sprintf('%d_%d_%d.mat',100*flwSpd(ii),thrLength(jj),desPitch(kk));
        if saveLin == 1
            save(varNam,'linsys')
            clear linsys
        end
        
        clear trimCtrl
    end
len = length(tsc.airTenVecs.Time);
thrTen(l,ll) = tsc.airTenVecs.getsamples(len).mag.Data;  
plotCtrlDeflections;
fig = get(groot,'CurrentFigure');
filepath = fullfile(fileparts(which('OCTProject.prj')),'output\Manta\');
filename = sprintf('%del%dturnstop',elevation(l),yaw(ll));
if saveim == 1
    saveas(fig,[filepath filename '.png']);
    save = true;
else
    save = false;
end
% vhcl.animateSim(tsc,2,...
%     'GifTimeStep',.001,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%     'ZoomInMove',true,'SaveGIF',true,'GifFile',[filename 'outtop.gif'],...
%     'View',[0,90],'startTime',100,'GifPath',filepath,'timeStep',5,'tracerDuration',7200);
% vhcl.animateSim(tsc,2,...
%     'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%     'ZoomInMove',true,'SaveGIF',save,'GifFile',[filename 'side.gif'],...
%     'View',[0,0],'startTime',100,'GifPath',filepath);
% vhcl.animateSim(tsc,2,...
%     'GifTimeStep',.01,'PlotTracer',false,'FontSize',12,'Pause',1==0,...
%     'ZoomInMove',true,'SaveGIF',save,'GifFile',[filename 'obliquestop.gif'],...
%     'View',[30,30],'startTime',100,'timeStep',5,'GifPath',filepath,'tracerDuration',100);

% figure
% plot(elevation,thrTen,'sr','DisplayName','Total Tension');
% grid on; hold on;
% plot(elevation,thrTen.*sin(elevation*pi/180),'xb','DisplayName','Vertical Component')
% plot(elevation,thrTen.*cos(elevation*pi/180),'ok','DisplayName','Horizontal Component')
% xlabel('Elevation Angle [deg]')
% ylabel('Tether Tension [N]')
% legend('Location','northwest')
% title({'Tether Tension vs Elevation Angle',...
%     'Glider Speed = 3 knots, Tether Length = 20 m'})

if saveim == 1
    close all
end
    %% Lateral Plot Loop
if latLoopPlot == 1
    subplot(3,3,1); hold on; grid on;
    plot(tsc.velocityVec.Time,squeeze(tsc.velocityVec.Data(2,:,:)),...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, Psi = %d deg, V_flow = %.2f',thrLength(jj),desPitch(kk),flwSpd(ii)))
    xlabel('Time, [s]')
    ylabel('Body-Y Velocity [m/s]')
    %legend('Location','southwest','FontSize',16)

    subplot(3,3,2); hold on; grid on;
    plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(2,:,:)),...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time, [s]')
    ylabel('Ground-Y Position [m]')
    
    subplot(3,3,4); hold on; grid on;
    plot(tsc.angularVel.Time,squeeze(tsc.angularVel.Data(1,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time, [s]')
    ylabel('Roll Rate [deg/s]')

    subplot(3,3,5); hold on; grid on;
    plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time, [s]')
    ylabel('Roll Angle [deg]')
    
    subplot(3,3,7); hold on; grid on;
    plot(tsc.angularVel.Time,squeeze(tsc.angularVel.Data(3,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time, [s]')
    ylabel('Yaw Rate [deg/s]')
       
    subplot(3,3,8); hold on; grid on;
    plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(3,:,:))*180/pi,...
        'LineWidth',0.5,'DisplayName',sprintf('L = %d m, $\Psi$ = %d deg',thrLength(jj),desPitch(kk)))
    xlabel('Time, [s]')
    ylabel('Yaw Angle [deg]')

    

    
    subplot(3,3,[3 6 9]); hold on; grid on;
    axis off;
    plot(0,0,'LineWidth',0.5,'DisplayName',...
        sprintf('L = %d m, Pitch = %d deg, Flow Velocity = %.2f m/s',...
        thrLength(jj),desPitch(kk),flwSpd(ii)))
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
    end
end
end
end
end
    end
end

% figure
% plotLateral
% % figure
% plotLong
% plotGroundAngles
% plotCtrlDeflections
if animate == 1
vhcl.animateSim(tsc,2,...
    'GifTimeStep',1,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
    'ZoomInMove',true,'SaveGIF',true,'GifFile','animation.gif',...
    'View',[0,90]);
vhcl.animateSim(tsc,2,...
    'GifTimeStep',1,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
    'ZoomInMove',true,'SaveGIF',true,'GifFile','animation.gif',...
    'View',[0,90],'LocalAero',true);
end

[x,y] = meshgrid(elevation,yaw)

% figure
% surf(x',y',thrTen);
% grid on; hold on;
% % plot(elevation,thrTen.*sin(elevation*pi/180),'xb','DisplayName','Vertical Component')
% % plot(elevation,thrTen.*cos(elevation*pi/180),'ok','DisplayName','Horizontal Component')
% xlabel('Elevation Angle [deg]')
% ylabel('Yaw Angle [deg]')
% zlabel('Tether Tension [N]')
% % legend('Location','northwest')
% title({'Tether Tension vs Elevation Angle',...
%     'Glider Speed = 3 knots, Tether Length = 20 m'})
% 
% figure
% grid on; hold on;
% for i = 1:length(yaw)
%     plot(elevation(1:end-2),thrTen(1:end-2,i))
% end

% figure;
% hold on; grid on;
% plot(tsc.ki.Time,squeeze(tsc.ki.Data),'r')
% plot(tsc.ki.Time,squeeze(tsc.kp.Data),'g')
% plot(tsc.ki.Time,squeeze(tsc.kd.Data))
% legend

