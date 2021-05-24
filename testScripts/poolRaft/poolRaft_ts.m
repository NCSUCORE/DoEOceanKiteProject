%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 1;                %   Flag to run linearization
thrArray = 15;
altitudeArray = 1.5;
flwSpdArray = -0.5;%-0.03;
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
thrLength = thrArray(1);  altitude = altitudeArray(1);  elev = atan2(altitude,thrLength);               %   Initial tether length/operating altitude/elevation angle 
flwSpd = flwSpdArray(1);                                    %   m/s - Flow speed
Tmax = 38;                                                  %   kN - Max tether tension 
h = 25*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = asin(altitude/thrLength);
loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
FLIGHTCONTROLLER = 'pathFollowingControllerExp';
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
loadComponent('raftGroundStation');                         %   Ground station
loadComponent('winchManta');                                %   Winches
loadComponent('MantaTether');                               %   Manta Ray tether
loadComponent('realisticSensors')                           %   Sensors
loadComponent('realisticSensorProcessing')                  %   Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8_exp2');                %   AR = 8; 8m span
%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([flwSpd 0 0],'m/s');                   %   m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
%%  Set basis parameters for high level controller
load('lineAngleSensor');
las.setInitAng([-el 0],'rad');
loadComponent('constBoothLem');        %   High level controller
% PATHGEOMETRY = 'lemOfBoothInv'
% hiLvlCtrl.elevationLookup.setValue(maxT.R.EL,'deg');
% 
% hiLvlCtrl.ELctrl.setValue(1,'');
% hiLvlCtrl.ELslew.setValue(0.25,'deg/s');
% hiLvlCtrl.ThrCtrl.setValue(1,'');

hiLvlCtrl.basisParams.setValue([a,b,-el,180*pi/180,thrLength-.1],'[rad rad rad rad m]') % Lemniscate of Booth
%%  Ground Station Properties
%% Set up pool raft parameters
theta = 30*pi/180;
T_tether = 100; %N
phi_max = 30*pi/180;
omega_kite = 2*pi/5; %rad/s
m_raft = 78.3; %kg
J_raft = 92.4; %kg*m^2
tow_length = 16;
tow_speed = 0;%0.5-0.03;
end_time = tow_length/(tow_speed-flwSpd);
x_init = 4;
y_init = 0;
y_dot_init = 0;
psi_init = 0;
psi_dot_init = 0;
initGndStnPos = [x_init;y_init;3];

thrAttachInit = initGndStnPos;
%%  Vehicle Properties
vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(tow_speed-flwSpd)*norm([1;0;0]))

%%  Tethers Properties
load([fileparts(which('OCTProject.prj')),'\vehicleDesign\Tether\tetherDataNew.mat']);
thr.tether1.initGndNodePos.setValue(thrAttachInit,'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.tether1.initGndNodeVel.setValue([-tow_speed 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
thr.tether1.youngsMod.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.youngsMod',Tmax)),'Pa');
thr.tether1.density.setValue(eval(sprintf('AR8b8.length600.tensionValues%d.density',Tmax)),'kg/m^3');
thr.tether1.setDiameter(.0076,'m');
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
vhcl.hStab.setIncidence(-1.5,'deg');
vhcl.setBuoyFactor(.98,'')
vhcl.setRBridle_LE([0.029;0;-0.1],'m')

%%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
%     open_system('OCTModel')
%     set_param('OCTModel','SimulationMode','accelerator');
    simWithMonitor('OCTModel')
    tsc = signalcontainer(logsout);
%%  Gif script
vhcl.animateSim(tsc1,0.2,'GifTimeStep',0.05,'SaveGif',1==0)%,'View',[0 0])

