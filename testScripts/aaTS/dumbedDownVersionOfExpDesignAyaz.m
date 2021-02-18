%% Test script for John to control the kite model
Simulink.sdi.clear
clear;clc;close all;
cd(fileparts(mfilename('fullpath')));

%%  Select sim scenario
%   0 = fig8;
%   1 = fig8-2rot DOE-M;  1.1 = fig8-2rot AVL;  1.2 = fig8-2rot XFoil;  1.3 = fig8-2rot XFlr5;
%   2 = fig8-winch DOE;
%   3 = steady Old;       3.1 = steady AVL;     3.2 = steady XFoil      3.3 = Steady XFlr5      3.4 = Steady XFlr5 Passive ;
%   4 = LaR Old;          4.1 = LaR AVL;        4.2 = LaR XFoil;        4.3 = LaR XFlr5

% select simulation scenario
simScenario = 3.2;
% Simulation Time (s)
simTime = 1200;
%%  Configure Test
% path height, width, and mean elevation (rad)
h = 10*pi/180;  
w = 40*pi/180;
el = 30*pi/180;                                
% convert width and height to path parameters, a and b
[a,b] = boothParamConversion(w,h);  
% Initial tether length (m)
thrLength = 4;   
% Flow speed (m/s)
flwSpd = 0.1;           
% Moving Ground Station Velocity Magnitude (m/s)
craftSpeed = -0.25;

% Ground Station Trajectory
% trajectory time stamps
time = [0 600 3165 3180 3195 3210 3215 63300  633000];
% Ground Station velocity trajectory
gndStnVel = craftSpeed*[ones(length(time),1),zeros(length(time),2)];
% Ground Station angular velocity trajectory
angVel = zeros(size(gndStnVel,1),size(gndStnVel,2));
% don't know what spiral is but set 1 for prescribed control,2 for spiral transit
spiral = 1; 

%%  Load components
% load launch and recovery controller
loadComponent('exp_slCtrl');                        
% load ground station controller
loadComponent('oneDoFGSCtrlBasic');
% load ground station
loadComponent('pathFollowingGndStn');
% load winch
loadComponent('winchManta');
% load tether
loadComponent('MantaTether');
% load sensors
loadComponent('idealSensors');
% load sensor processing
loadComponent('idealSensorProcessing');
% load vehicle
loadComponent('Manta2RotXFoil_AR8_b8_exp2');                            
% select vehicle variant in simulink model
VEHICLE = 'vehicleManta2RotPool';
% select six DoF calcualtions variant in simulink model
SIXDOFDYNAMICS = 'sixDoFDynamicsCoupledFossen12Int';
% load environment
loadComponent('constXYZT');
% select environment variant in simulink model
ENVIRONMENT = 'environmentManta2Rot';
% load high-level controller
loadComponent('constBoothLem');

% tweak vehicle aerodynamic parameters
vhcl.hStab.CL.setValue(vhcl.hStab.CL.Value,'')
vhcl.hStab.CD.setValue(vhcl.hStab.CD.Value,'')
vhcl.vStab.CL.setValue(vhcl.vStab.CL.Value,'')
vhcl.vStab.CD.setValue(vhcl.vStab.CD.Value,'')
vhcl.hStab.setIncidence(1.6225,'deg');
vhcl.setBuoyFactor(1,'')

%%  Environment Properties
% set flow speed vector (m/s)
env.water.setflowVec([flwSpd 0 0],'m/s');               

%% high level controller properties
% set high-level controller basis parameters 
% basisParam = [a,b,mean elevation,mean azimuth,tether length]
hiLvlCtrl.basisParams.setValue([a,b,el,0*pi/180,thrLength],'[rad rad rad rad m]') 

%%  Ground Station Properties
% set ground station position (m)
gndStn.setPosVec([0 0 0],'m');
% set ground station velocity (m/s)
gndStn.setVelVec([0 0 0],'m/s');
% set ground station initial angular position (rad)
gndStn.initAngPos.setValue(0,'rad');
% set ground station initial angular velocity (rad/s)
gndStn.initAngVel.setValue(0,'rad/s');

%%  Vehicle Properties
% set vehicle path initial conditions
vhcl.setICsOnPath(...
    .05,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm(flwSpd))   % Initial speed
% set vehicle initial Euler angles (rad)
vhcl.setInitEulAng([0,0,0]*pi/180,'rad');
% set maximum control deflection rates (deg/s)
vhcl.allMaxCtrlDefSpeed.setValue(30,'deg/s');
% set turbine power coefficient
vhcl.turb1.setPowerCoeff(0,'');
% added mass tweaking matrix
MA_tweak = ones(6);
vhcl.setMa6x6_LE(vhcl.Ma6x6_LE.Value.*MA_tweak,'');

%%  Tethers Properties
% set tether ground node initial position (m)
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
% set tether ground node initial velocity (m/s)
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
% set tether kite node initial velocity (m/s)
thr.tether1.initAirNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(...
    rotation_sequence(vhcl.initEulAng.Value)*vhcl.initVelVecBdy.Value(:),'m/s');

% set tether kite node initial position (m)
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value(:),'m');
% set tether density (kg/m^3)
thr.tether1.setDensity(env.water.density.Value,'kg/m^3');
% set tether diameter (m)
thr.tether1.setDiameter(0.0076,'m');
% choose to enable or disable tether drag
thr.tether1.dragEnable.setValue(false,'')
% provide tether with the kite's mass (kg)
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%%  Winches Properties
% set initial tether length (m)
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
% set laucnh and recovery tether speed (m/s)
wnch.winch1.LaRspeed.setValue(1,'m/s');

%%  Controller User Def. Parameters and dependant properties
% set path geometry shape
fltCtrl.setFcnName(PATHGEOMETRY,'');
% find path parameter based on kites' initial position
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,gndStn.posVec.Value);
% tweak tangent roll controller gains
% KP (rad/rad)
fltCtrl.tanRoll.setKp(fltCtrl.tanRoll.kp.Value*1,'(rad)/(rad)');

% tweak pitch controller
% proportional gain, KP (deg/deg)
fltCtrl.pitchSP.kp.setValue(10,'(deg)/(deg)');      
% integral gain, KI (deg / deg*s)
fltCtrl.pitchSP.ki.setValue(.01,'(deg)/(deg*s)');   
% pitch angle saturation limits? (deg)
fltCtrl.pitchAngleMax.upperLimit.setValue(45,'');   
fltCtrl.pitchAngleMax.lowerLimit.setValue(-45,'');
% select where pitch setpoint comes from. 0 = contant; 1 = time-lookup; 2 = LaR
fltCtrl.pitchCtrl.setValue(0,'');
% set constant pitch setpoint
fltCtrl.pitchConst.setValue(0,'deg');

% tweak spooling controller gains
% nominal spool speed (m/s)
fltCtrl.setNomSpoolSpeed(0,'m/s');
% spool time constant (s)
fltCtrl.setSpoolCtrlTimeConstant(5,'s');

% tweak winch controller 
wnch.winch1.elevError.setValue(2,'deg');

% look at initial controller vector
fltCtrl.initCtrlVec;

% tweak elevator controller
elevKp = 50;
% proportional gain, KP (deg/rad)
fltCtrl.elevCmd.kp.setValue(elevKp,'(deg)/(rad)');
% proportional gain, KD (deg/rad)
fltCtrl.elevCmd.kd.setValue(elevKp*0,'(deg)/(rad/s)');
% integral gain, KI (deg / rad*s)
fltCtrl.elevCmd.ki.setValue(elevKp/500,'(deg)/(rad*s)');

% tweak ailerons
% proportional gain, KP (deg/rad)
fltCtrl.alrnCmd.kp.setValue(0,'(deg)/(rad)');
% integral gain, KI (deg / rad*s)
fltCtrl.alrnCmd.ki.setValue(0,'(deg)/(rad*s)');
% derivative gain, KD (deg / rad/s)
fltCtrl.alrnCmd.kd.setValue(0,'(deg)/(rad/s)');

% tweak rudder
% proportional gain, KP (deg/rad)
fltCtrl.rudderCmd.kp.setValue(0,'(deg)/(rad)')
% integral gain, KI (deg / rad*s)
fltCtrl.rudderCmd.ki.setValue(0,'(deg)/(rad*s)')
% derivative gain, KD (deg / rad/s)
fltCtrl.rudderCmd.kd.setValue(0,'(deg)/(rad/s)')

%% Scale Components
% scale tether
thr.scale(0.1,1);
% scale flight controller
fltCtrl.scale(0.1,1);
% scale environment
env.scale(0.1,1);
%%  Set up critical system parameters and run simulation
% clear simulink temp files
Simulink.sdi.clear;
% set simulaiton prameters
simParams = SIM.simParams;
% set simulation duration
simParams.setDuration(simTime,'s');
% set dynamic calculation method
dynamicCalc = '';

%% Simulation
% run the simulation
simWithMonitor('OCTModel');
% create time series container object
tsc = signalcontainer(logsout);

%% post processing
figure
subplot(2,1,1)
plot(tsc.positionVec.Time,tsc.pitchSP.Data(:),'k:+');
hold on;
grid on;
plot(tsc.positionVec.Time,tsc.eulerAngles.Data(2,:)*180/pi,'r');
legend('Pitch SP','Pitch')
subplot(2,1,2)
plot(tsc.positionVec.Time,tsc.ctrlSurfDeflCmd.Data(:,3),'k');
grid on;
hold on;
legend('Elevator deflection');
linkaxes(findall(0,'type','axes'),'x');


% plotCtrlDeflections
% figure; plot(tsc.hStabMoment)
% figure; plot(tsc.wingTotalMoment)

% vhcl.animateSim(tsc,2,...
%     'GifTimeStep',0,'PlotTracer',true,'FontSize',12,'Pause',1==0,...
%     'ZoomInMove',false,'SaveGIF',true,'GifFile','animation.gif',...
%     'View',[0,0],'timeStep',.01);


