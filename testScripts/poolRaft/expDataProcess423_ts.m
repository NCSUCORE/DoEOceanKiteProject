%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
thrArray = .47624;%[200:400:600];%:25:600];
altitudeArray = 1.5;%[100:200:300];%150:25:300];
flwSpdArray = -0.0001;%[0.1:0.1:.5];
inc = [-8 -2];
elevArray = [40 15]*pi/180;
towArray = [.47 .77];%rpm2speed([50 65 80]);%[0.5:.15:.8];
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
for i = 1:length(inc)
    i
    for j = 1:length(towArray)
        j
        for k = 1:numel(elevArray)
            tic
            k
            thrLength = 2.63;  altitude = thrLength*sin(elevArray(k));                 %   Initial tether length/operating altitude/elevation angle
            flwSpd = -1e-9 ;                                   %   m/s - Flow speed                                              %   kN - Max tether tension
            h = 25*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
            [a,b] = boothParamConversion(w,h);                          %   Path basis parameters
            %%  Load components
            el = elevArray(k);
            loadComponent('exp_slCtrl');
            % loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
            % FLIGHTCONTROLLER = 'pathFollowingControllerExp';
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller                           %   Ground station
            loadComponent('raftGroundStation');         
            loadComponent('winchManta');                                %   Winches
            loadComponent('MantaTether');                               %   Manta Ray tether
            loadComponent('realisticSensors')  ;                             %   Sensors
            loadComponent('lineAngleSensor');
            loadComponent('idealSensorProcessing')                      %   Sensor processing
            loadComponent('Manta2RotXFoil_AR8_b8_exp_3dPrinted');                %   AR = 8; 8m span
            SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
            %%  Environment Properties
            loadComponent('ConstXYZT');                                 %   Environment
            env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
            ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
            %%  Set basis parameters for high level controller
            
            loadComponent('constBoothLem');        %   High level controller
            % PATHGEOMETRY = 'lemOfBoothInv'
            % hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
            %
            % hiLvlCtrl.ELctrl.setValue(1,'');
            % hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
            % hiLvlCtrl.ThrCtrl.setValue(1,'');
            
            hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
            las.setInitAng([el 0],'rad');
%             las.tetherLoadDisable;
%             las.dragDisable;
            las.setCD(1.3,'')
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
            initGndStnPos = [x_init;y_init;3];
            
            thrAttachInit = initGndStnPos;
            %%  Vehicle Properties
            % vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
            vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
            vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
%             vhcl.setInitEulAng([180 0 0]*pi/180,'rad');
            vhcl.setInitVelVecBdy([-tow_speed 0 0],'m/s');
            %%  Tethers Properties
            load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
            thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initGndNodeVel.setValue([-tow_speed 0 0]','m/s');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
            thr.tether1.youngsMod.setValue(50e9,'Pa');
            thr.tether1.density.setValue(1000,'kg/m^3');
            thr.tether1.setDiameter(.0076,'m');
            thr.setNumNodes(6,'');
            thr.tether1.setDragCoeff(1.8,'');
            %%  Winches Properties
            wnch.setTetherInitLength(vhcl,thrAttachInit,env,thr,env.water.flowVec.Value);
            wnch.winch1.LaRspeed.setValue(1,'m/s');
            %%  Controller User Def. Parameters and dependant properties
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,thrAttachInit);
            fltCtrl.setPerpErrorVal(.25,'rad')
            fltCtrl.rudderGain.setValue(0,'')
            fltCtrl.rollMoment.kp.setValue(50,'(N*m)/(rad)')
            fltCtrl.rollMoment.ki.setValue(0,'(N*m)/(rad*s)');
            fltCtrl.rollMoment.kd.setValue(25,'(N*m)/(rad/s)')
            fltCtrl.tanRoll.kp.setValue(.45,'(rad)/(rad)')
            thr.tether1.dragEnable.setValue(1,'')
            vhcl.hStab.setIncidence(inc(i),'deg');
            
            
            %%  Set up critical system parameters and run simulation
            simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
            %     open_system('OCTModel')
            %     set_param('OCTModel','SimulationMode','accelerator');
            simWithMonitor('OCTModel')
            tsc1{i,j,k} = signalcontainer(logsout);
            toc
        end
    end
end


%% Process Test Data
selPath = uigetdir;
listing = dir(selPath);

% selPath2 = uigetdir;
% listing2 = dir(selPath2);
figure; hold on; grid on;
for i = 3:numel(listing)-1
    load(strcat(selPath,'\',listing(i).name));
    tscData{i-2} = tsc;
    if i > 4
        a = find(tsc.speedCMD1.Data> 1,1);
        speed(i-2) = tsc.speedCMD1.Data(a);
        tscData{i-2}.linSpeed = tsc.speedCMD1.Data(a);
    else
        a = 1;
        speed(i-2) = 0;
        tscData{i-2}.linSpeed = 0;
    end
    tscData{i-2}.a = a;
    plot(tsc.speedCMD1.Time(a:end),tsc.speedCMD1.Data(a:end))
end
desRPM = [0 0 50 50 50 50 50 50 65 65 65 80 80 80 50 50 50 80 80 80,...
    50 50 50 80 80 80 50 50 50 80 80 80 50 50 50 80 80 80];
figure
plot(speed*30,'x','DisplayName','Commanded RPM')
hold on
plot(desRPM,'o','DisplayName','Test Plan RPM')
xlabel('Test Run')
ylabel('RPM')
legend location southeast


%% March 26 Data
towArray = [0.47 0.62 0.77]*1
load('lineAngleSensor')
g = 9.81; %acc due to grav m/s^2
rho = 1000; %kg/m^3 density of water
xCG = .07 %axial location of center of mass m
xCB = .106 %axial location of center of buoyancy m
mLAS = .573%las.mass.Value; %mass of LAS boom kg
vLAS = las.volume.Value; %las volume
gammaLAS = rho*vLAS/mLAS

A = .012*.47624; %frontal cylinder area m^2
l = .47624; %cylinder length m

CDconst = 4*mLAS*g*(xCG-gammaLAS*xCB)/(rho*A*l);

dataSeg = {[5:13],[14:19],[20:25],[26:31],[32:37]};
% dataSeg = {[11:20],[21:29],[30:38]};
% dataSeg2 = {NaN,[;
for j = 1:numel(dataSeg)
    figure('Position',[100 100 900 400]);
    if j == 1
        
        q = 1; qq = 1; qqq = 1;
        for i = dataSeg{j}
            a = tscData{i}.a;
            %     rmsCalc = tscData{i}.El_deg.getsampleusingtime...
            %         (tscData{i}.El_deg.Time(a),tscData{i}.El_deg.Time(a)+30)
            %     rmsDeg(i) = rms(rmsCalc.Data);
            %     meanDeg(i) = mean(rmsCalc.Data);
            if tscData{i}.linSpeed > 1.66 && tscData{i}.linSpeed < 1.68
                rmsCalc = tscData{i}.El_deg.getsampleusingtime...
                    (tscData{i}.El_deg.Time(a)+10,tscData{i}.El_deg.Time(a)+27)
                rmsDeg(i) = rms(rmsCalc.Data);
                meanDeg(i) = mean(rmsCalc.Data);
                CD(i) = CDconst*cosd(rmsDeg(i))/sind(rmsDeg(i))/towArray(1)^2;
                CDmean(i) = CDconst*cosd(meanDeg(i))/sind(meanDeg(i))/towArray(1)^2;
                subplot(1,3,1); hold on; grid on;
                set(gca,'FontSize',20)
                plot(tscData{i}.El_deg.Time(tscData{i}.a:end)...
                    -tscData{i}.El_deg.Time(tscData{i}.a),...
                    tscData{i}.El_deg.Data(tscData{i}.a:end),...
                    '-','DisplayName',sprintf('Run %d',q));
                plot([5 30],[meanDeg(i) meanDeg(i)],'LineStyle','--','DisplayName',sprintf('Mean Elevation Run %d',q))
                q = q+1;
                ylim([30,90])
                xlabel 'Time [s]'
                ylabel 'Elevation Angle [deg]'
                title(sprintf('%.2f m/s',towArray(1)))
                legend('Location','northeast','FontSize',14)
            elseif tscData{i}.linSpeed > 2.16 && tscData{i}.linSpeed < 2.17
                rmsCalc = tscData{i}.El_deg.getsampleusingtime...
                    (tscData{i}.El_deg.Time(a)+10,tscData{i}.El_deg.Time(a)+20)
                rmsDeg(i) = rms(rmsCalc.Data);
                meanDeg(i) = mean(rmsCalc.Data);
                CD(i) = CDconst*cosd(rmsDeg(i))/sind(rmsDeg(i))/towArray(2)^2;
                CDmean(i) = CDconst*cosd(meanDeg(i))/sind(meanDeg(i))/towArray(2)^2;
                subplot(1,3,2); hold on; grid on;
                set(gca,'FontSize',20)
                plot(tscData{i}.El_deg.Time(tscData{i}.a:end)...
                    -tscData{i}.El_deg.Time(tscData{i}.a),...
                    tscData{i}.El_deg.Data(tscData{i}.a:end),...
                    '-','DisplayName',sprintf('Run %d',qq));
                plot([5 25],[meanDeg(i) meanDeg(i)],'LineStyle','--','DisplayName',sprintf('Mean Elevation Run %d',qq))
                qq = qq+1;
                ylim([30,90])
                xlabel 'Time [s]'
                ylabel 'Elevation Angle [deg]'
                title(sprintf('%.2f m/s',towArray(2)))
                legend('Location','northeast','FontSize',14)
            elseif tscData{i}.linSpeed > 2.6 && tscData{i}.linSpeed < 2.7
                subplot(1,3,3); hold on; grid on;
                set(gca,'FontSize',20)
                rmsCalc = tscData{i}.El_deg.getsampleusingtime...
                    (tscData{i}.El_deg.Time(a)+5,tscData{i}.El_deg.Time(a)+15)
                rmsDeg(i) = rms(rmsCalc.Data);
                meanDeg(i) = mean(rmsCalc.Data);
                CD(i) = CDconst*cosd(rmsDeg(i))/sind(rmsDeg(i))^2/towArray(3)^2;
                CDmean(i) = CDconst*cosd(meanDeg(i))/sind(meanDeg(i))^2/towArray(3)^2;
                predElev = acot(rho*towArray(3)^2*A*l*1.2883/(4*mLAS*g*(xCG-gammaLAS*xCB)))*180/pi;
                plot(tscData{i}.El_deg.Time(tscData{i}.a:end)...
                    -tscData{i}.El_deg.Time(tscData{i}.a),...
                    tscData{i}.El_deg.Data(tscData{i}.a:end),...
                    '-','DisplayName',sprintf('Run %d',qqq));
%                 line([5 20],[predElev predElev],'DisplayName','Predicted Elevation')
                qqq = qqq+1;
                ylim([30,90])
                xlabel('Time [s]')
                ylabel 'Elevation Angle [deg]'
                title(sprintf('%.2f m/s',towArray(3)))
                legend('Location','northeast','FontSize',14)
            else
            end
        end
        cdMean = mean([CDmean(5:10)]);
        cdStd = std([CDmean(5:10)]);
        predElev = acot(rho*towArray(3)^2*A*l*cdMean/(4*mLAS*g*(xCG-gammaLAS*xCB)))*180/pi;
        predElevPos = acot(rho*towArray(3)^2*A*l*(cdMean+2*cdStd)/(4*mLAS*g*(xCG-gammaLAS*xCB)))*180/pi;
        predElevNeg = acot(rho*towArray(3)^2*A*l*(cdMean-2*cdStd)/(4*mLAS*g*(xCG-gammaLAS*xCB)))*180/pi;
        subplot(1,3,3); hold on; grid on;
        plot([5 20],[predElev predElev],'LineStyle','--','DisplayName','Predicted Mean Elevation')
        plot([5 20],[predElevPos predElevPos],'LineStyle','--','DisplayName','Predicted Upper Bound')
        plot([5 20],[predElevNeg predElevNeg],'LineStyle','--','DisplayName','Predicted Lower Bound')
    else
        for i = dataSeg{j}
            windowSize = 100;
            b = (1/windowSize)*ones(1,windowSize);
            a = 1;
            elDot{i} = diff(lowpass(tscData{i}.kite_elev.Data(tscData{i}.a:end),2,2000))./(tscData{i}.kite_elev.Time(tscData{i}.a+1:end)-tscData{i}.kite_elev.Time(tscData{i}.a:end-1));
            elDot{i} = filter(b,a,elDot{i});
            elDotT{i} = tscData{i}.kite_elev.Time(tscData{i}.a:end-1)-tscData{i}.kite_elev.Time(tscData{i}.a);
            if tscData{i}.linSpeed > 1.66 && tscData{i}.linSpeed < 1.68
%                 subplot(1,2,1); hold on; grid on;
%                 plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
%                     -tscData{i}.kite_elev.Time(tscData{i}.a)-4,...
%                     tscData{i}.kite_elev.Data(tscData{i}.a:end),...
%                     '-','DisplayName',sprintf('Run %d',q));
%                 q = q+1;
%                 ylim([0,90])
%                 xlim([0,20])
%                 xlabel 'Time [s]'
%                 ylabel 'Elevation Angle [deg]'
%                 title(sprintf('%.2f m/s',towArray(1)))
%                 legend('Location','southeast')
%             elseif tscData{i}.linSpeed > 2.16 && tscData{i}.linSpeed < 2.17
%                 subplot(1,3,2); hold on; grid on;
%                 plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
%                     -tscData{i}.kite_elev.Time(tscData{i}.a),...
%                     tscData{i}.kite_elev.Data(tscData{i}.a:end),...
%                     '-','DisplayName',sprintf('Run %d',qq));
%                 qq = qq+1;
%                 ylim([0,90])
%                 xlabel 'Time [s]'
%                 ylabel 'Elevation Angle [deg]'
%                 title(sprintf('%.2f m/s',towArray(2)))
%                 legend('Location','southeast')
            elseif tscData{i}.linSpeed > 2.6 && tscData{i}.linSpeed < 2.7
                subplot(1,1,1); hold on; grid on;
                plot(tscData{i}.kite_elev.Time(tscData{i}.a:end)...
                    -tscData{i}.kite_elev.Time(tscData{i}.a)-4,...
                    tscData{i}.kite_elev.Data(tscData{i}.a:end),...
                    '-','DisplayName',sprintf('Run %d',qqq));
                qqq = qqq+1;
                ylim([0,90])
                xlim([0,10])
                xlabel 'Time [s]' 
                ylabel 'Elevation Angle [deg]' 
                title(sprintf('%.2f m/s',towArray(3)))
                legend('Location','southeast')
            else
            end
        end
        for i = 2
            subplot(1,1,1)
            alignment = [0 0;1 1; 2 1; 1 1; 2 2];
            imEl = squeeze(atan2(tsc1{alignment(j,2),i,alignment(j,1)}.thrNodePosVecs.Data(3,1,:)-...
                tsc1{alignment(j,2),i,alignment(j,1)}.thrNodePosVecs.Data(3,2,:),...
                tsc1{alignment(j,2),i,alignment(j,1)}.thrNodePosVecs.Data(1,1,:)-...
                tsc1{alignment(j,2),i,alignment(j,1)}.thrNodePosVecs.Data(1,2,:)))*180/pi;
            imEld{i,j} = diff(imEl)./(tsc1{alignment(j,2),i,alignment(j,1)}.thrNodePosVecs.Time(2:end)-tsc1{alignment(j,2),i,alignment(j,1)}.thrNodePosVecs.Time(1:end-1));
            imEldotT{i,j} = tsc1{alignment(j,2),i,alignment(j,1)}.thrNodePosVecs.Time(1:end-1);
            plot(tsc1{alignment(j,2),i,alignment(j,1)}.elevationAngle.Time,imEl...
                ,'k','DisplayName','Simulation','LineWidth',2)
            
%             plot(tsc1{alignment(j,2),i,alignment(j,1)}.elevationAngle.Time,squeeze(tsc1{alignment(j,2),i,alignment(j,1)}.lasElevDeg.Data)...
%                 ,'b--','DisplayName','Simulation')
            %         plot(tsc1{j,i}.elevationAngle.Time,-squeeze(tsc1{j,i}.elevationAngle.Data)...
            %             ,'g--','DisplayName','Sim')
        end
    end

    titleCell = {'Elevation Response - Line Angle Sensor',...
        'Elevation Response - Incidence = -8 Deg Init Elevation = 40 Deg',...
        'Elevation Response - Incidence = -8 Deg Init Elevation = 10 Deg',...
        'Elevation Response - Incidence = -2 Deg Init Elevation = 40 Deg',...
        'Elevation Response - Incidence = -2 Deg Init Elevation = 10 Deg'};
%     sgtitle(titleCell{j},'FontSize',24)

end

figure('Position',[100 100 900 400]); hold on; grid on;

for i = 2%
    for j = 3
        plot(imEldotT{i,j},imEld{i,j},'k','LineWidth',2)
    end
end
for i = [4:6]
plot(elDotT{19+i}-4,elDot{19+i})
end
xlim([.1 10])
ylim([-5 50])
legend('Simulation','Run 7','Run 8','Run 9')
xlabel 'Time [s]'
ylabel 'Elevation Rate [deg/s]'
% figure; hold on; grid on;
% plot(tscData{11}.speedCMD1.Time(tscData{11}.a:end)-tscData{11}.speedCMD1.Time(tscData{11}.a),...
%     tscData{11}.speedCMD1.Data(tscData{11}.a:end)*30,'DisplayName','Commanded')
% plot(tscData{11}.rpm_w1.Time(tscData{11}.a:end)-tscData{11}.rpm_w1.Time(tscData{11}.a),...
%     tscData{11}.rpm_w1.Data(tscData{11}.a:end)/(2*pi),'DisplayName','Encoder Measurement')
% xlabel('Time [s]')
% ylabel('Winch Speed [rpm]')
% ylim([0 1000])
% legend
% vhcl.animateSim(tsc1{1,1},2,'TracerDuration',20,...
%     'GifTimeStep',0,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%     'GifFile','expCross.gif','timestep',0.1,'View',[0,0]);
% 
% function [linSpeed] = rpm2speed(rpm)
% 
% p1 =    0.008441;  %(-0.01554, 0.03243)
% p2 =      0.2241;  %(-1.362, 1.811)
% 
% linSpeed = p1*rpm + p2;
% end