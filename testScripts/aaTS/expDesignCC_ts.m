%% Test script for John to control the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Select sim scenario
%   0 = fig8;   1.a = fig8-2rot;   2.a = fig8-winch;   3.a = Steady   4.a = LaR

%%  Set Test Parameters
saveSim = 0;              %   Flag to save results
runLin = 1;                %   Flag to run linearization
thrArray = 4;%[200:400:600];%:25:600];
altitudeArray = 2;%[100:200:300];%150:25:300];
flwSpdArray = .15;%[0.1:0.1:.5]; 
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
for j = 1:length(thrArray)
    for k = 1:length(flwSpdArray)
thrLength = thrArray(j);  altitude = altitudeArray(j);  elev = atan2(altitude,thrLength);               %   Initial tether length/operating altitude/elevation angle 
flwSpd = flwSpdArray(k) ;                                              %   m/s - Flow speed
Tmax = 38;                                                  %   kN - Max tether tension 
h = 20*pi/180;  w = 90*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = asin(altitude/thrLength);
loadComponent('pathFollowWithAoACtrl');                 %   Path-following controller with AoA control
FLIGHTCONTROLLER = 'pathFollowingControllerMantaBandLin';
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('MantaGndStn');                               %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('MantaTether');                           %   Manta Ray tether
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8_exp2');                             %   AR = 8; 8m span
SIXDOFDYNAMICS = 'sixDoFDynamicsCoupledFossen12Int';
VEHICLE = 'vehicleManta2RotPool';
%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');               %   m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2RotBandLin';                   %   Two turbines
%%  Set basis parameters for high level controller
loadComponent('varAltitudeBooth');                             %   High level controller
hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');

hiLvlCtrl.ELctrl.setValue(1,'');
hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
hiLvlCtrl.ThrCtrl.setValue(1,'');

hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
%%  Vehicle Properties
vhcl.setICsOnPath(.0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,4*flwSpd*norm([1;0;0]))
% vhcl.setVolume(2.77e-3,'m^3');
% Ixx = 2.804660e-2;
% Iyy = 6.2e-2;
% Izz = 8.4e-2;
% Ixy = -0.057487e-2;
% Ixz = -0.025665e-2;
% Iyz = 0.001656e-2;
% 
% vhcl.setInertia_CM([Ixx -Ixy -Ixz;...
%                     -Ixy Iyy -Iyz;...
%                     -Ixz -Iyz Izz],'kg*m^2')
% vhcl.setMa6x6_LE(vhcl.Ma6x6_LE.Value*1,'')
%%  Tethers Properties
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(eval(sprintf('AR8b8.length600.tensionValues%d.outerDiam',Tmax)),'m');
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.elevatorReelInDef.setValue(3,'deg');
fltCtrl.AoACtrl.setValue(1,'');              fltCtrl.RCtrl.setValue(1,'');
fltCtrl.AoASP.setValue(1,'');                       fltCtrl.AoAConst.setValue(6,'deg');
fltCtrl.alphaCtrl.kp.setValue(.3,'(kN)/(rad)');     fltCtrl.Tmax.setValue(Tmax,'kN');
fltCtrl.elevCtrl.kp.setValue(125,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
fltCtrl.rollCtrl.kp.setValue(400,'(deg)/(rad)');    fltCtrl.rollCtrl.kd.setValue(4,'(deg)/(rad/s)');
fltCtrl.rollCtrl.ki.setValue(00,'(deg)/(rad*s)');
fltCtrl.firstSpoolLap.setValue(400,'');              fltCtrl.winchSpeedIn.setValue(.1,'m/s');
fltCtrl.elevCtrlMax.upperLimit.setValue(30,'');      fltCtrl.elevCtrlMax.lowerLimit.setValue(-30,'');
fltCtrl.setPerpErrorVal(.05,'rad')
fltCtrl.rudderGain.setValue(.2,'')
vhcl.hStab.setIncidence(0,'deg');
vhcl.setBuoyFactor(.98,'')
fltCtrl.scale(0.1,1);
fltCtrl.tanRoll.kp.setValue(0.25,'(rad)/(rad)')
fltCtrl.tanRoll.kd.setValue(0.25,'(rad)/(rad/s)')
fltCtrl.maxBank.lowerLimit.setValue(-.78,'')
fltCtrl.maxBank.upperLimit.setValue(.78,'')
thr.tether1.dragEnable.setValue(1,'')
% fltCtrl.setFcnName(PATHGEOMETRY,'');
% fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
% fltCtrl.rudderGain.setValue(0,'')
% fltCtrl.elevatorReelInDef.setValue(3,'deg');
% fltCtrl.AoACtrl.setValue(1,'');                     fltCtrl.RCtrl.setValue(0,'');
% fltCtrl.AoASP.setValue(1,'');                       fltCtrl.AoAConst.setValue(6*pi/180,'deg');
% fltCtrl.alphaCtrl.kp.setValue(.3,'(kN)/(rad)');     fltCtrl.Tmax.setValue(Tmax,'kN');
% fltCtrl.elevCtrl.kp.setValue(0,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(0,'(deg)/(rad*s)');
% fltCtrl.rollCtrl.kp.setValue(200,'(deg)/(rad)');    fltCtrl.rollCtrl.ki.setValue(1,'(deg)/(rad*s)');
% fltCtrl.firstSpoolLap.setValue(100,'');              fltCtrl.winchSpeedIn.setValue(.1,'m/s');
% fltCtrl.elevCtrlMax.upperLimit.setValue(8,'');      fltCtrl.elevCtrlMax.lowerLimit.setValue(0,'');
% vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
% fltCtrl.scale(0.1,1);
% env.scale(0.1,1);
vhcl.rBridle_LE.setValue([0.05;0; -0.2],'m')     
%%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(200,'s');  dynamicCalc = '';
    set_param('OCTModel','SimulationMode','accelerator');
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);
    %%
   
% 
%     Pow = tsc.rotPowerSummary(vhcl,env);
    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
    AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
    ten = max([max(airNode(ran)) max(gndNode(ran))]);
    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
plot(tsc.closestPathVariable.Data(ran),tsc.ctrlSurfDeflCmd.Data(ran,1))
dt = datestr(now,'mm-dd_HH-MM');
%%

% simParams = SIM.simParams;  simParams.setDuration(10000,'s');  dynamicCalc = '';
% simWithMonitor('OCTModel');
% tsc = signalcontainer(logsout);   
% lap = max(tsc.lapNumS.Data)-1;
% tsc.plotFlightError(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    filename = sprintf(strcat('V-%.3f_EL-%.1f_THR-%d.mat'),flwSpd,el*180/pi,thrLength);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Manta\');
if saveSim == 1
    if max(tsc.lapNumS.Data) > 1
    save(strcat(fpath,filename),'vhcl','thr','fltCtrl','env','linsys','simParams','LIBRARY','gndStn','tsc','tsc1','tsc2','tsc3')
    end
end
    end
end
%%  Plot Results
    lap = max(tsc.lapNumS.Data)-1;
    if max(tsc.lapNumS.Data) < 2
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'lapNum',lap,'dragChar',1==0);
    else
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0);
        tsc.plotFlightError(vhcl,env,'plot1Lap',1==1,'plotS',1==1,'lapNum',lap,'dragChar',1==0);
    end

%%  Animate Simulation
% if simScenario <= 2
%     vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
%         'GifTimeStep',0,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%         'SaveGif',1==1,'GifFile','expCross.gif',...
%         'timestep',0.05);
% else
figure; plot(tsc.tanRoll);
figure; plot(tsc.tanRollDes);
    vhcl.animateSim(tsc,.5,'Pause',1==0,'PathFunc',fltCtrl.fcnName.Value,...
        'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0,...
        'PathPosition',true,'SaveGif',1==0,'GifFile','awwSnap.gif');
% end
%%  Compare to old results
% Res = load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\Results\Manta 2.0\Rotor\Turb1.0_V-0.300_EL-30.0_D-0.70_AoA-13.98_10-22_12-29.mat');
% Res.tsc.rotPowerSummary(Res.vhcl,Res.env);
% [Idx1,Idx2] = Res.tsc.getLapIdxs(max(Res.tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
% AoA = mean(squeeze(Res.tsc.vhclAngleOfAttack.Data(:,:,ran)));
% airNode = squeeze(sqrt(sum(Res.tsc.airTenVecs.Data.^2,1)))*1e-3;
% gndNode = squeeze(sqrt(sum(Res.tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
% ten = max([max(airNode(ran)) max(gndNode(ran))]);
% fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n',AoA,ten);
