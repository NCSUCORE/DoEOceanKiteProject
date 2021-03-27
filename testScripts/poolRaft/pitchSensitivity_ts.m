%% Test script for pool test simulation of the kite model
clear;clc;close all;
Simulink.sdi.clear
%%  Set Test Parameters
saveSim = 0;               %   Flag to save results
runLin = 0;                %   Flag to run linearization
thrArray = 3;%[200:400:600];%:25:600];
altitudeArray = 1.5;%[100:200:300];%150:25:300];
flwSpdArray = -0.;%[0.1:0.1:.5]; 
inc = [-8:.1:0];
towArray = [0.5:.15:.8];
distFreq = 0;
distAmp = 0;
pertVec = [0 1 0];
for i = 1:length(inc)
    for j = 1:length(towArray)
        tic
thrLength = 3;  altitude = thrLength*sin(40/180*pi);                 %   Initial tether length/operating altitude/elevation angle 
flwSpd = -.0001 ;                                   %   m/s - Flow speed
Tmax = 38;                                                  %   kN - Max tether tension 
h = 25*pi/180;  w = 100*pi/180;                             %   rad - Path width/height
[a,b] = boothParamConversion(w,h);                          %   Path basis parameters
%%  Load components
fpath = fullfile(fileparts(which('OCTProject.prj')),...
    'vehicleDesign\Tether\Tension\');
maxT = load([fpath,sprintf('TmaxStudy_%dkN.mat',Tmax)]);
el = asin(altitude/thrLength);
    loadComponent('exp_slCtrl');   
% loadComponent('pathFollowCtrlExp');                         %   Path-following controller with AoA control
% FLIGHTCONTROLLER = 'pathFollowingControllerExp';
loadComponent('oneDoFGSCtrlBasic');                         %   Ground station controller
% loadComponent('MantaGndStn');                             %   Ground station
loadComponent('raftGroundStation');  


loadComponent('winchManta');                                %   Winches
loadComponent('MantaTether');                               %   Manta Ray tether
loadComponent('idealSensors')                               %   Sensors
loadComponent('idealSensorProcessing')                      %   Sensor processing
loadComponent('Manta2RotXFoil_AR8_b8_exp_3dPrinted');                %   AR = 8; 8m span
SIXDOFDYNAMICS        = "sixDoFDynamicsCoupledFossen12int";
%%  Environment Properties
loadComponent('ConstXYZT');                                 %   Environment
env.water.setflowVec([-towArray(j) 0 0],'m/s');                   %   m/s - Flow speed vector
    ENVIRONMENT = 'environmentManta2RotBandLin';            %   Two turbines
%%  Set basis parameters for high level controller

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
m_raft = 50; %kg
J_raft = 30;
tow_length = 16;
tow_speed = 0%towArray(j);    
end_time = tow_length/towArray(j);
x_init = 4;
y_init = 0;
y_dot_init = 0;
psi_init = 0;
psi_dot_init = 0;
initGndStnPos = [x_init;y_init;3];

thrAttachInit = initGndStnPos;
%%  Vehicle Properties
% vhcl.setICsOnPath(.85,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,6.5*abs(flwSpd)*norm([1;0;0]))
    vhcl.setICsOnPath(0,PATHGEOMETRY,hiLvlCtrl.basisParams.Value,initGndStnPos,0);
    vhcl.setInitEulAng([180 0 180]*pi/180,'rad');
    vhcl.setInitVelVecBdy([-tow_speed 0 0],'m/s');
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
vhcl.hStab.setIncidence(inc(i),'deg');






%%  Set up critical system parameters and run simulation
    simParams = SIM.simParams;  simParams.setDuration(end_time,'s');  dynamicCalc = '';
%     open_system('OCTModel')
%     set_param('OCTModel','SimulationMode','accelerator');
    simWithMonitor('OCTModel')
    tsc1{i,j} = signalcontainer(logsout);
    elevEnd(i,j) = tsc1{i,j}.elevationAngle.Data(end);
    toc
    end 
end

for i = 1:length(inc)
    for j = 1:length(towArray)
        pitch(i,j) = -tsc1{i,j}.pitch.Data(end);
        elev(i,j) = -tsc1{i,j}.elevationAngle.Data(end);
    end
end

[x,y]=meshgrid(inc,towArray);

figure
plot(pitch*180/pi,elev,'-')
legend('Tow Speed = 0.5 m/s','Tow Speed = 0.65 m/s','Tow Speed = 0.8 m/s')
xlabel('Pitch Angle')
ylabel('Elevation Angle')

figure
plot(x',pitch,'-')
legend('Tow Speed = 0.5 m/s','Tow Speed = 0.65 m/s','Tow Speed = 0.8 m/s')
xlabel('Stabilizer Incidence [deg]')
ylabel('Pitch Angle [deg]')
