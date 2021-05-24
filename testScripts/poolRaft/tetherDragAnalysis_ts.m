% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear

% Import and Process Data
selPath = 'C:\Users\andre\Documents\MHK\04092021';
listing = dir(selPath);

selPath2 = 'C:\Users\andre\Documents\MHK\04162021';
listing2 = dir(selPath2);
for i = 1:9
    load(strcat(selPath2,'\',listing2(i+3).name));
    tscData{i} = tsc;
    a = find(tsc.speedCMD1.Data> 1,1);
    speed(i) = tsc.speedCMD1.Data(a);
    tscData{i}.linSpeed = tsc.speedCMD1.Data(a);
    tscData{i}.a = a;
end

for i = 1:9
    a = tscData{i}.a;
    
    if tscData{i}.linSpeed > 1.66 && tscData{i}.linSpeed < 1.68
        rmsCalc = tscData{i}.El_deg.getsampleusingtime...
            (tscData{i}.El_deg.Time(a)+15,tscData{i}.El_deg.Time(a)+30);
        rmsDeg(i) = rms(rmsCalc.Data);
        meanDeg(i) = mean(rmsCalc.Data);
        stdDev(i) = std(rmsCalc.Data);
        
    elseif tscData{i}.linSpeed > 2.16 && tscData{i}.linSpeed < 2.17
        rmsCalc = tscData{i}.El_deg.getsampleusingtime...
            (tscData{i}.El_deg.Time(a)+10,tscData{i}.El_deg.Time(a)+20);
        rmsDeg(i) = rms(rmsCalc.Data);
        meanDeg(i) = mean(rmsCalc.Data);
        stdDev(i) = std(rmsCalc.Data);
        
    elseif tscData{i}.linSpeed > 2.6 && tscData{i}.linSpeed < 2.7
        rmsCalc = tscData{i}.El_deg.getsampleusingtime...
            (tscData{i}.El_deg.Time(a)+7,tscData{i}.El_deg.Time(a)+13);
        rmsDeg(i) = rms(rmsCalc.Data);
        meanDeg(i) = mean(rmsCalc.Data);
        stdDev(i) = std(rmsCalc.Data);
    else
    end
end



%Specify system parameters
towArray = [.47 .62 .77];
thrDragCoef = 0.5:.01:2;
[towArray,thrDragCoef] = meshgrid(towArray,thrDragCoef);

[n,m] = size(towArray)
lasDeg = repmat([mean(rmsDeg(1:3)) mean(rmsDeg(4:6)) mean(rmsDeg(7:9))],n,1);
lasStd = repmat([std(rmsDeg(1:3)) std(rmsDeg(4:6)) std(rmsDeg(7:9))],n,1);

%Tether Properties
% lThr = 2.63; %m tether arc length @ LAS
dThr = 0.0076; %m tether diameter

%Drag Object Properties
CdCyl = 1; %Cylinder drag coefficient
mCyl = 1.3285 ; %kg mass of cylinder
dCyl = 1.5*.0254; %m diameter of cylinder
rhoCyl = 7850; %kg/m^3 density of 304
rhoWat = 1000; %kg/m^3 density of water
lCyl = 4*mCyl/(pi*rhoCyl*dCyl^2); %cylinder length
fCyl = mCyl*9.81-1000*pi*dCyl^2/4*lCyl*9.81; %net buoyant force on cylinder
fDragCyl = 0.5*1000*towArray.^2*CdCyl*dCyl*lCyl; %cylinder drag force
T1 = sqrt(fCyl^2+fDragCyl.^2);
theta1 = atan2(fCyl,fDragCyl);
theta1deg = theta1*180/pi;

%Line Angle Sensor Properties
load('lineAngleSensor')
g = 9.81; %acc due to grav m/s^2
xCG = las.L_CM.Value; %axial location of center of mass m
xCB = las.L_CB.Value; %axial location of center of buoyancy m
mLAS = las.mass.Value; %mass of LAS boom kg
vLAS = las.volume.Value; %las volume
lasCD = las.CD.Value;
l = .49;%las.length.Value;
offset = las.length.Value-l;
d = las.diameter.Value;
A = l*d; %frontal cylinder area m^2
lThr = 2.63-(lasDeg*1.5831+444.73)/1000; %Tether lost to the LAS roller
%Calculate Tether Tension at the LAS
alpha = 1/2*rhoWat*towArray.^2.*thrDragCoef*dThr.*lThr;
thrAngle = acot(alpha./T1+fDragCyl/fCyl);
thrAngDeg = thrAngle*180/pi;
thrTen = T1.*sin(theta1)./sin(thrAngle); 

%Calculate Line Angle Sensor Drag
lasDrag = 1/2*rhoWat.*towArray.^2.*lasCD*l*d.*sin(lasDeg*pi/180);

% %Calculate the Vector from LAS end to roller
% theta2 = atan2((l+offset)*sin(lasDeg*pi/180),(l+offset).*cos(lasDeg*pi/180)-0.0717);
theta2 = (-0.0014*lasDeg.^2 + 1.1256*lasDeg + 0.4256)*pi/180;

err = -lasDrag.*sin(lasDeg*pi/180)*(l/2+offset)...
    -thrTen.*sin(theta2-lasDeg*pi/180)*(l+offset)...
    +thrTen.*sin(thrAngle-lasDeg*pi/180)*(l+offset)...
    -g*cos(lasDeg*pi/180)*(vLAS*rhoWat*xCB-mLAS*xCG);

figure; hold on; grid on;
plot(thrDragCoef(:,:,1),err(:,:,1))
% plot([0.5 2],[0 0])
legend('Tow Speed = 0.47 m/s','Tow Speed = 0.62 m/s',...
    'Tow Speed = 0.77 m/s')
xlabel '$C_{D_{tether}}$'
ylabel 'Error [N-m]'
% Re = [.47 .62 .77]*.0076/1e-6
%%
clear tsc
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
inc = -8;
elevArray = 90*pi/180;
cdteth = [1.66 1.81]
towArray = [.47 .62 .77];%rpm2speed([50 65 80]);%[0.5:.15:.8];
for i = 1:length(cdteth)
    i
    for j = 1:length(towArray)
        j
        for k = 1:numel(elevArray)
            tic
            k
            thrLength = 2.63-.52;  altitude = thrLength*sin(elevArray(k));                 %   Initial tether length/operating altitude/elevation angle
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
            loadComponent('Manta2RotXFoil_AR8_b8_exp_3dPrinted'); 
            VEHICLE = "weight"; %   AR = 8; 8m span
            SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
            %%  Environment Properties
            loadComponent('ConstXYZT');                                 %   Environment
            env.water.setflowVec([1e-9 0 0],'m/s');                   %   m/s - Flow speed vector
            ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
            %%  Set basis parameters for high level controller           
            loadComponent('constBoothLem');        %   High level controller
            hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
            las.setInitAng([-el 0],'rad');
%             las.tetherLoadDisable;
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
            thr.tether1.setDragCoeff(cdteth(i),'');
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
            vhcl.hStab.setIncidence(inc,'deg');            
            %%  Set up critical system parameters and run simulation
            simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
            %     open_system('OCTModel')
            %     set_param('OCTModel','SimulationMode','accelerator');
            simWithMonitor('OCTModel')
            tsc{j+(i-1)*length(towArray)} = signalcontainer(logsout);
            toc
        end
    end
end

lasDegPlot = [mean(rmsDeg(1:3)) mean(rmsDeg(4:6)) mean(rmsDeg(7:9))] 

for i = 1:numel(tsc)
    lasDegSim(i) = -tsc{i}.lasElevDeg.Data(end)
end

figure; hold on; grid on;
plot(towArray,lasDegPlot,'x','DisplayName','Experimental Data')
plot(towArray,lasDegSim(1:3),'o','DisplayName','Simulation CD = 1.66')
plot(towArray,lasDegSim(4:6),'*','DisplayName','Simulation CD = 1.81')
xlabel('Tow Velocity [m/s]')
ylabel('Elevation Angle')
legend