%% Test script for John to control the kite model
clear;clc;
Simulink.sdi.clear
%%  Select sim scenario
%   0 = fig8;   1.a = fig8-2rot;   2.a = fig8-winch;   3.a = Steady   4.a = LaR
simScenario = 1.0;
%%  Set Test Parameters
saveSim = 1;                                                %   Flag to save results
thrLength = 400;                                            %   m - Initial tether length
flwSpd = .3;                                                %   m/s - Flow speed
el = 30*pi/180;                                             %   rad - Mean elevation angle
Tmax = 30;                                                  %   kN - Max tether tension 
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
if simScenario >= 4
    loadComponent('LaRController');                         %   Launch and recovery controller
elseif simScenario >= 3 && simScenario < 4
    loadComponent('SteadyController');                      %   Steady-flight controller
elseif simScenario == 2
    loadComponent('pathFollowingCtrlForILC');               %   Path-following controller with spooling
else
    loadComponent('pathFollowWithAoACtrl');                 %   Path-following controller with AoA control
end
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('MantaGndStn');                               %   Ground station
loadComponent('winchManta');                                %   Winches
if simScenario >= 4
    loadComponent('shortTether');                           %   Tether for reeling
    thr.tether1.setInitTetherLength(thrLength,'m');         %   Initialize tether length 
else
    loadComponent('MantaTether');                           %   Manta Ray tether
end
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
if simScenario == 0
    loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
elseif simScenario == 2
    loadComponent('fullScale1thr');                                     %   DOE kite
elseif simScenario == 1 || simScenario == 3 || simScenario == 4
    loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
elseif simScenario == 1.1 || simScenario == 3.1 || simScenario == 4.1
    loadComponent('Manta2RotXFoil_AR9_b9');                             %   AR = 9; 9m span
elseif simScenario == 1.2 || simScenario == 3.2 || simScenario == 4.2
    loadComponent('Manta2RotXFoil_AR9_b10');                            %   AR = 9; 10m span
elseif simScenario == 1.3 || simScenario == 3.3 || simScenario == 4.3
    loadComponent('Manta2RotXFoil_AR8_b8');                             %   AR = 8; 8m span
elseif simScenario == 1.4 || simScenario == 3.4 || simScenario == 4.4
    error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
elseif simScenario == 1.5 || simScenario == 3.5 || simScenario == 4.5
    error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
elseif simScenario == 1.6 || simScenario == 3.6 || simScenario == 4.6
    error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
elseif simScenario == 1.7 || simScenario == 3.7 || simScenario == 4.7
    error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
elseif simScenario == 1.8 || simScenario == 3.8 || simScenario == 4.8
    error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
elseif simScenario == 1.9 || simScenario == 3.9 || simScenario == 4.9
    error('Kite doesn''t exist for simScenario %.1f\n',simScenario)
end
%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');               %   m/s - Flow speed vector
if simScenario == 0
    ENVIRONMENT = 'environmentManta';                       %   Single turbine
elseif simScenario == 2
    ENVIRONMENT = 'environmentDOE';                         %   No turbines
else
    ENVIRONMENT = 'environmentManta2Rot';                   %   Two turbines
end
%%  Set basis parameters for high level controller
if simScenario ~= 1.3
    loadComponent('constBoothLem');                             %   High level controller
else
    loadComponent('varAltitudeBooth');                             %   High level controller
    omega = 0.005;
    fpath = fullfile(fileparts(which('OCTProject.prj')),'output','Tmax Study\');
    maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
    hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
    hiLvlCtrl.ELctrl.setValue(2,'');
    hiLvlCtrl.ThrCtrl.setValue(1,'');
    hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
end
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
%%  Vehicle Properties
vhcl.setICsOnPath(.05,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))
if simScenario >= 3
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
    vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
end
%%  Tethers Properties
load('C:\Users\John Jr\Desktop\Manta Ray\Model 9_28\vehicleDesign\Tether\tetherDataNew.mat')
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(eval(sprintf('AR8b8.length600.tensionValues%d.outerDiam',Tmax)),'m');
% thr.tether1.setDensity(env.water.density.Value,thr.tether1.density.Unit);
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
fltCtrl.rudderGain.setValue(0,'')
if simScenario >= 4
    fltCtrl.LaRelevationSP.setValue(35,'deg');          fltCtrl.setNomSpoolSpeed(.25,'m/s');
end
if simScenario >= 3 && simScenario < 4
    fltCtrl.elevCmd.kp.setValue(0,'(deg)/(rad)');       fltCtrl.elevCmd.ki.setValue(0,'(deg)/(rad*s)');
    fltCtrl.pitchCtrl.setValue(0,'');                   fltCtrl.pitchConst.setValue(-10,'deg');
    fltCtrl.pitchTime.setValue(0:500:2000,'s');         fltCtrl.pitchLookup.setValue(-10:5:10,'deg');
elseif simScenario >= 1 && simScenario < 2
    fltCtrl.AoASP.setValue(2,'');                       fltCtrl.AoAConst.setValue(vhcl.optAlpha.Value*pi/180,'deg');
    fltCtrl.alphaCtrl.kp.setValue(.3,'(kN)/(rad)');     fltCtrl.Tmax.setValue(Tmax,'kN');
    fltCtrl.elevCtrl.kp.setValue(200,'(deg)/(rad)');    fltCtrl.elevCtrl.ki.setValue(1,'(deg)/(rad*s)');
elseif simScenario == 0
    vhcl.turb1.setDiameter(.0,'m');     vhcl.turb2.setDiameter(.0,'m')
end
vhcl.setBuoyFactor(getBuoyancyFactor(vhcl,env,thr),'');
% vhcl.turb1.setDiameter(.72,'m');     vhcl.turb2.setDiameter(.72,'m')
% thr.tether1.setDragEnable(false,'');
%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(2000,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')
%%  Log Results
tsc = signalcontainer(logsout);
if simScenario < 2 && simScenario >= 1
    Pow = tsc.rotPowerSummary(vhcl,env);
    [Idx1,Idx2] = tsc.getLapIdxs(max(tsc.lapNumS.Data)-1);  ran = Idx1:Idx2;
    AoA = mean(squeeze(tsc.vhclAngleOfAttack.Data(:,:,ran)));
    airNode = squeeze(sqrt(sum(tsc.airTenVecs.Data.^2,1)))*1e-3;
    gndNode = squeeze(sqrt(sum(tsc.gndNodeTenVecs.Data.^2,1)))*1e-3;
    ten = max([max(airNode(:)) max(gndNode(:))]);
    fprintf('Average AoA = %.3f;\t Max Tension = %.1f kN\n\n',AoA,ten);
end
dt = datestr(now,'mm-dd_HH-MM');
if simScenario == 0
    filename = sprintf(strcat('Manta_EL-%.1f_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta\');
elseif simScenario > 0 && simScenario < 2
%     filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_D-%.2f_R-%.2f_',dt,'.mat'),simScenario,flwSpd,el*180/pi,vhcl.turb1.diameter.Value,hiLvlCtrl.ELslew.Value);
    filename = sprintf(strcat('Turb%.1f_V-%.3f_EL-%.1f_D-%.2f_AoA-%.2f_',dt,'.mat'),simScenario,flwSpd,el*180/pi,vhcl.turb1.diameter.Value,vhcl.optAlpha.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Rotor\');
elseif simScenario == 2
    filename = sprintf(strcat('Winch_EL-%.1f_Thr-%d_w-%.1f_h-%.1f_',dt,'.mat'),el*180/pi,thrLength,w*180/pi,h*180/pi);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Winch\');
elseif simScenario >= 3 && simScenario < 4
    filename = sprintf(strcat('Steady%.1f_EL-%.1f_kp-%.2f_ki-%.2f_',dt,'.mat'),simScenario,el*180/pi,fltCtrl.elevCmd.kp.Value,fltCtrl.elevCmd.ki.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','Steady\');
elseif simScenario >= 4
    filename = sprintf(strcat('LaR%.1f_EL-%.1f_SP-%.1f_t-%.1f_Wnch-%.1f_',dt,'.mat'),simScenario,el*180/pi,fltCtrl.LaRelevationSP.Value,simParams.duration.Value,fltCtrl.nomSpoolSpeed.Value);
    fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');
end
if saveSim == 1
    save(strcat(fpath,filename),'tsc','vhcl','thr','fltCtrl','env','simParams','LIBRARY','gndStn')
end
%%  Plot Results
if simScenario < 3
    lap = max(tsc.lapNumS.Data)-1;
    if max(tsc.lapNumS.Data) < 2
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    else
        tsc.plotFlightResults(vhcl,env,'plot1Lap',1==0,'plotS',1==1,'lapNum',lap,'dragChar',1==0)
    end
else
    tsc.plotLaR(fltCtrl,'Steady',simScenario >= 3 && simScenario < 4);
end
%%
figure; subplot(1,3,1); hold on; grid on;
plot(tsc.basisParams.Time,squeeze(tsc.basisParams.Data(3,:,:))*180/pi,'r-'); xlabel('Time [s]'); ylabel('Elevation [deg]');
plot(tsc.elevationAngle.Time,squeeze(tsc.elevationAngle.Data),'b-'); xlabel('Time [s]'); ylabel('Elevation [deg]');
legend('Setpoint','Actual','location','northwest')
subplot(1,3,2); hold on; grid on;
plot(tsc.tetherLengths.Time,squeeze(tsc.tetherLengths.Data),'b-'); xlabel('Time [s]'); ylabel('Tether Length [m]');
subplot(1,3,3); hold on; grid on;
plot(tsc.positionVec.Time,squeeze(tsc.positionVec.Data(3,1,:)),'b-'); xlabel('Time [s]'); ylabel('Altitude [m]');
%%  Animate Simulation
% if simScenario <= 2
    vhcl.animateSim(tsc,5,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',15,...
        'GifTimeStep',.01,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
        'ZoomIn',1==0,'SaveGif',1==1,'GifFile',strrep(filename,'.mat','.gif'));
% else
%     vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==0,...
%         'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==0,...
%         'SaveGif',1==1,'GifFile',strrep(filename,'.mat','zoom.gif'));
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