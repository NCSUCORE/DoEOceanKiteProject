%% Test script for pool test simulation of the kite model
% clear;clc;close all;
clc
close all
Simulink.sdi.clear
clear tsc1
distFreq = 0;distAmp = 0;pertVec = [0 1 0];
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
inc =-2;
elevArray = 20*pi/180%[40 15]*pi/180;
towArray = [0.93];
rCM = 1
thrLength = 2.63;
flwSpd = -1e-9;
for q = 2
    for i = 1:length(inc)
        i
        for j = 1:length(towArray)
            j
            for k = 1:numel(rCM)
                tic
                Simulink.sdi.clear
                h = 25*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
                [a,b] = boothParamConversion(w,h);                          %   Path basis parameters
                %%  Load components
                el = elevArray;
                if q ~= 3
                    %             loadComponent('exp_slCtrl');
                    loadComponent('periodicCtrlExp');
                    %             fltCtrl.ctrlOff.setValue(0,'')
                else%
                    loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
                    FLIGHTCONTROLLER = 'pathFollowingControllerExp';
                end
                loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller                           %   Ground station
                loadComponent('raftGroundStation');
                loadComponent('winchManta');                                %   Winches
                loadComponent('MantaTether');                               %   Manta Ray tether
                loadComponent('realisticSensors');                             %   Sensors
                loadComponent('lineAngleSensor');
                loadComponent('idealSensorProcessing');                      %   Sensor processing
                loadComponent('poolScaleKiteAbney');                %   AR = 8; 8m span
                SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
                %%  Environment Properties
                loadComponent('ConstXYZT');                                 %   Environment
                env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
                ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
                %%  Set basis parameters for high level controller
                
                loadComponent('constBoothLem');        %   High level controller
                % PATHGEOMETRY = 'lemOfBoothInv'
                hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
                las.setThrInitAng([-el 0],'rad');
                las.setInitAngVel([-0 0],'rad/s');
                %             las.tetherLoadDisable;
                %             las.dragDisable;
                %%  Ground Station Properties
                %% Set up pool raft parameters
                theta = 30*pi/180;
                T_tether = 100; %N
                phi_max = 30*pi/180;
                omega_kite = 2*pi/5; %rad/s
                m_raft = 50; %kg
                J_raft = 30;
                tow_length = 16;
                tow_speed = towArray(j);
                end_time = tow_length/tow_speed;
                x_init = 4;
                y_init = 0;
                y_dot_init = 0;
                psi_init = 0;
                psi_dot_init = 0;
                initGndStnPos = [x_init;y_init;0];
                thrAttachInit = initGndStnPos;
                %%  Vehicle Properties
                vhcl.stbdWing.setGainCL(vhcl.stbdWing.gainCL.Value/4,'1/deg');
                vhcl.portWing.setGainCL(vhcl.portWing.gainCL.Value/4,'1/deg');
                vhcl.stbdWing.setGainCD(vhcl.stbdWing.gainCD.Value/4,'1/deg');
                vhcl.portWing.setGainCD(vhcl.portWing.gainCD.Value/4,'1/deg');
                if q == 3
                    vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
                else
                    vhcl.setICsOnPath(0.0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
                    vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
                    %             vhcl.setInitEulAng([180 0 0]*pi/180,'rad');
                    vhcl.setInitVelVecBdy([0 0 0],'m/s');
                end

                %%  Tethers Properties
                load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
                thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
                thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
                x = thr.tether1.initGndNodePos.Value(1)-thr.tether1.initAirNodePos.Value(1);
                y = thr.tether1.initGndNodePos.Value(2)-thr.tether1.initAirNodePos.Value(2);
                z = thr.tether1.initGndNodePos.Value(3)-thr.tether1.initAirNodePos.Value(3);
                initThrAng = atan2(z,sqrt(x^2+y^2));
                
                las.setThrInitAng([-initThrAng 0],'rad');
                thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
                thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
                thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
                thr.tether1.youngsMod.setValue(50e9,'Pa');
                thr.tether1.density.setValue(1000,'kg/m^3');
                thr.tether1.setDiameter(.0076,'m');
                thr.setNumNodes(4,'');
                thr.tether1.setDragCoeff(1.8,'');
                %%  Winches Properties
                wnch.setTetherInitLength(vhcl,thrAttachInit,env,thr,env.water.flowVec.Value);
                wnch.winch1.LaRspeed.setValue(1,'m/s');
                %%  Controller User Def. Parameters and dependant properties
                fltCtrl.setFcnName(PATHGEOMETRY,'');
                fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,thrAttachInit);
                fltCtrl.setPerpErrorVal(.25,'rad')
                fltCtrl.rudderGain.setValue(0,'')
                fltCtrl.rollMoment.kp.setValue(100,'(N*m)/(rad)')
                fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
                fltCtrl.rollMoment.kd.setValue(55,'(N*m)/(rad/s)')
                fltCtrl.tanRoll.kp.setValue(.45,'(rad)/(rad)')
                thr.tether1.dragEnable.setValue(1,'')
                vhcl.hStab.setIncidence(0,'deg');
                if q == 3
                    vhcl.hStab.setIncidence(-4,'deg');
                end
                if q ~= 3
                    
                    fltCtrl.rollAmp.setValue(70,'deg');
                    fltCtrl.yawAmp.setValue(90,'deg');
                    fltCtrl.period.setValue(6,'s');
                    fltCtrl.rollPhase.setValue(pi,'rad');
                    fltCtrl.yawPhase.setValue(.693,'rad');
                    if q == 1
                        fltCtrl.startCtrl.setValue(42,'s')
                    else
                        fltCtrl.startCtrl.setValue(2,'s')
                    end
                    fltCtrl.rollCtrl.kp.setValue(0,'(deg)/(deg)');
                    fltCtrl.rollCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.rollCtrl.kd.setValue(0,'(deg)/(deg/s)');
                    fltCtrl.rollCtrl.tau.setValue(0.02,'s');
                    
                    fltCtrl.rollCtrl.kp.setValue(3,'(deg)/(deg)');
                    fltCtrl.rollCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.rollCtrl.kd.setValue(1,'(deg)/(deg/s)');
                    fltCtrl.rollCtrl.tau.setValue(0.02,'s');
                    
                    
                    fltCtrl.yawCtrl.kp.setValue(0,'(deg)/(deg)');
                    fltCtrl.yawCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.yawCtrl.kd.setValue(0,'(deg)/(deg/s)');
                    fltCtrl.yawCtrl.tau.setValue(0.00,'s');
                    
                    fltCtrl.yawCtrl.kp.setValue(1,'(deg)/(deg)');
                    fltCtrl.yawCtrl.ki.setValue(0,'(deg)/(deg*s)');
                    fltCtrl.yawCtrl.kd.setValue(0.7,'(deg)/(deg/s)');
                    fltCtrl.yawCtrl.tau.setValue(0.02,'s');
                    
                    fltCtrl.ccElevator.setValue(-2,'deg');
                    fltCtrl.trimElevator.setValue(inc(i),'deg');
                end
                %%  Set up critical system parameters and run simulation
                simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
                %     open_system('OCTModel')
                %     set_param('OCTModel','SimulationMode','accelerator');
                simWithMonitor('OCTModel')
                tsc1{i,j,k,q} = signalcontainer(logsout);
                tsc =  tsc1{i,j,k,q};
                %             figure
                %             plotsq(tsc1{1,1}.eulerAngles.Data(2,:,:)*180/pi)
                %                         vhcl.animateSim(tsc1{1,1},0.2,'GifTimeStep',0.2,'SaveGif',1==1)%,'View',[0 0])
                if q == 2
                    tsc = tsc1{i,j,k,q};
                    vel = tsc.velCMvec.Data;
                    Ten = tsc.gndNodeTenVecs.Data;
                    TenMag = sqrt(dot(Ten,Ten));
                    velMag = sqrt(dot(vel,vel));
                    figure
                    plotsq(tsc.velCMvec.Time,velMag/0.77);
                    xlabel 'Time [s]'
                    ylabel 'Velocity Augmentation [$|v_{kite}|/|v_{tow}|$]'
                    yyaxis('right')
                    plot(tsc.vhclAngleOfAttack)
                    ylim([0 15])
                    ylabel 'Vehicle Angle of Attack [deg]'
                    
                    figure
                    plotsq(tsc.velCMvec.Time,TenMag);
                    xlabel 'Time [s]'
                    ylabel 'Tether Tension [N]'
                    ylim([0 1000])
                    yyaxis('right')
                    plot(tsc.vhclAngleOfAttack)
                    ylim([0 15])
                    ylabel 'Vehicle Angle of Attack [deg]'
                    
                    figure; hold on;  grid on;
                    plotsq(tsc.eulerAngles.Time,tsc.eulerAngles.Data(1,:,:)*180/pi+180);
                    plotsq(tsc.eulerAngles.Time,tsc.eulerAngles.Data(3,:,:)*180/pi-180);
                    xlabel('Time [s]')
                    ylabel('Angle [deg]')
                    legend ('Roll','Yaw')
                    %                     [pksRoll,locRoll] = findpeaks(squeeze(tsc.eulerAngles.Data(1,:,:)*180/pi)+180);
                    %                     [pksYaw,locYaw] = findpeaks(squeeze(tsc.eulerAngles.Data(3,:,:)*180/pi)-180);
                    %                     period = tsc.alphaBdy.Time(locYaw(end))-tsc.alphaBdy.Time(locYaw(end-1))
                    %                     phase = 2*pi*((tsc.alphaBdy.Time(locYaw(end))-tsc.alphaBdy.Time(locRoll(end-2)))/period-1)
                    
                end
                % vhcl.animateSim(tsc1{i,j,k,q},0.2,'GifTimeStep',0.2,'SaveGif',1==1)%,'View',[0 0])
                
                if q == 2
                    vhcl.animateSim(tsc1{i,j,k,q},0.2,'GifTimeStep',0.2,'SaveGif',1==1)%,'View',[0 0])
                    
                    figure('Position',[100 100 700 250]); hold on; grid on;
                    plot(tsc1{i,j,k,q}.rollSP-180,'-b','LineWidth',1.5)
                    plot(tsc1{i,j,k,q}.rollDeg-180,'--b','LineWidth',1.5)
                    plot(tsc1{i,j,k,q}.yawSP-180,'-r','LineWidth',1.5)
                    plot(tsc1{i,j,k,q}.yawDeg-180,'--r','LineWidth',1.5)
                    legend('SP','Response')
                    ylabel 'Attitude [deg]'
                    xlabel 'Time [s]'
                    %                     title(sprintf('Cross Current Tracking - %.d Deg Elevator',-10))
                    legend('Roll SP','Roll','Yaw SP','Yaw','Orientation','horizontal')
                    set(gca,'FontSize',15)
                    ylim([-60 60])
                    
                    figure('Position',[100 100 700 250]); hold on; grid on;
                    plot(tsc1{i,j,k,q}.alSatDefl,'-b','LineWidth',1.5)
                    %             plot(tsc1{i}.ctrlSurfDefl.Time,tsc1{i}.ctrlSurfDefl.Data(:,2),'-g','LineWidth',1.5)
                    plot(tsc1{i,j,k,q}.elSatDefl,'-r','LineWidth',1.5)
                    plot(tsc1{i,j,k,q}.rudSatDefl,'-k','LineWidth',1.5)
                    legend('Aileron','Elevator','Rudder')
                    ylabel 'Attitude [deg]'
                    xlabel 'Time [s]'
                    title(sprintf('Cross Current Tracking - %.d Deg Elevator',3))
                    %             legend('Roll SP','Roll','Yaw SP','Yaw','Orientation','horizontal')
                    set(gca,'FontSize',15)
                    ylim([-30 30])
                end
                toc
            end
        end
    end
end

%,'View',[0 0])
% figure('Position',[100 100 700 250]); hold on; grid on;
% plot(tsc1{i}.rollSP,'-b','LineWidth',1.5)
% plot(tsc1{i}.rollDeg,'--b','LineWidth',1.5)
% plot(tsc1{i}.yawSP,'-r','LineWidth',1.5)
% plot(tsc1{i}.yawDeg,'--r','LineWidth',1.5)
% legend('SP','Response')
% ylabel 'Attitude [deg]'
% xlabel 'Time [s]'
% title 'Cross Current Tracking - Well Timed Initiation'
% legend('Roll SP','Roll','Yaw SP','Yaw','Orientation','horizontal')
% set(gca,'FontSize',15)
% ylim([50 350])

%% Process Test Data

%
% figure; hold on; grid on;
% plotsq(tsc1{1,1}.velCMvec.Time,sqrt(dot(tsc1{1,1}.velCMvec.Data,tsc1{1,1}.velCMvec.Data)))
% plotsq(tsc1{1,1}.velEst.Time,sqrt(dot(tsc1{1,1}.velEst.Data',tsc1{1,1}.velEst.Data')))
% ylim([0 2])
% legend('Velocity','Velocity Estimation')
%
% figure; hold on; grid on;
% subplot(3,1,1); hold on; grid on;
% plotsq(tsc1{1,1}.positionVec.Time,tsc1{1,1}.positionVec.Data(1,:,:))
% plotsq(tsc1{1,1}.positionVec.Time,tsc1{1,1}.posEst.Data(1,:,:))
% subplot(3,1,2); hold on; grid on;
% plotsq(tsc1{1,1}.positionVec.Time,tsc1{1,1}.positionVec.Data(2,:,:))
% plotsq(tsc1{1,1}.positionVec.Time,tsc1{1,1}.posEst.Data(2,:,:))
% subplot(3,1,3); hold on; grid on;
% plotsq(tsc1{1,1}.positionVec.Time,tsc1{1,1}.positionVec.Data(3,:,:))
% plotsq(tsc1{1,1}.positionVec.Time,tsc1{1,1}.posEst.Data(3,:,:))
% legend('Pos','Pos Estimation')
%
% figure; hold on; grid on;
% subplot(3,1,1); hold on; grid on;
% plotsq(tsc1{1,1}.velocityVec.Time,tsc1{1,1}.velocityVec.Data(1,:,:))
% plotsq(tsc1{1,1}.velocityVec.Time,tsc1{1,1}.velEst.Data(:,1,:))
% ylim([0,2])
% subplot(3,1,2); hold on; grid on;
% plotsq(tsc1{1,1}.velocityVec.Time,tsc1{1,1}.velocityVec.Data(2,:,:))
% plotsq(tsc1{1,1}.velocityVec.Time,tsc1{1,1}.velEst.Data(:,2,:))
% ylim([-2,2])
% subplot(3,1,3); hold on; grid on;
% plotsq(tsc1{1,1}.velocityVec.Time,tsc1{1,1}.velocityVec.Data(3,:,:))
% plotsq(tsc1{1,1}.velocityVec.Time,tsc1{1,1}.velEst.Data(:,3,:))
% ylim([-2,2])
% legend('Pos','Pos Estimation')

%%
for k = 1:length(rCM)
    figure('Position',[100 100 900 750])
    for j = 1:length(towArray)
        subplot(numel(towArray),1,j); hold on; grid on;
        for i = 1:numel(inc)
            
            plotsq(tsc1{i,j,k,1}.eulerAngles.Time,tsc1{i,j,k,1}.vhclAngleOfAttack.Data,...
                'DisplayName',sprintf('%d Elevator',inc(i)))
            ylim([0 20])
        end
        legend
        xlabel 'Time [s]'
        ylabel 'AoA [deg]'
        title(sprintf('Tow Velocity %.2f m/s',towArray(j)))
        sgtitle(sprintf('Trim Response - CG %d\\%% Chord aft of wing leading edge',round((rCM(k)+vhcl.rCM_LE.Value(1))/vhcl.stbdWing.rootChord.Value*100)),...
            'FontSize',20)
        
        set(gca,'FontSize',15)
    end
end

%%
figure('Position',[100 100 900 750])
for k = 1:length(rCM)
    
    for j = 1:length(towArray)
        subplot(numel(towArray),1,j); hold on; grid on;
        title(sprintf('Tow Speed = %.2f m/s',towArray(j)))
        data = [];
        for i = 1:numel(inc)
            data = [data -tsc1{i,j,k,1}.eulerAngles.Data(2,:,end)*180/pi];
        end
        pA = data
        plot(inc,data,'x','DisplayName','Simulation','LineWidth',1.5)
        plot(elevDefl,pitchAngle,'x','DisplayName','Experiment','LineWidth',1.5)
        xlabel 'Elevator Inclination [deg]'
        ylabel 'Pitch Angle [deg]'
        legend
        xlim([-8 -3])
        %         title(sprintf('CG %d %% Chord Aft of Leading Edge',round((rCM(k)+vhcl.rCM_LE.Value(1))/vhcl.stbdWing.rootChord.Value*100)))
        set(gca,'FontSize',15)
    end
end
%%
figure('Position',[100 100 900 750])
for k = 1:length(rCM)
    
    for j = 1:length(towArray)
        subplot(numel(towArray),1,j); hold on; grid on;
        title(sprintf('Tow Speed = %.2f m/s',towArray(j)))
        data = [];
        for i = 1:numel(inc)
            data = [data -tsc1{i,j,k,1}.Elevation.Data(end)*180/pi];
        end
        plot(pA,data,'x','DisplayName','Simulation','LineWidth',1.5)
        plot(pitchAngle,elevAngle,'x','DisplayName','Experiment','LineWidth',1.5)
        legend('Orientation','horizontal','Location','south')
        xlabel 'Pitch Angle [deg]'
        ylabel 'Elevation Angle [deg]'
        legend
        %         xlim([-8 -3])
        %         title(sprintf('CG %d %% Chord Aft of Leading Edge',round((rCM(k)+vhcl.rCM_LE.Value(1))/vhcl.stbdWing.rootChord.Value*100)))
        set(gca,'FontSize',15)
    end
end
%%
figure('Position',[100 100 900 750]);
for k = 1:length(rCM)
    
    for j = 1:length(towArray)
        h = subplot(2,1,j); hold on; grid on;
        title(sprintf('Tow Speed = %.2f m/s',towArray(j)))
        data = zeros(numel(inc),1)';
        data1 = zeros(numel(inc),1)';
        for i = 1:numel(inc)
            data(i) =sqrt(dot(tsc1{i,j,k,1}.FFluidBdy.Data(:,:,end),tsc1{i,j,k,1}.FFluidBdy.Data(:,:,end)));
            data1(i) = sqrt(dot(tsc1{i,j,k,1}.FBuoyBdy.Data(:,:,end),tsc1{i,j,k,1}.FBuoyBdy.Data(:,:,end)))-...
                sqrt(dot(tsc1{i,j,k,1}.FGravBdy.Data(:,:,end),tsc1{i,j,k,1}.FGravBdy.Data(:,:,end)));
        end
        set(h,'ColorOrderIndex', k)
        plot(inc,data,'x','DisplayName',sprintf('%d%%',...
            round((.097-rCM(k))/vhcl.stbdWing.rootChord.Value*100)),...
            'LineWidth',1.5)
        set(h,'ColorOrderIndex', k)
        x = plot(inc,data1)
        x.Annotation.LegendInformation.IconDisplayStyle = 'off';
        legend('Orientation','horizontal','FontName','cmr12')
        xlabel 'Elevator Inclination [deg]'
        ylabel 'Hydrodynamic Force [N]'
        set(gca,'FontSize',15)
    end
end
%%
figure('Position',[100 100 900 750]);
for k = 1:length(rCM)
    
    for j = 1:length(towArray)
        h = subplot(2,1,j); hold on; grid on;
        title(sprintf('Tow Speed = %.2f m/s',towArray(j)))
        data = zeros(numel(inc),1)';
        data1 = zeros(numel(inc),1)';
        for i = 1:numel(inc)
            data(i) =sqrt(dot(tsc1{i,j,k,1}.FFluidBdy.Data(:,:,end),tsc1{i,j,k,1}.FFluidBdy.Data(:,:,end)));
            data1(i) = sqrt(dot(tsc1{i,j,k,1}.FBuoyBdy.Data(:,:,end),tsc1{i,j,k,1}.FBuoyBdy.Data(:,:,end)))-...
                sqrt(dot(tsc1{i,j,k,1}.FGravBdy.Data(:,:,end),tsc1{i,j,k,1}.FGravBdy.Data(:,:,end)));
        end
        set(h,'ColorOrderIndex', k)
        plot(inc,abs(data./data1),'x','DisplayName',sprintf('%d\\%%',...
            round((.097-rCM(k))/vhcl.stbdWing.rootChord.Value*100)),...
            'LineWidth',1.5)
        %         set(h,'ColorOrderIndex', k)
        %         x = plot(inc,data1)
        %         x.Annotation.LegendInformation.IconDisplayStyle = 'off';
        legend('Orientation','horizontal','FontName','cmr12')
        xlabel 'Elevator Inclination [deg]'
        ylabel '$|F_{hydro}/F_{buoy}|$'
        set(gca,'FontSize',15)
    end
end
%%
pos = 2.63*[-cosd(tsc.kite_azi.Data).*cosd(tsc.kite_elev.Data)+0.77/2.63*tsc.Az_deg.Time...
    sind(tsc.kite_azi.Data).*cosd(tsc.kite_elev.Data) sind(tsc.kite_elev.Data)]';
T = tsc.kite_azi.Time;
figure; subplot(3,1,1);plot(T,pos(1,:))
subplot(3,1,2);plot(T,pos(2,:))
subplot(3,1,3);plot(T,pos(3,:))

vel = diff(pos,1,2)./.01;
%Data Filtering
fLowPass = 2*2*pi; %low pass frequency in rad/s
tau = 1/fLowPass; %time constant in 1/s
tauRate = 1/(1*2*pi);
lowFiltRaw = tf(1,[tau 1]);
lowFiltRate = tf(1,[tauRate 1]);

vel(1,:) = lsim(lowFiltRate,vel(1,:)',T(1:end-1)')';
vel(2,:) = lsim(lowFiltRate,vel(2,:)',T(1:end-1)')';
vel(3,:) = lsim(lowFiltRate,vel(3,:)',T(1:end-1)')';
figure; subplot(3,1,1);plot(T(1:end-1),vel(1,:));ylim([-3 3])
subplot(3,1,2);plot(T(1:end-1),vel(2,:));ylim([-3 3])
subplot(3,1,3);plot(T(1:end-1),vel(3,:));ylim([-3 3])

velMag = (sqrt(dot(vel,vel))/0.77);
figure('Position',[100 100 900 350]);grid on;
subplot(2,1,1);plot(T(1:end-1),velMag);grid on;hold on;ylim([0 3]);
% plot(tsc.LoadCell_N.Time,tsc.LoadCell_N.Data,'-r','LineWidth',1.5)
xlim([1518 1550])
ylim([0.5,2])
ylabel '$|v_{kite}|/|v_{tow}|$'
set(gca,'FontSize',15)
subplot(2,1,2);hold on; grid on;
plot(tsc.rollSP.Time,tsc.rollSP.Data,'--k')
plotsq(tsc.kiteRoll.Time,tsc.kiteRoll.Data,'k');
plot(tsc.yawSP.Time,tsc.yawSP.Data,'--b')
plotsq(tsc.kiteYaw.Time,tsc.kiteYaw.Data,'b');
plot(tsc.kite_azi)
plot(tsc.kite_elev)
% ylim([-40 40]);
ylabel 'Attitude [deg]'
xlabel 'Time [s]'
legend('Roll SP','Roll','Yaw SP','Yaw','Azimuth','Elevation','Location','southwest')%,...
%     'Orientation','horizontal')
set(gca,'FontSize',15)
xlim([1518 1550])
% sgtitle 'Run 51 - 40 Degree Roll SP - 5 Sec Period - 0.77 m/s Tow Velocity'
% yyaxis('left')
%%
figure;hold on; grid on;
plot(tsc.rollSP.Time,tsc.rollSP.Data,'--k')
plotsq(tsc.kiteRoll.Time,tsc.kiteRoll.Data,'k');
plot(tsc.yawSP.Time,tsc.yawSP.Data,'--b')
plotsq(tsc.kiteYaw.Time,tsc.kiteYaw.Data,'b');
plot(tsc.kite_azi)
plot(tsc.kite_elev)
% ylim([-40 40]);
ylabel 'Attitude [deg]'
xlabel 'Time [s]'
legend('Roll SP','Roll','Yaw SP','Yaw','Azimuth','Elevation','Location','southwest')%,...
%     'Orientation','horizontal')
set(gca,'FontSize',15)
xlim([1518 1550])
%%
figure; hold on;
plot(tsc.LoadCell_N/4)
plot(tsc.runCounter)
xlabel('Time [s]','Interpreter','latex')
ylabel('Load [N]','Interpreter','latex')
yyaxis('right')
plot(tsc.kitePitch)
ylabel('Pitch Angle [deg]','Interpreter','latex')
title('')
ylim([-10 20])
legend('Measured Tether Tension','Elevation Angle')
set(gca,'FontSize',15)