%% Test script for John to control the kite model 
Simulink.sdi.clear
clear;clc;%close all
%%  Select sim scenario 
%   0 = fig8;   1 = fig8-rotor;   1.1 = fig8-2rotor;   1.2 = fig8-2rotor New Model;
%   2 = fig8-winch;   3 = steady;  4 = LaR;  4.2 = LaR New Model;
simScenario = 4.2;
%%  Set Physical Test Parameters
thrLength = 400;                                            %   m - Initial tether length 
flwSpd = .25;                                               %   m/s - Flow speed 
lengthScaleFactors = 0.8;                                   %   Factor to scale DOE kite to Manta Ray 
el = 40*pi/180;                                             %   rad - Mean elevation angle 
h = 15*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters 
%%  Load components
if simScenario == 3
    loadComponent('baselineSteadyLevelFlight');             %   Steady-level flight controller 
elseif simScenario >= 4
    loadComponent('LaRController');                         %   Launch and recovery controller 
else
    loadComponent('pathFollowingCtrlForManta');             %   Path-following controller 
end
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('pathFollowingGndStn');                       %   Ground station
loadComponent('winchManta');                                %   Winches
if simScenario >= 4
    minLinkDeviation = .1;
    minSoftLength = 0;
    minLinkLength = 1;                                      %   Length at which tether rediscretizes
    loadComponent('shortTether');                           %   Tether for reeling
else
    loadComponent('MantaTether');                           %   Single link tether
end
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
if simScenario == 0  || simScenario == 1 || simScenario == 2 
    loadComponent('MantaKiteNACA2412');                     %   Vehicle with 1 rotor 
elseif simScenario == 1.2 || simScenario == 4.2
    loadComponent('newManta2RotNACA2412');                  %   Vehicle with 2 rotors
else
    loadComponent('Manta2RotNACA2412');                     %   Vehicle with 2 rotors
%     loadComponent('Manta2RotEPP552');                       %   Vehicle with 2 rotors
end
%%  Environment Properties 
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector 
if simScenario == 0 || simScenario == 1 || simScenario == 2 
    ENVIRONMENT = 'environmentManta';                       %   Single turbine 
else
    ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines 
%     ENVIRONMENT = 'environmentManta4Rot';                   %   Four turbines
end
%%  Set basis parameters for high level controller
% loadComponent('constEllipse');                              %   High level controller
loadComponent('constBoothLem');                             %   High level controller
if strcmpi(PATHGEOMETRY,'ellipse')
    hiLvlCtrl.basisParams.setValue([w,h,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Ellipse
else
    hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
end
%%  Ground Station Properties
gndStn.setPosVec([0 0 0],'m')
gndStn.setVelVec([0 0 0],'m/s')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');
%%  Vehicle Properties 
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,(11/2)*norm(env.water.flowVec.Value))
if simScenario >= 3
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
end
if simScenario == 0 || simScenario == 2 
    vhcl.turb1.setDiameter(0,'m')
end
%%  Tethers Properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
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
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad');
    fltCtrl.LaRelevationSP.setValue(45,'deg');          fltCtrl.LaRelevationSPErr.setValue(2,'deg');        %   Elevation setpoints
    fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');    %   Elevation angle outer-loop controller 
    fltCtrl.elevCmd.kp.setValue(200,'(deg)/(rad)');     fltCtrl.elevCmd.ki.setValue(10,'(deg)/(rad*s)');    %   Elevation angle inner-loop controller 
%     fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');       fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
    fltCtrl.pitchAngleMax.upperLimit.setValue(20,'');   fltCtrl.pitchAngleMax.lowerLimit.setValue(-40,'');
    fltCtrl.setNomSpoolSpeed(.00,'m/s');                fltCtrl.setSpoolCtrlTimeConstant(5,'s');
    wnch.winch1.elevError.setValue(2,'deg');
    vhcl.turb1.setPowerCoeff(0,'');
end
tRef = [0 750 1500];  % tRef = [0 2000 4000];   
pSP =  [0 0 0];    
thr.tether1.dragEnable.setValue(0,'');
% vhcl.rBridle_LE.setValue([0,0,0]','m');
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
%%  Log Results 
tsc = signalcontainer(logsout);
dt = datestr(now,'mm-dd_HH-MM');
if simScenario == 0
    filename = sprintf(strcat('Manta_EL-%.1f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
elseif simScenario == 1
    filename = sprintf(strcat('Turb_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
elseif simScenario == 1.1
    filename = sprintf(strcat('Turb2_V-%.2f_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),flwSpd,el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Rotor\');
elseif simScenario == 1.2
    filename = sprintf(strcat('Turb2_V-%.2f_EL-%.1f_D-%.2f_w-%.1f_h-%.1f_',dt,'.mat'),flwSpd,el*180/pi,vhcl.turb1.diameter.Value,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
elseif simScenario == 2
    filename = sprintf(strcat('Winch_EL-%.1f_Thr-%d_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,thrLength,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Winch\');
elseif simScenario == 3
    filename = sprintf(strcat('Steady_EL-%.1f_kp-%.2f_ki-%.2f_kd-%.2f_',dt,'.mat'),el*180/pi,fltCtrl.pitchMoment.kp.Value,fltCtrl.pitchMoment.ki.Value,fltCtrl.pitchMoment.kd.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','Steady\');
elseif simScenario == 4
%     filename = sprintf(strcat('LaR_EL-%.1f_SP-%.1f_t-%.1f_Wnch-%.1f_',dt,'.mat'),el*180/pi,fltCtrl.LaRelevationSP.Value,simParams.duration.Value,fltCtrl.nomSpoolSpeed.Value);
%     filename = sprintf(strcat('Elevation_kp-%.1f_ki-%.2f_',dt,'.mat'),fltCtrl.pitchSP.kp.Value,fltCtrl.pitchSP.ki.Value);
    filename = sprintf(strcat('Pitch_kp-%.1f_ki-%.1f_',dt,'.mat'),fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta','LaR\');
elseif simScenario == 4.2
%     filename = sprintf(strcat('LaR_EL-%.1f_SP-%.1f_t-%.1f_Wnch-%.1f_',dt,'.mat'),el*180/pi,fltCtrl.LaRelevationSP.Value,simParams.duration.Value,fltCtrl.nomSpoolSpeed.Value);
%     filename = sprintf(strcat('Elevation_kp-%.1f_ki-%.2f_',dt,'.mat'),fltCtrl.pitchSP.kp.Value,fltCtrl.pitchSP.ki.Value);
    filename = sprintf(strcat('Pitch_kp-%.1f_ki-%.1f_',dt,'.mat'),fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');
end
save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
% save(strcat(fpath,filename),'tsc','-v7.3')
%%  Animate Simulation 
% if simScenario <= 2
%     vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'Pause',false,...
%         'ZoomIn',false,'SaveGif',1==1,'GifFile',strrep(filename,'.mat','.gif'));
% else
%     vhcl.animateSim(tsc,2,'View',[0,0],...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==1,...
%         'SaveGif',1==0,'GifFile',strrep(filename,'.mat','0.gif'));
% end
%%  Plot Results
if simScenario < 3
    tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'Vapp',false,'plotBeta',false)
%     tsc.plotTanAngles('plot1Lap',true,'plotS',true)
%     tsc.plotPower(vhcl,env,'plot1Lap',true,'plotS',true,'Lap1',1,'Color',[0 0 1],'plotLoyd',false)
else
    tsc.plotLaR;
%     set(gcf,'OuterPosition',[347.4000  192.2000  590.4000  652.0000]);
end
%%  Compare to old results 
% tsc.turbEnrg.Data(1,1,end)
% load('C:\Users\John Jr\Desktop\Manta Ray\Model\Results\Manta\Rotor\Turb2_V-0.25_EL-30.0_D-0.56_w-40.0_h-15.0_08-04_10-56.mat')
% tsc.turbEnrg.Data(1,1,end)
% simStabilityCheck





