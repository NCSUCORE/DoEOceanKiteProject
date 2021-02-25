%% Test script for James to control the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Select sim scenario
%   0 = fig8;   1.a = fig8-2rot;   2.a = fig8-winch;   3.a = Steady   4.a = LaR

%%  Set Test Parameters
saveSim = 0;              %   Flag to save results
runLin = 1;                %   Flag to run linearization
thrArray = 3;%[200:400:600];%:25:600];
altitudeArray = 1.5;%[100:200:300];%150:25:300];
flwSpdArray = .25;%[0.1:0.1:.5]; 
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
for j = 1:length(thrArray)
    for k = 1:length(flwSpdArray)
thrLength = thrArray(j);  altitude = altitudeArray(j);  elev = atan2(altitude,thrLength);               %   Initial tether length/operating altitude/elevation angle 
flwSpd = flwSpdArray(k) ;                                              %   m/s - Flow speed
Tmax = 38;                                                  %   kN - Max tether tension 
h = 25*pi/180;  w = 100*pi/180;                              %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = asin(altitude/thrLength);
loadComponent('pathFollowCtrlExp');                 %   Path-following controller with AoA control
% FLIGHTCONTROLLER = 'pathFollowingControllerExp';
FLIGHTCONTROLLER = 'hiToLoElevationControllerExp';
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('MantaGndStn');                               %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('MantaTether');                           %   Manta Ray tether
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8_exp2');                             %   AR = 8; 8m span
%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');               %   m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2RotBandLin';                   %   Two turbines
    FLOWCALCULATION = 'rampSaturatedXYZT';
    rampSlope = .05; %flow speed ramp rate
%%  Set basis parameters for high level controller
loadComponent('constBoothLem');        %   High level controller
% PATHGEOMETRY = 'lemOfBoothInv'
% hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
% 
% hiLvlCtrl.ELctrl.setValue(1,'');
% hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
% hiLvlCtrl.ThrCtrl.setValue(1,'');

hiLvlCtrl.basisParams.setValue([a,b,-el,0*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
gndStn.posVec.setValue([0 0 3],'m')
%%  Vehicle Properties INITIAL CONDITIONS
% vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value,6.5*flwSpd*norm([1;0;0]))
vhcl.initPosVecGnd.setValue([0;0;0],'m')
vhcl.initAngVelVec.setValue([0;0;0],'rad/s')
vhcl.initVelVecBdy.setValue([0;0;0],'m/s')
vhcl.initEulAng.setValue([0;0;0],'rad')
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
thr.tether1.setDiameter(.0076,'m');
%%  Winches Properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.LaRspeed.setValue(1,'m/s');
%%  Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
fltCtrl.setPerpErrorVal(.25,'rad')
fltCtrl.rudderGain.setValue(0,'')
fltCtrl.rollMoment.kp.setValue(50,'(N*m)/(rad)')
fltCtrl.rollMoment.kd.setValue(25,'(N*m)/(rad/s)')
fltCtrl.tanRoll.kp.setValue(.45,'(rad)/(rad)')
thr.tether1.dragEnable.setValue(1,'')
vhcl.hStab.setIncidence(-1.5,'deg');
vhcl.setBuoyFactor(.98,'')
vhcl.setRBridle_LE([0.029;0;-0.1],'m')%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Start Control
fltCtrl.startControl.setValue(300,'s')
elSP = -5; 

%% Open Loop Flow Speed
flowSpeedOpenLoop = .03; 
%%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(200,'s');  dynamicCalc = '';
%     open_system('OCTModel')
%     set_param('OCTModel','SimulationMode','accelerator');
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);
    
%     plotsq(tsc.winchPower.Time, tsc.positionVec.Data(3,1,:))
     vhcl.animateSim(tsc,2,'GifTimeStep',0.05,'SaveGif',1==1)
    
    end 
end
