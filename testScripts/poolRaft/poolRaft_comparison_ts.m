%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
thrArray = 3;%[200:400:600];%:25:600];
altitudeArray = 1.5;%[100:200:300];%150:25:300];
flwSpdArray = 1e-9;%[0.1:0.1:.5]; 
inc = -4;%[-8:1:0];
towArray = 1%[.4:.1:1];
elevArray = [20]*pi/180
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
            loadComponent('Manta2RotXFoil_AR8_b8_exp');                %   AR = 8; 8m span
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
            las.setInitAng([-el 0],'rad');
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
figure
plot(tsc1{1,1,1}.t1Unit)

figure
plot(tsc1{1,1,1}.t2Unit)

figure
plot(tsc1{1,1,1}.lasBoomOrient)


imElGnd = squeeze(atan2(tsc1{1,1,1}.thrNodePosVecs.Data(3,1,:)-...
    tsc1{1,1,1}.thrNodePosVecs.Data(3,2,:),...
    tsc1{1,1,1}.thrNodePosVecs.Data(1,1,:)-...
    tsc1{1,1,1}.thrNodePosVecs.Data(1,2,:)))*180/pi;

imElKite = squeeze(atan2(tsc1{1,1,1}.thrNodePosVecs.Data(3,end-1,:)-...
    tsc1{1,1,1}.thrNodePosVecs.Data(3,end,:),...
    tsc1{1,1,1}.thrNodePosVecs.Data(1,end-1,:)-...
    tsc1{1,1,1}.thrNodePosVecs.Data(1,end,:)))*180/pi;


figure; hold on; grid on;
plotsq(tsc1{1,1,1}.elevationAngle.Time,imElGnd)
plotsq(tsc1{1,1,1}.elevationAngle.Time,imElKite)
plotsq(tsc1{1,1,1}.lasElevDeg.Time,-tsc1{1,1,1}.lasElevDeg.Data)
legend('Gnd Tether Elevation Angle','Kite Tether Elevation Angle','LAS Elevation Angle')
xlabel 'Time [s]'
ylabel 'Elevation Angle [deg]'



figure
for k = 1:numel(elevArray)

    for j = 1:length(towArray)
           hold on; grid on;
        for i = 1:2:length(inc)
            plot(tsc1{i,j,k}.velocityVec.Time,tsc1{i,j,k}.velCMvec.Data(1,:)/towArray(j)...
                ,'DisplayName',...
                sprintf('%d deg Initial Elevation Angle',elevArray(k)*180/pi))
        end
        title(sprintf('%.2f m/s Tow Velocity',...
            towArray(j)))
        legend
        xlabel 'Time [s]'
        ylabel '$u/V_{tow}$'
    end
    sgtitle(sprintf('Initial Elevation Angle - %d deg',elevArray(k)*180/pi))
end
% 
% for k = 1:numel(elevArray)
%     figure
%     for j = 1:length(towArray)
%            subplot(3,3,j); hold on; grid on;
%         for i = 1:2:length(inc)
%             plot(tsc1{i,j,k}.alphaBdy.Time,...
%                 squeeze(tsc1{i,j,k}.portWingAoA.Data),...
%                 'DisplayName',...
%                 sprintf('%d Stabilizer Inclination',inc(i)))
%         end
%         title(sprintf('%.2f m/s Tow Velocity',...
%             towArray(j)))
%         legend
%         xlabel 'Time [s]'
%         ylabel 'Elevation [deg]'
%     end
%     sgtitle(sprintf('Initial Elevation Angle - %d deg',elevArray(k)*180/pi))
% end
figure
for k = 1:numel(elevArray)
    
    for j = 1:length(towArray)
%         subplot(3,3,k); hold on; grid on;
        for i = 1:2:length(inc)
            imElGnd = squeeze(atan2(tsc1{i,j,k}.thrNodePosVecs.Data(3,1,:)-...
                tsc1{i,j,k}.thrNodePosVecs.Data(3,2,:),...
                tsc1{i,j,k}.thrNodePosVecs.Data(1,1,:)-...
                tsc1{i,j,k}.thrNodePosVecs.Data(1,2,:)))*180/pi;
            
            imElKite = squeeze(atan2(tsc1{i,j,k}.thrNodePosVecs.Data(3,end-1,:)-...
                tsc1{i,j,k}.thrNodePosVecs.Data(3,end,:),...
                tsc1{i,j,k}.thrNodePosVecs.Data(1,end-1,:)-...
                tsc1{i,j,k}.thrNodePosVecs.Data(1,end,:)))*180/pi;
            

            
            plot(tsc1{i,j,k}.lasElevDeg.Time,...
                squeeze(tsc1{i,j,k}.lasElevDeg.Data),...
                'DisplayName','LAS Elevation')
            
            plot(tsc1{i,j,k}.elevationAngle.Time,...
                squeeze(tsc1{i,j,k}.elevationAngle.Data),...
                'DisplayName','Simulation Gross Elevation')
            
            plot(tsc1{i,j,k}.lasElevDeg.Time,...
                -imElKite,...
                'DisplayName','Simulated Kite Tether Angle')
            
            plot(tsc1{i,j,k}.lasElevDeg.Time,...
                -imElGnd,...
                'DisplayName','Simulated Ground Station Tether Angle')
        end
%         title(sprintf('%.2f m/s Tow Velocity',...
%             towArray(j)))
if k == 1
        legend
end
        xlabel 'Time [s]'
        ylabel 'Elevation [deg]'
    end
    sgtitle(sprintf('Initial Elevation Angle - %d deg',elevArray(k)*180/pi))
end