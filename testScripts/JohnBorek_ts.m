%% Test script for John to become familiar with the kite model 
clear;clc;%close all
%%  Select sim scenario 
simScenario = 3;                    %   0 = fig8;   1 = fig8-rotor;   2 = fig8-winch
                                    %   3 = steady; 4 = reel-in/out
%%  Set Physical Test Parameters
thrLength           = 400;
flwSpd              = .5;
lengthScaleFactors  = 0.8;
el = 45*pi/180;                     %   rad - Mean elevation angle 
w = 40*pi/180;                      %   rad - Path width
h = 6.2*pi/180;                     %   rad - Path height 
[a,b] = boothParamConversion(w,h);  %   Path basis parameters 
%%  Set up critical system parameters
simParams = SIM.simParams;
simParams.setDuration(1000,'s');
dynamicCalc = '';
%%  Load components
%   Flight Controller 
switch simScenario
    case 3
        loadComponent('baselineSteadyLevelFlight');
    case 4
        loadComponent('newSpoolCtrl');
    otherwise
        loadComponent('pathFollowingCtrlForManta');
end
fltCtrl.rudderGain.setValue(0,'')

%   Ground station controller
loadComponent('oneDoFGSCtrlBasic');

%   High level controller
loadComponent('constBoothLem');

%   Ground station
loadComponent('pathFollowingGndStn');

%   Winches
loadComponent('oneDOFWnch');

%   Tether
switch simScenario
    case 4
        loadComponent('shortTether');
    otherwise 
        loadComponent('pathFollowingTether');
end

%   Sensors
loadComponent('idealSensors')

%   Sensor processing
loadComponent('idealSensorProcessing')

%   Vehicle
loadComponent('MantaFullScale1thr');

%   Environment
if simScenario == 3 || simScenario == 4
    loadComponent('ConstXYZT');
else
    loadComponent('ConstXYZT');
end
%%  Scale everything to Manta Ray, except environment and sim params
fltCtrl.scale(lengthScaleFactors,1);
gndStn.scale(lengthScaleFactors,1);
hiLvlCtrl.scale(lengthScaleFactors,1);
vhcl.scale(lengthScaleFactors,1);
wnch.scale(lengthScaleFactors,1);
thr.scale(lengthScaleFactors,1);
env.scale(lengthScaleFactors,1);
%%  Environment IC's and dependant properties
env.water.setflowVec([flwSpd 0 0],'m/s')
%%  Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue(...
    [a,b,el,0*pi/180,thrLength],...
    '[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.setVelVec([0 0 0],'m/s')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%%  Set vehicle initial conditions
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(env.water.flowVec.Value))
if simScenario == 3 || simScenario == 4
    vhcl.setICsOnPath(.0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,5,0]*pi/180,'rad')
end
%%  Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%%  Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
if simScenario == 0 || simScenario == 1 || simScenario == 3
    fltCtrl.setFirstSpoolLap(1000,'');
end
%% Hack things to make it run at lower flow speeds
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
thr.tether1.setDiameter(0.007,thr.tether1.diameter.Unit);
thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
%% Steady-flight controller parameters 
if simScenario == 3
    fltCtrl.pitchMoment.kp.setValue(5,'(N*m)/(rad)');
    fltCtrl.pitchMoment.ki.setValue(5,'(N*m)/(rad*s)');
    fltCtrl.pitchMoment.kd.setValue(0,'(N*m)/(rad/s)');
    fltCtrl.pitchMoment.tau.setValue(.01,'s');
end
%% Run Simulation
simWithMonitor('OCTModel')
%% Log Results 
tsc = signalcontainer(logsout);
dt = datestr(now,'mm-dd_HH-MM');
switch simScenario
    case 0
        filename = sprintf(strcat('Manta_V-%.2f_Thr-%d_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
    case 1
        filename = sprintf(strcat('Manta_turb_V-%.2f_Thr-%d_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
    case 2
        filename = sprintf(strcat('Manta_winch_V-%.2f_Thr-%d_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Winch\');
    case 3
        filename = sprintf(strcat('Manta_steady_V-%.2f_kp-%.2f_ki-%.2f_kd-%.2f_',dt,'.mat'),flwSpd(1),fltCtrl.pitchMoment.kp.Value,fltCtrl.pitchMoment.ki.Value,fltCtrl.pitchMoment.kd.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Steady\');
    case 4
        filename = sprintf(strcat('Manta_LaR_V-%.2f_Thr-%d_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','LaR\');
end
save(strcat(fpath,filename),'tsc')
%%  Animate Simulation 
% vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
%     'GifTimeStep',.02,'PlotTracer',true,'FontSize',12,...
%     'Pause',false,'ZoomIn',false,'SaveGif',false,'GifFile',filename);
vhcl.animateSim(tsc,2,'View',[0,0],'FigPos',[488-1500 342 560 420],...
    'GifTimeStep',.02,'PlotTracer',true,'FontSize',12,...
    'Pause',false,'ZoomIn',false,'SaveGif',false,'GifFile',filename);
%%  Plot Flight Control
figure()
subplot(3,2,1)
hold on;    grid on
plot(tsc.elevationAngle.Time,tsc.elevationSP.Data*ones(numel(tsc.elevationAngle.Time),1),'r-');
plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data)*180/pi,'b-');
ylabel('Elevation [deg]');
legend('$\Theta_\mathrm{des}$','$\Theta_\mathrm{act}$')
subplot(3,2,3)
hold on;    grid on
plot(tsc.elevCmd.Time,squeeze(tsc.elevCmd.Data),'b-');
ylabel('Elevator [deg]');
subplot(3,2,5)
hold on;    grid on
% plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,1,:))*180/pi,'b-');
plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(2,1,:))*180/pi,'r-');
plot(tsc.eulerAngles.Time,tsc.pitchSP.Data*ones(numel(tsc.eulerAngles.Time),1),'r--');
legend('Pitch','Pitch SP')
xlabel('Time [s]'); ylabel('Angle [deg]');
subplot(3,2,2)
hold on;    grid on
plot(tsc.airTenVecs.Time,squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1))),'r-');
plot(tsc.gndNodeTenVecs.Time,squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1))),'b--');
ylabel('Tension [N]');
legend('Kite','Gnd')
subplot(3,2,4)
hold on;    grid on
plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(1,1,:)),'r-');
plot(tsc.FNetBdy.Time,squeeze(tsc.FNetBdy.Data(3,1,:)),'b-');
ylabel('Net Force [N]');
legend('$F_b^x$','$F_b^z$')
subplot(3,2,6)
hold on;    grid on
plot(tsc.FDragBdy.Time,squeeze(sqrt(sum(tsc.FLiftBdy.Data.^2,1)))./squeeze(sqrt(sum(tsc.FDragBdy.Data.^2,1))))
xlabel('Time [s]'); ylabel('L/D');
%%  Plot Angle of attack 
% figure()
% subplot(4,1,1)
% hold on;    grid on
% plot(tsc.alphaLocal.Time(1:500),squeeze(tsc.alphaLocal.Data(1,1,1:500)),'b-');   
% ylabel('Port [rad]');   title('Angle of Attack')
% subplot(4,1,2)
% hold on;    grid on
% plot(tsc.alphaLocal.Time(1:500),squeeze(tsc.alphaLocal.Data(1,2,1:500)),'b-');   
% ylabel('Starboard [rad]');
% subplot(4,1,3)
% hold on;    grid on
% plot(tsc.alphaLocal.Time(1:500),squeeze(tsc.alphaLocal.Data(1,3,1:500)),'b-');   
% ylabel('Elevator [rad]');
% subplot(4,1,4)
% hold on;    grid on
% plot(tsc.alphaLocal.Time(1:500),squeeze(tsc.alphaLocal.Data(1,4,1:500)),'b-');   
% ylabel('Rudder [rad]');
% xlabel('Time [s]');



