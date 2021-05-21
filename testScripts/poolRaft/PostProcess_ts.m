%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
inc = [-8]% -2];
elevArray = 15*pi/180%[40 15]*pi/180;
towArray = 0.77%[0.47 .77];
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
            thrLength = 2.63%-.52;  altitude = thrLength*sin(elevArray(k));                 %   Initial tether length/operating altitude/elevation angle
            flwSpd = -1e-9 ;                                   %   m/s - Flow speed                                              %   kN - Max tether tension
            h = 25*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
            [a,b] = boothParamConversion(w,h);                          %   Path basis parameters
            %%  Load components
            el = elevArray(k);
            loadComponent('exp_slCtrl');
            fltCtrl.ctrlOff.setValue(0,'')
            % loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
            % FLIGHTCONTROLLER = 'pathFollowingControllerExp';
            loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller                           %   Ground station
            loadComponent('raftGroundStation');         
            loadComponent('winchManta');                                %   Winches
            loadComponent('MantaTether');                               %   Manta Ray tether
            loadComponent('realisticSensors');                             %   Sensors
            loadComponent('lineAngleSensor');
            loadComponent('idealSensorProcessing');                      %   Sensor processing
            loadComponent('Manta2RotXFoil_AR8_b8_exp2');                %   AR = 8; 8m span
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
            las.setThrInitAng([-el 0],'rad');
            las.setInitAngVel([-0 0],'rad/s');
%             las.tetherLoadDisable;
%             las.dragDisable;
%             las.setCD(1.3,'')
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
            % vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
            vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
            vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
%             vhcl.setInitEulAng([180 0 0]*pi/180,'rad');
            vhcl.setInitVelVecBdy([0 0 0],'m/s');
            %%  Tethers Properties
            load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
            thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            x = thr.tether1.initGndNodePos.Value(1)-thr.tether1.initAirNodePos.Value(1)
            y = thr.tether1.initGndNodePos.Value(2)-thr.tether1.initAirNodePos.Value(2)
            z = thr.tether1.initGndNodePos.Value(3)-thr.tether1.initAirNodePos.Value(3)
            initThrAng = atan2(z,sqrt(x^2+y^2))

            las.setThrInitAng([-initThrAng 0],'rad');
            thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
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
            tsc1 = signalcontainer(logsout);
            toc
        end
    end
end


%% Process Test Data
selPath = 'G:\Shared drives\Kite Experimentation\Pool testing\Friday Pool Test\04 23 21\Data';
listing = dir(selPath);

figure; hold on; grid on;
for i = 28:30
    load(strcat(selPath,'\',listing(i).name));
    tscData{i-27} = tsc;
    if i > 4
        a = find(tsc.speedCMD1.Data> 1,1);
        speed(i-27) = tsc.speedCMD1.Data(a);
        tscData{i-27}.linSpeed = tsc.speedCMD1.Data(a);
    else
        a = 1;
        speed(i-2) = 0;
        tscData{i-2}.linSpeed = 0;
    end
    tscData{i-27}.a = a;
    plot(tsc.speedCMD1.Time(a:end),tsc.speedCMD1.Data(a:end))
end



%% March 26 Data
towArray = [0.47 0.62 0.77]*1
load('lineAngleSensor')
g = 9.81; %acc due to grav m/s^2
rho = 1000; %kg/m^3 density of water
xCG = las.L_CM.Value %axial location of center of mass m
xCB = las.L_CB.Value %axial location of center of buoyancy m
mLAS = las.mass.Value; %mass of LAS boom kg
vLAS = las.volume.Value; %las volume
gammaLAS = rho*vLAS/mLAS
l = las.length.Value;
d = las.diameter.Value;
A = l*d; %frontal cylinder area m^2

CDconst = 4*mLAS*g*(xCG-gammaLAS*xCB)/(rho*A*l);

%Data Filtering
fLowPass = 2*2*pi; %low pass frequency in rad/s
tau = 1/fLowPass; %time constant in 1/s
tauRate = 1/(2*2*pi);
lowFiltRaw = tf(1,[tau 1]);
lowFiltRate = tf(1,[tauRate 1]);


dataSeg = {[],[1:3]}%{[5:13],[14:19],[20:25],[26:31],[32:37]};
        for i = 1:3
%             windowSize = 100;
%             b = (1/windowSize)*ones(1,windowSize);
%             a = 1;
            elFilt{i} = lsim(lowFiltRaw,tscData{i}.kite_elev.Data(tscData{i}.a:end),tscData{i}.kite_elev.Time(tscData{i}.a:end));
            elDot{i} = diff(elFilt{i})./(tscData{i}.kite_elev.Time(tscData{i}.a+1:end)-tscData{i}.kite_elev.Time(tscData{i}.a:end-1));
%             
            elDotT{i} = tscData{i}.kite_elev.Time(tscData{i}.a:end-1)-tscData{i}.kite_elev.Time(tscData{i}.a);
            elDot{i} = lsim(lowFiltRate,elDot{i},elDotT{i});


        end
        for i = 2
            subplot(1,1,1); hold on;
            alignment = [0 0;1 1; 2 1; 1 1; 2 2];
            imEl = squeeze(atan2(tsc1.t1Unit.Data(3,1,:),...
                sqrt(tsc1.t1Unit.Data(1,1,:).^2+...
                tsc1.t1Unit.Data(2,1,:).^2)))*180/pi;
            imEld = diff(imEl)./(tsc1.thrNodePosVecs.Time(2:end)-tsc1.thrNodePosVecs.Time(1:end-1));
            imEldotT = tsc1.thrNodePosVecs.Time(1:end-1);
            elDotLAS = tsc1.lasElevRateDeg.Data(1:end-1);
            plot(tsc1.elevationAngle.Time,imEl...
                ,'k','DisplayName','Simulation','LineWidth',2)
            plot(tsc1.lasElevDeg.Time,...
                -tsc1.lasElevDeg.Data,...
                'r','DisplayName','Simulation LAS','LineWidth',2)
%             plot(tsc1{alignment(j,2),i,alignment(j,1)}.elevationAngle.Time,squeeze(tsc1{alignment(j,2),i,alignment(j,1)}.lasElevDeg.Data)...
%                 ,'b--','DisplayName','Simulation')
            %         plot(tsc1{j,i}.elevationAngle.Time,-squeeze(tsc1{j,i}.elevationAngle.Data)...
            %             ,'g--','DisplayName','Sim')
        end


    titleCell = {'Elevation Response - Line Angle Sensor',...
        'Elevation Response - Incidence = -8 Deg Init Elevation = 40 Deg',...
        'Elevation Response - Incidence = -8 Deg Init Elevation = 10 Deg',...
        'Elevation Response - Incidence = -2 Deg Init Elevation = 40 Deg',...
        'Elevation Response - Incidence = -2 Deg Init Elevation = 10 Deg'};
%     sgtitle(titleCell{j},'FontSize',24)



figure('Position',[100 100 900 400]); hold on; grid on;

for i = 2%
    for j = 3
        plot(imEldotT,imEld,'k','LineWidth',2)
        plot(imEldotT,-elDotLAS,'r','LineWidth',2)
    end
end
for i = 1:3
plot(elDotT{i}-4,elDot{i})
end
xlim([.1 10])
ylim([-5 50])
legend('Simulation','Simulation LAS','Run 7','Run 8','Run 9')
xlabel 'Time [s]'
ylabel 'Elevation Rate [deg/s]'