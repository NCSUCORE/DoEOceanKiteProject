% Test script for pool test simulation of the kite model
clear;clc;close all;



% Process Test Data
selPath = 'C:\Users\andre\Documents\MHK\04232021';
listing = dir(selPath);

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
end

dataSeg = {[5:13]};
for j = 1:numel(dataSeg)
    for i = dataSeg{j}
        a = tscData{i}.a;
        if tscData{i}.linSpeed > 1.66 && tscData{i}.linSpeed < 1.68
            rmsCalc = tscData{i}.El_deg.getsampleusingtime...
                (tscData{i}.El_deg.Time(a)+10,tscData{i}.El_deg.Time(a)+27);
            rmsDeg(i-4) = rms(rmsCalc.Data);
            meanDeg(i-4) = mean(rmsCalc.Data);
        elseif tscData{i}.linSpeed > 2.16 && tscData{i}.linSpeed < 2.17
            rmsCalc = tscData{i}.El_deg.getsampleusingtime...
                (tscData{i}.El_deg.Time(a)+10,tscData{i}.El_deg.Time(a)+20);
            rmsDeg(i-4) = rms(rmsCalc.Data);
            meanDeg(i-4) = mean(rmsCalc.Data);
        elseif tscData{i}.linSpeed > 2.6 && tscData{i}.linSpeed < 2.7
            rmsCalc = tscData{i}.El_deg.getsampleusingtime...
                (tscData{i}.El_deg.Time(a)+5,tscData{i}.El_deg.Time(a)+15);
            rmsDeg(i-4) = rms(rmsCalc.Data);
            meanDeg(i-4) = mean(rmsCalc.Data);
        else
        end
    end
end

towArray = [0.47 0.47 0.47 0.62 0.62 0.62 0.77 0.77 0.77]*1;
load('lineAngleSensor')
g = 9.81; %acc due to grav m/s^2
rho = 1000; %kg/m^3 density of water
xCG = las.L_CM.Value; %axial location of center of mass m
xCB = las.L_CB.Value; %axial location of center of buoyancy m
mLAS = las.mass.Value; %mass of LAS boom kg
vLAS = las.volume.Value; %las volume
gammaLAS = rho*vLAS/mLAS;
l = .49;%las.length.Value;
offset = las.length.Value-l;
d = las.diameter.Value;
A = l*d; %frontal cylinder area m^2

lasCD = -(rho*vLAS*xCB-mLAS*xCG)*g./(1/2*rho.*towArray.^2*l*d*(l/2+offset))...
    .*cot(rmsDeg*pi/180)./sin(rmsDeg*pi/180);
lasStd = std(lasCD)
lasMean = mean(lasCD)

%% Compare to Simulation
clear tsc
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
inc = -8;
elevArray = 90*pi/180;
towArray = [.47 .62 .77];%rpm2speed([50 65 80]);%[0.5:.15:.8];
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
            fltCtrl.ctrlOff.setValue(0,'')
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller                           %   Ground station
            loadComponent('raftGroundStation');         
            loadComponent('winchManta');                                %   Winches
            loadComponent('MantaTether');                               %   Manta Ray tether
            loadComponent('realisticSensors');                             %   Sensors
            loadComponent('lineAngleSensor');
            loadComponent('idealSensorProcessing');                      %   Sensor processing
            loadComponent('Manta2RotXFoil_AR8_b8_exp_3dPrinted');                %   AR = 8; 8m span
            SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
            %%  Environment Properties
            loadComponent('ConstXYZT');                                 %   Environment
            env.water.setflowVec([1e-9 0 0],'m/s');                   %   m/s - Flow speed vector
            ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
            %%  Set basis parameters for high level controller           
            loadComponent('constBoothLem');        %   High level controller
            hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
            las.setInitAng([-el 0],'rad');
            las.tetherLoadDisable;
%            las.dragDisable;
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
%             las.CD.setValue(1.3,'')
            thrAttachInit = initGndStnPos;
            %%  Vehicle Properties
            vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
            vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
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
            tsc{j} = signalcontainer(logsout);
            toc
        end
    end
end

towArray1 =  [0.47 0.62 0.77];
degPlot = [mean(rmsDeg(1:3)) mean(rmsDeg(4:6)) mean(rmsDeg(7:9))];
lasDrag = 1/2*rho.*towArray1.^2*l*d*(l/2+offset)*las.CD.Value.*sind(degPlot).^2;

for i = 1:length(towArray)
    simDegPlot(i) = -tsc{i}.lasElevDeg.Data(end);
    simLasDrag(i) = tsc{i}.lasQthetaDrag.Data(end);
end

figure; hold on; grid on;

plot(towArray,simDegPlot-degPlot,'x')
% plot(towArray1,degPlot,'o','DisplayName','Experiment')
% legend
xlabel 'Tow Speed [m/s]'
ylabel 'LAS Inclination Error [deg]'

figure; hold on; grid on;
plot(towArray,simLasDrag,'DisplayName','Simulation')
plot(towArray1,lasDrag,'o','DisplayName','Experimental Predicted ')
legend
xlabel 'Tow Speed [m/s]'
ylabel 'Drag Moment [N-m]'