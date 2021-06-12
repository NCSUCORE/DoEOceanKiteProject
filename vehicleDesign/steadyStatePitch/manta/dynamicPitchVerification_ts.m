%% Test script for John to control the kite model
clear; clc;
Simulink.sdi.clear

t_run             = 1000;
nodes             = 5;
waterDensity      = 1028;
ELEVATOR_HARDCODE = 0;

%%     
thrLength = 400;  altitude = thrLength/(3.05/3);               %   m/m - Initial tether length/operating altitude
flwSpd = 0.025;                                               %   m/s - Flow speed
Tmax = 20;        Tdiam = 0.0125;                           %   kN/m - Max tether tension/tether diameter 
h = 10*pi/180;  w = 40*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
amp = 0.10;  freq = 0.05*2*pi;   

%%  Load components
loadComponent('Manta2RotXFoil_AR8_b8');             %   AR = 8; 8m span


loadComponent('constBoothLem');                     %   Constant basis parameters
el = asin(altitude/thrLength);                      %   rad - Initial elevation angle
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,... %   Initialize basis parameters
    thrLength],'[rad rad rad rad m]');

loadComponent('LaRController');                     %   Launch and recovery controller

loadComponent('MantaTether');                       %   Manta Ray tether
%loadComponent('shortTether');                       %   Tether for reeling
%thr.tether1.setInitTetherLength(thrLength,'m');     %   Initialize tether length

loadComponent('ConstXYZT');                         %   Constant flow
ENVIRONMENT = 'environmentManta2Rot';               %   Two turbines
env.water.setflowVec([flwSpd 0 0],'m/s');           %   m/s - Flow speed vector
env.water.density.setValue(waterDensity,'kg/m^3')

loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('MantaGndStn');                               %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing

%%  Vehicle Initial Conditions 
vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,0)
vhcl.setInitEulAng([0,0,0]*pi/180,'rad')
    
%%  Tethers Properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)+gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(3.7e10,'Pa');
thr.tether1.density.setValue(2226,'kg/m^3');
thr.tether1.setDiameter(Tdiam,'m');
%thr.tether1.setMaxLength(thrLength,'m');
%thr.setNumNodes(nodes,'');

%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');

%%  Controller User Def. Parameters and dependant properties
fltCtrl.LaRelevationSP.setValue(60,'deg');          
fltCtrl.setNomSpoolSpeed(.0,'m/s');
vhcl.setBuoyFactor(1.0391,'');

%% Set Center of Mass
%CM_Correct = 0.011730865432716;
CM_Correct = 0.0205;
vhcl.setRCM_LE([8.8444775e-01 + CM_Correct;...
                0             ;...
                3.1365427e-02 ],'m')
vhcl.setRCentOfBuoy_LE(vhcl.rCM_LE.Value - [CM_Correct;0;0],'m');
vhcl.setRBridle_LE([vhcl.rCentOfBuoy_LE.Value(1)-.3;0;-vhcl.fuse.diameter.Value/2],'m');


%%  Set up critical system parameters and run simulation
simParams = SIM.simParams;  simParams.setDuration(t_run,'s');  dynamicCalc = '';
simWithMonitor('OCTModel')

%%  Log Results
tsc = signalcontainer(logsout);

filename = sprintf(strcat('LaR_V-%.3f_EL-%.1f_SP-%.1f_Wnch-%.1f.mat'),flwSpd,el*180/pi,fltCtrl.LaRelevationSP.Value,fltCtrl.nomSpoolSpeed.Value);
fpath = fullfile(fileparts(which('OCTProject.prj')),'Results','Manta 2.0','LaR\');

%%  Plot Results
%tsc.plotLaR(fltCtrl,'Steady',true);

figure(1)
subplot(2,1,1)
plot(squeeze(tsc.elevationAngle.Time),squeeze(tsc.elevationAngle.Data))
title('Total Elevation (deg)')
subplot(2,1,2)
plot(squeeze(tsc.pitch.Time),squeeze(tsc.pitch.Data)*(180/pi))
title('Pitch (deg)')

figure(2)
hold on
plot(squeeze(tsc.pitch.Time),squeeze(tsc.pitch.Data)*(180/pi))
hold off

%%  Animate Simulation
vhcl.animateSim(tsc,2,'View',[0,0],'Pause',1==0,...
    'GifTimeStep',.05,'PlotTracer',true,'FontSize',12,'ZoomIn',1==1,...
    'SaveGif',1==1,'GifFile',strrep(filename,'.mat','zoom.gif'));














