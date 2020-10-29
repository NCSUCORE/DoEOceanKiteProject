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
simScenario = 1.2;
simScenariosub = (simScenario - floor(simScenario))*10
%%  Set Physical Test Parameters
thrLength = 3%[20 35 50];                         % m - Initial tether length
flwSpd = [0.25]%[0.25:.25:2];                             % m/s - Flow speed
elevation = 35  % elevation angle in degrees for tow controller
el = elevation*pi/180;                                 % rad - Mean elevation angle


if simScenario > 3 &&  simScenario < 4
ctrlPitch = 2; % Controller State 0 - Single Pitch 1 - Lookup Table 2 - Elevator Controller
end
desPitch = 0;%[0:2:16];                            % Desired Pitch in degrees

%Sim Time
simTime = 100

%Exit at SS
exit = 0

%Linearization Inputs
openLoop = 0 %1 = open loop linearization 0 = closed loop linearization
linCtrl = 0; %0 - Normal Control; 1 - Freeze Control inputs for linearization
linearize = 0;%0 - No linearization; 1 - Linearization turned on 
saveLin = 0% 1 to save,

%%Flow Perturbation Matrix
flowDirPert = [0]
stepTime = 150; %Time to rotate flow
rampSlope = 1/30; %slope of disturbance dist/s
%Controller Freeze
ctrlFreeze = 0; %Freeze Control Surface Deflections 0 = normal operation 1 = freeze @ ctrlFreezeTime
ctrlFreezeTime = stepTime-10; %Sim time to freeze control surface deflections

longloop = 0
latLoopPlot = 0
animate = 0

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
    if simScenario >= 3
        loadComponent('slCtrl');                         %   Launch and recovery controller
%         loadComponent('LaRController');                         %   Launch and recovery controller
    elseif simScenario == 2
        loadComponent('pathFollowingCtrlForILC');
    else
        loadComponent('pathFollowingCtrlForManta');             %   Path-following controller
    end
    loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
    loadComponent('pathFollowingGndStn');                       %   Ground station
    loadComponent('winchManta');                                %   Winches
    if simScenario >= 4
        minLinkDeviation = .1;
        minSoftLength = 0;
        minLinkLength = 1;                                      %   Length at which tether rediscretizes
        loadComponent('shortTether');                           %   Tether for reeling
    else
        loadComponent('MantaTether_38kN');                           %   Single link tether
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
    elseif simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
        loadComponent('Manta2RotXFlr_CFD_AR__ExpScale');                             %   Manta kite with XFoil
    elseif simScenario == 1.3 || simScenario == 3.3 || simScenario == 3.4 || simScenario == 4.3
        loadComponent('Manta2RotXFoil_AR8_b8_B4pct');                              %   Manta kite with XFlr5 
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
    gndStn.setPosVec([0 0 0],'m')
    gndStn.setVelVec([0 0 0],'m/s')
    gndStn.initAngPos.setValue(0,'rad');
    gndStn.initAngVel.setValue(0,'rad/s');
    %%  Vehicle Properties
    vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(env.water.flowVec.Value))
    if simScenario >= 3
        vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
        vhcl.setInitEulAng([0,desPitch(kk),0]*pi/180,'rad')
    end
    if simScenario == 0
        vhcl.turb1.setDiameter(0,'m')
    end
    %%  Tethers Properties
    thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
    thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%     thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
     thr.tether1.setDiameter(0.0076,thr.tether1.diameter.Unit);
    thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
    %%  Winches Properties
    wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
    wnch.winch1.LaRspeed.setValue(1,'m/s');
    %%  Controller User Def. Parameters and dependant properties
    fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
    fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
        hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
    if simScenario ~= 2
        fltCtrl.setFirstSpoolLap(1000,'');
        fltCtrl.elevCtrl.kp.SetValue(
    end
    fltCtrl.rudderGain.setValue(0,'')
    if simScenario == 1.1
        fltCtrl.setElevatorReelInDef(-2,'deg')
    else
        fltCtrl.setElevatorReelInDef(0,'deg')
    end
    fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
    if simScenario >= 3 && simScenario < 4
        fltCtrl.LaRelevationSP.setValue(elevation,'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
        fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller
        fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
        fltCtrl.setNomSpoolSpeed(.25,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
        wnch.winch1.elevError.setValue(2,'deg');
        vhcl.turb1.setPowerCoeff(0,'');
%         fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)'); fltCtrl.rollMoment.kd.setValue(0,'(N*m)/(rad/s)');
        fltCtrl.pitchConst.setValue(desPitch(kk),'deg');
        fltCtrl.pitchCtrl.setValue(ctrlPitch,'');
        fltCtrl.initCtrlVec;
        fltCtrl.alrnCmd.kp.setValue(0,'(deg)/(rad)');
        fltCtrl.alrnCmd.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.alrnCmd.kd.setValue(0,'(deg)/(rad/s)');
        fltCtrl.alrnCmd.tau.setValue(.1,'s');
        fltCtrl.rudderCmd.kp.setValue(1000,'(deg)/(rad)');
        fltCtrl.rudderCmd.ki.setValue(100,'(deg)/(rad*s)');
        fltCtrl.rudderCmd.kd.setValue(1000,'(deg)/(rad/s)');
        fltCtrl.rudderCmd.tau.setValue(.1,'s');
        fltCtrl.yawSP.kp.setValue(3,'(deg)/(deg)');
        fltCtrl.yawSP.ki.setValue(0.05,'(deg)/(deg*s)');
        fltCtrl.yawSP.kd.setValue(0,'(deg)/(deg/s)');
        fltCtrl.yawSP.tau.setValue(.01,'s');
        fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)')
%         fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');
%         fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
        fltCtrl.setNomSpoolSpeed(0,'m/s');
    end
           
%     fltCtrl.rollMoment.kp.setValue(0,'(N*m)/(rad)'); fltCtrl.rollMoment.kd.setValue(0,'(N*m)/(rad/s)'); 
    thr.tether1.dragEnable.setValue(1,'');
    % vhcl.rBridle_LE.setValue([0,0,0]','m');

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
    
plotCtrlDeflections
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
%  Plot Results
% close all
% if simScenario < 3 && simScenario ~= 2
%     tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'plotBeta',1==0,'lapNum',max(tsc.lapNumS.Data)-1)
% else
%     tsc.plotLaR(fltCtrl);
% end
% figure
% tsc.azimuthAngle.plot
% figure
% tsc.eul.plot

% figure
% plotLateral
% % figure
% plotLong
% plotGroundAngles
% plotCtrlDeflections
if animate == 1
vhcl.animateSim(tsc,2,...
    'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
    'ZoomIn',1==0,'SaveGIF',true,'GifFile','animation.gif');
end

% A = linsys.ss.A
% B = linsys.ss.B
% [n,q] = size(B)
% for i = 1:n
%     if i == 1
%         test(:,1:i*q)=B;
%     else
%         test(:,(i-1)*q+1:i*q)=A^(i-1)*B;
%     end
% end
% pass = rank(test)
