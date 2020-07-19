%% Test script for John to control the kite model 
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario 
%   0 = fig8;   1 = fig8-rotor;   1.1 = fig8-2rotor;   2 = fig8-winch;   3 = steady;  4 = reel-in/out
simScenario = 0;
%%  Set Physical Test Parameters
thrLength = 400;                                            %   m - Initial tether length 
flwSpd = .25;                                               %   m/s - Flow speed 
lengthScaleFactors = 0.8;                                   %   Factor to scale DOE kite to Manta Ray 
el = 10*pi/180;                                             %   rad - Mean elevation angle 
w = 40*pi/180;  h = 6.2*pi/180;                             %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters 
%%  Load components
switch simScenario                                          %   Flight Controller 
    case 3                              
        loadComponent('baselineSteadyLevelFlight');         %   Steady-level flight 
    case 4
        loadComponent('LaRController');                     %   Launch and recovery 
        minLinkDeviation = .1;                              
        minSoftLength = 0;                                  
        minLinkLength = 1;                                  %   Length at which tether rediscretizes
    otherwise
        loadComponent('pathFollowingCtrlForManta');
end
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('constBoothLem');                             %   High level controller
loadComponent('pathFollowingGndStn');                       %   Ground station
loadComponent('winchManta');                                %   Winches
switch simScenario                                          %   Tether
    case 4
        loadComponent('shortTether');                       %   Tether for reeling
    otherwise 
        loadComponent('pathFollowingTether');               %   Single link tether
end
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
if mod(simScenario,1) == 0
    loadComponent('Manta1thr1rot');                         %   Vehicle with 1 rotor 
else
    loadComponent('Manta1thr2rot');                         %   Vehicle with 2 rotors
end
loadComponent('ConstXYZT');                                 %   Environment
%%  Scale everything to Manta Ray, except environment and sim params
fltCtrl.scale(lengthScaleFactors,1);
gndStn.scale(lengthScaleFactors,1);
hiLvlCtrl.scale(lengthScaleFactors,1);
vhcl.scale(lengthScaleFactors,1);
wnch.scale(lengthScaleFactors,1);
thr.scale(lengthScaleFactors,1);
env.scale(lengthScaleFactors,1);
%%  Environment Properties 
env.water.setflowVec([flwSpd 0 0],'m/s')
%%  Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
gndStn.setPosVec([0 0 0],'m')
gndStn.setVelVec([0 0 0],'m/s')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%%  Vehicle Properties 
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(env.water.flowVec.Value))
if simScenario == 3 || simScenario == 4
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
end
if simScenario ~= 1 && simScenario ~= 1.1
    vhcl.setTurbDiam(0,'m')
elseif simScenario == 1.1
    vhcl.setTurbDiam(.56,'m')
    vhcl.turbines(1,1).setDragCoeff(.75,'')
end
%%  Tethers Properties
if simScenario == 4
    thr.tether1.setInitGndNodePos(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
    thr.tether1.setInitAirNodePos(vhcl.initPosVecGnd.Value(:)...
        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
    thr.tether1.setInitGndNodeVel([0 0 0]','m/s');
    thr.tether1.setInitAirNodeVel(vhcl.initVelVecBdy.Value(:),'m/s');
    thr.tether1.setVehicleMass(vhcl.mass.Value,'kg');
else
    thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
    thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
        +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
    thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
    thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
end
thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
thr.tether1.setDiameter(0.007,thr.tether1.diameter.Unit);
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
end
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.setElevatorReelInDef(0,'deg')
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,fltCtrl.tanRoll.kp.Unit);
%%  Steady-flight controller parameters 
if simScenario >= 3
    fltCtrl.pitchSP.kp.setValue(3,'(deg)/(deg)');
    fltCtrl.pitchSP.ki.setValue(.1,'(deg)/(deg*s)');
    fltCtrl.pitchSP.kd.setValue(0,'(deg)/(deg/s)');
    fltCtrl.pitchSP.tau.setValue(.01,'s');
    
    fltCtrl.elevCmd.kp.setValue(5,'(deg)/(rad)');
    fltCtrl.elevCmd.ki.setValue(5,'(deg)/(rad*s)');
    fltCtrl.RelevationSP.setValue(35,'deg')
    fltCtrl.pitchAngleMax.upperLimit.setValue(25,'')
%     vhcl.rCentOfBuoy_LE.setValue([.015,0,.0546]','m')
end
tRef = 0:10000:170000;     
pSP = [linspace(0,16,9) linspace(16,0,9)];
% pSP = linspace(1,1,numel(tRef))*5;
% vhcl.rBridle_LE.setValue([0,0,0]','m')
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(1500,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
%%  Log Results 
tsc = signalcontainer(logsout);
dt = datestr(now,'mm-dd_HH-MM');
switch simScenario
    case 0
        filename = sprintf(strcat('Manta_V-%.2f_Thr-%d_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
    case 1
        filename = sprintf(strcat('Turb_V-%.2f_D-%.2f_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),vhcl.turbines(1,1).diameter.Value,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
    case 1.1
        filename = sprintf(strcat('Turb2_V-%.2f_D-%.2f_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),vhcl.turbines(1,1).diameter.Value,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
    case 2
        filename = sprintf(strcat('Winch_V-%.2f_Thr-%d_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),thrLength,w*180/pi,h*180/pi);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Winch\');
    case 3
        filename = sprintf(strcat('Steady_V-%.2f_kp-%.2f_ki-%.2f_kd-%.2f_',dt,'.mat'),flwSpd(1),fltCtrl.pitchMoment.kp.Value,fltCtrl.pitchMoment.ki.Value,fltCtrl.pitchMoment.kd.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Steady\');
    case 4
%         filename = sprintf(strcat('Manta_LaR_V-%.2f_Thr-%d_w-%.2f_h-%.2f_',dt,'.mat'),flwSpd(1),thrLength,w*180/pi,h*180/pi);
        filename = sprintf(strcat('LaR_kp-%.1f_ki-%.1f_kd-%.1f_tau-%.2f_',dt,'.mat'),fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value,fltCtrl.elevCmd.kd.Value,fltCtrl.elevCmd.tau.Value);
        fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','LaR\');
end
% save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams')
% save(strcat(fpath,filename),'tsc','-v7.3')
%%  Animate Simulation 
if simScenario <= 2
    vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
        'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',false,...
        'ZoomIn',false,'SaveGif',false,'GifFile',strrep(filename,'.mat','.gif'));
else
    vhcl.animateSim(tsc,2,'View',[0,0],'FigPos',[-6.2 33.8 1550.4 838.4],...
        'GifTimeStep',.1,'PlotTracer',true,'FontSize',12,'ZoomIn',true,...
        'SaveGif',true,'GifFile',strrep(filename,'.mat','2.gif'));
end
%%  Plot Results
if simScenario == 1 || simScenario == 1.1
    plotTurbResults(tsc,vhcl,'plotS',true,'lap2',false);   
    set(gcf,'OuterPosition',[-6.2 33.8 1550.4 838.4]);
elseif simScenario >=3
    hh = plotFlightResults(tsc,vhcl);   
    set(gcf,'OuterPosition',[-6.2 33.8 1550.4 838.4]);
elseif simScenario == 0
    plotLapResults(tsc,vhcl,'plotS',true,'lap2',false);   
end