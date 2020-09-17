 

%% Reel in test script JOEY
Simulink.sdi.clear
clear;clc;%close all

%%  Set Physical Test Parameters
initTetherLength = 400;                                     %   m - Initial tether length
maxTetherLength = 400;
flwSpd = .25;                                               %   m/s - Flow speed
reelSpeed = .25;
simulationTime = 5000;
lengthScaleFactors = 0.8;                                   %   Factor to scale DOE kite to Manta Ray
el = 30*pi/180;                                             %   rad - Mean elevation angle
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components

loadComponent('LaRController');                             %   Launch and recovery controller
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('pathFollowingGndStn');                       %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('shortTether');                               %   Tether for reeling
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
loadComponent('Manta2RotAVL_Thr075');                       %   Vehicle with 2 rotors

%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
ENVIRONMENT = 'environmentManta2Rot';                       %   Two turbines

%%  Set basis parameters for high level controller
% loadComponent('constEllipse');                            %   High level controller
loadComponent('constBoothLem');                             %   High level controller
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,initTetherLength],'[rad rad rad rad m]') % Lemniscate of Booth

%%  Ground Station Properties
gndStn.setPosVec([0 0 0],'m')
gndStn.setVelVec([0 0 0],'m/s')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%%  Vehicle Properties
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(env.water.flowVec.Value))
vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
vhcl.setInitEulAng([0,0,0]*pi/180,'rad')

%%  Tethers Properties

%Tether Initial Conditions
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.maxLength.setValue(maxTetherLength,'m');
thr.tether1.initTetherLength.setValue(initTetherLength,'m');

%Tether Properties
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.density.setValue(env.water.density.Value,'kg/m^3');


%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(reelSpeed,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
fltCtrl.setFirstSpoolLap(1000,'');
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);

%%  Steady-flight controller parameters
vhcl.setInitEulAng([0,0,0]*pi/180,'rad');
fltCtrl.LaRelevationSP.setValue(35,'deg');          fltCtrl.LaRelevationSPErr.setValue(1,'deg');        %   Elevation setpoints
fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.001,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller
fltCtrl.elevCmd.kp.setValue(200,'(deg)/(rad)');     fltCtrl.elevCmd.ki.setValue(5,'(deg)/(rad*s)');    %   Elevation angle inner-loop controller
fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
fltCtrl.setNomSpoolSpeed(reelSpeed,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
wnch.winch1.elevError.setValue(2,'deg');
vhcl.turb1.setPowerCoeff(0,'');

tRef = [0  250 500 750 1000 1250 1500 1750 2000 2250 2500 2750 3000];
pSP =  [30 30  30  30  30   40   40   40   40   40   40   40   40];
% vhcl.rBridle_LE.setValue([0,0,0]','m');
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(simulationTime,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')

%%  Log Results
tsc = signalcontainer(logsout);
dt = datestr(now,'mm-dd_HH-MM');
filename = sprintf(strcat('PitchStep_kp-%.1f_ki-%.1f_',dt,'.mat'),fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','LaR\');

%% Plot Tension
figure(5)
clear('AirTen1')
clear('GndTen1')
for jj = 1:size(tsc.airTenVecs.Data(:,:),2)
    AirTen1(1,jj) = norm(tsc.airTenVecs.Data(:,jj));
    GndTen1(1,jj) = norm(tsc.gndNodeTenVecs.Data(:,jj));
end 

hold on
plot(tsc.airTenVecs.Time,AirTen1,'g')
title('Kite Tension for Reel In')
hold on
plot(tsc.gndNodeTenVecs.Time,GndTen1)%,'m')
%yyaxis right;
%plot(tsc.tetherLengths.Time,tsc.tetherLengths.Data(1,:),'r')
%plot(tsc.tetherLengths.Time,ceil(tsc.tetherLengths.Data(1,:).*.01).*100,'b')
%plot(tsc.tetherLengths.Time,ceil(tsc.tetherLengths.Data(1,:).*.01).*100)
hold off
ylabel('Tension (N)')
%set(gca,'YColor','k');
%yyaxis left;
title('Kite and Ground Tension')
xlabel('Time (s)')
ylabel('Force (N)')
legend('Air Tension tether','Ground Tension','Tether Length','Links Reeled Out')
xlim([250,5000])

%% Plotting Other
%Euler Angles
figure(1)
subplot(3,1,1)
plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(1,:))
title('Euler Angles')
subplot(3,1,2)
plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(2,:))
hold on
subplot(3,1,3)
plot(tsc.eulerAngles.Time,tsc.eulerAngles.Data(3,:))
hold on
%legend('Current tether','New Tether')
xlabel('Time (s)')
ylabel('Angle (rad)')

%Positions
figure(2)
subplot(3,1,1)
plot(tsc.positionVec.Time,tsc.positionVec.Data(1,:))
hold on
title('Kite Positions')
subplot(3,1,2)
plot(tsc.positionVec.Time,tsc.positionVec.Data(2,:))
hold on
subplot(3,1,3)
plot(tsc.positionVec.Time,tsc.positionVec.Data(3,:))
hold on
%legend('Current tether','New Tether')
xlabel('Time (s)')
ylabel('Position (m)')
%Velocities
figure(3)
subplot(3,1,1)
plot(tsc.velocityVec.Time,tsc.velocityVec.Data(1,:))
hold on
title('Kite Velocities')
subplot(3,1,2)
plot(tsc.velocityVec.Time,tsc.velocityVec.Data(2,:))
hold on
subplot(3,1,3)
plot(tsc.velocityVec.Time,tsc.velocityVec.Data(3,:))
hold on
%legend('Current tether','New Tether')
xlabel('Time (s)')
ylabel('Velocity (m/s)')
%Angular Velocities
figure(4)
subplot(3,1,1)
plot(tsc.angularVel.Time,tsc.angularVel.Data(1,:))
hold on
title('Kite Angular Velocities')
subplot(3,1,2)
plot(tsc.angularVel.Time,tsc.angularVel.Data(2,:))
hold on
subplot(3,1,3)
plot(tsc.angularVel.Time,tsc.angularVel.Data(3,:))
hold on
%legend('Current tether','New Tether')
xlabel('Time (s)')
ylabel('Ang Vel (rad/sec)')

%%  Animate Results
%vhcl.animateSim(tsc,.5,'SaveGif',true,'zoom',true)
%vhcl.animateSim(tsc,2,'SaveGif',true,'View',[71,0])
vhcl.animateSim(tsc,2,'SaveGif',false)



