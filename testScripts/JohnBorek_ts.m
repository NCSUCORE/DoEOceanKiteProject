%% Test script for John to become familiar with the kite model 
clear;clc;%close all

%%  Set Physical Test Parameters
thrLength           = 400;
flwSpd              = .25;
lengthScaleFactors  = 0.8;
if thrLength >= 100 && thrLength < 200
    a = 0.6;    b = 1.0;
elseif thrLength >= 200 && thrLength < 300
    a = 0.4;    b = 1.0;
elseif thrLength >= 300
    a = 0.35;   b = 1.0;
else
    a = 1.0;    b = 2.2;
end
w = 2*a*180/pi; h = sqrt(-3*a^4+4*a^2*b^2+4*b^4)/a^2;
turbDiameter = 0;%.8;
%% Set up critical system parameters
simParams = SIM.simParams;
simParams.setDuration(2000,'s');
dynamicCalc = '';
%% Load components
% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% loadComponent('pathFollowingCtrlForManta');
% loadComponent('baselineSteadyLevelFlight');
fltCtrl.rudderGain.setValue(0,'')

% Ground station controller
loadComponent('oneDoFGSCtrlBasic');

% High level controller
loadComponent('constBoothLem');

% Ground station
loadComponent('pathFollowingGndStn');

% Winches
loadComponent('oneDOFWnch');

% Tether
% loadComponent('fiveNodeSingleTether');
loadComponent('pathFollowingTether');

% Sensors
loadComponent('idealSensors')

% Sensor processing
loadComponent('idealSensorProcessing')

% Vehicle
if turbDiameter ~= 0
    loadComponent('fullScale1thr');
else
    loadComponent('JohnfullScale1thr');
end

% Environment
loadComponent('ConstXYZT');
%% Scale everything to Manta Ray, except environment and sim params
fltCtrl.scale(lengthScaleFactors,1);
gndStn.scale(lengthScaleFactors,1);
hiLvlCtrl.scale(lengthScaleFactors,1);
vhcl.scale(lengthScaleFactors,1);
wnch.scale(lengthScaleFactors,1);
thr.scale(lengthScaleFactors,1);
env.scale(lengthScaleFactors,1);
%% Environment IC's and dependant properties
env.water.setflowVec([flwSpd 0 0],'m/s')

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue(...
    [a,b,.36,0*pi/180,thrLength],...
    '[rad rad rad rad m]') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.setVelVec([0 0 0],'m/s')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%% Set vehicle initial conditions
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(env.water.flowVec.Value))
% vhcl.setICsOnPath(.0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
vhcl.setTurbDiam(turbDiameter,'m');
% vhcl.setInitEulAng([0,5,0]*pi/180,'rad')
%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
if turbDiameter == 0
    fltCtrl.setFirstSpoolLap(1000,'');
else
    fltCtrl.setFirstSpoolLap(1,'');
end
%% Hack things to make it run at lower flow speeds
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
thr.tether1.setDiameter(0.007,thr.tether1.diameter.Unit);
thr.tether1.setYoungsMod(thr.tether1.youngsMod.Value*1.2,thr.tether1.youngsMod.Unit);
%% Steady-flight controller parameters 
% fltCtrl.pitchMoment.kp.setValue(.5,'(rad)/(rad)');
% fltCtrl.pitchMoment.ki.setValue(0.1,'(rad)/(rad*s)');
% fltCtrl.pitchMoment.kd.setValue(1,'(rad)/(rad/s)');
% fltCtrl.pitchMoment.tau.setValue(.01,'s');
pSP = 1;
%% Run Simulation
simWithMonitor('OCTModel')

%% Log Results 
tsc = signalcontainer(logsout);
dt = datestr(now,'mm-dd_HH-MM');
if vhcl.turbines(1).diameter.Value > 0
    filename = sprintf(strcat('Manta_',dt,'_turb_V-%.1f_Thr-%d_a-%.1f_b-%.1f.mat'),flwSpd,thrLength,a,b);
elseif vhcl.turbines(1).diameter.Value == 0 && fltCtrl.firstSpoolLap.Value == 1
    filename = sprintf(strcat('Manta_',dt,'_winch_V-%.1f_Thr-%d_a-%.1f_b-%.1f.mat'),flwSpd,thrLength,a,b);
else
    filename = sprintf(strcat('MantaSF_',dt,'_V-%.1f_Thr-%d_a-%.1f_b-%.1f.mat'),flwSpd,thrLength,a,b);
end
fpath = 'C:\Users\John Jr\Desktop\Manta Ray\Model\Results\Manta\';
save(strcat(fpath,filename),'tsc')
%%  Animate Simulation 
dt = datestr(now,'mm-dd_HH-MM');
filename = sprintf(strcat('Manta_winch_Thr-%d_V-%.2f_',dt,'.gif'),thrLength(1),flwSpd(1));
vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
    'GifTimeStep',.02,'PlotTracer',true,'FontSize',12,...
    'Pause',false,'ZoomIn',false,'SaveGif',true,'GifFile',filename);
%%  Plot Flight Control
% figure()
% subplot(3,1,1)
% hold on;    grid on
% % plot(tsc.elevationAngle.Time,35*ones(numel(tsc.elevationAngle.Time),1),'r-');
% plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data)*180/pi,'b-');    
% ylabel('Elevation [deg]');
% % legend('$\Theta_\mathrm{des}$','$\Theta_\mathrm{act}$')
% subplot(3,1,2)
% hold on;    grid on
% plot(tsc.eulerAngles.Time,0*ones(numel(tsc.eulerAngles.Time),1),'r-');  
% plot(tsc.eulerAngles.Time,squeeze(tsc.eulerAngles.Data(1,1,:))*180/pi,'b-');  
% ylabel('Roll [deg]');
% legend('$\Phi_\mathrm{des}$','$\Phi_\mathrm{act}$')
% subplot(3,1,3)
% hold on;    grid on
% plot(tsc.eulerAngles.Time,pSP*ones(numel(tsc.eulerAngles.Time),1),'r-');  
% plot(tsc.pitch.Time,squeeze(tsc.pitch.Data(1,1,:))*180/pi,'b-');  
% xlabel('Time [s]'); ylabel('Pitch [deg]');
% legend('$\Theta_\mathrm{des}$','$\Theta_\mathrm{act}$')