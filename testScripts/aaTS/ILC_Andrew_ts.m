clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(5000,'s');
dynamicCalc = '';
Simulink.sdi.clear
distFreq = 0;
distAmp = 0;
pertVec = [0 0 0];
flwSpd = 1
%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
loadComponent('pathFollowingCtrlForILCAoA');
fltCtrl.rudderGain.setValue(-1,'')
% SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
fltCtrl.firstSpoolLap.setValue(100,'')
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('constEllipse');
% loadComponent('constBoothLem');

loadComponent('fig8ILC1mPs')
PATHGEOMETRY = 'lemBoothNew'
hiLvlCtrl.initBasisParams.setValue([140,40,30*pi/180,0*pi/180,300],'[]') % Lemniscate of Booth
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Sensors
loadComponent('idealSensors')
% Sensor processing
loadComponent('idealSensorProcessing')
% Vehicle
loadComponent('fullScale1thr');
VEHICLE = "vhcl2turb";
PLANT = "plant2turb";
WINCH = "constThr"
% loadComponent('pathFollowingVhclForComp')
% loadComponent('sensitivityAnalysis');              %   Load vehicle

% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');

ENVIRONMENT = "env2turb"
%% Environment IC's and dependant properties
env.water.setflowVec([flwSpd 0 0],'m/s')
% w = 100*pi/180; h = 30*pi/180;
% [a,b] = boothParamConversion(w,h)
%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([1,1.4,-30*pi/180,180*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([a,b,-30*pi/180,180*pi/180,150],'[rad rad rad rad m]') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.initBasisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (6/2)*norm([ 1 0 0 ])) % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
thr.numNodes.setValue(8,'')
thr.tether1.numNodes.setValue(8,'')
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
% thr.tether1.setYoungsMod(20e10,'Pa')
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
% thr.setNumNodes(8,'')
%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.initLength.setValue(300,'m')
%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.initBasisParams.Value,...
    gndStn.posVec.Value);
% fltCtrl.rollMoment.setKp(.2,'(rad)/(rad)')
% fltCtrl.rollMoment.setTau(.1,'s')
fltCtrl.winchSpeedIn.setValue(0,'m/s')
fltCtrl.firstSpoolLap.setValue(100,'')
fltCtrl.RPMConst.setValue(0,'')
fltCtrl.elevatorConst.setValue(0,'deg')
fltCtrl.AoACtrl.setValue(1,'')
fltCtrl.Tmax.setValue(1e6,'kN')
fltCtrl.AoAmin.setValue(0,'deg')
fltCtrl.AoAConst.setValue(5*pi/180,'deg')
fltCtrl.AoASP.setValue(0,'')
fltCtrl.rudderGain.setValue(-1,'')
% fltCtrl.elevatorReelInDef.setValue(0,'deg')
fltCtrl.refFiltTau.setValue(3,'s')
fltCtrl.rollMoment.kp.setValue(10000,'(N*m)/(rad)');
fltCtrl.rollMoment.ki.setValue(00,'(N*m)/(rad*s)');
fltCtrl.rollMoment.kd.setValue(40000,'(N*m)/(rad/s)');
fltCtrl.rollMoment.tau.setValue(1,'s');
fltCtrl.yawMoment.kp.setValue(10000,'(N*m)/(rad)');
fltCtrl.perpErrorVal.setValue(0.1,'rad')
fltCtrl.pitchMoment.kp.setValue(10000,'(N*m)/(rad)');
fltCtrl.pitchMoment.ki.setValue(100,'(N*m)/(rad*s)');
fltCtrl.tanRoll.kp.setValue(0.4,'(rad)/(rad)');
fltCtrl.tanRoll.ki.setValue(0,'(rad)/(rad*s)');
fltCtrl.tanRoll.kd.setValue(0,'(rad)/(rad/s)');
fltCtrl.tanRoll.tau.setValue(.1,'s');
hiLvlCtrl.numInitLaps.setValue(2,'')
hiLvlCtrl.trustRegion.setValue([5 5 inf inf inf],'[]')
% fltCtrl.yawMoment.kp.setValue(,'(N*m)/(rad)');
%% Run Simulation
% vhcl.setFlowGradientDist(.01,'m')
% simWithMonitor('OCTModel')
% tsc = signalcontainer(logsout);
% fltCtrl.yawMoment.kp.setValue(100,'(N*m)/(rad)')
% ENVIRONMENT = "env2turbLinearize";
SIXDOFDYNAMICS = 'sixDoFDynamicsCoupledFossen12Int';
set_param('OCTModel','SimulationMode','accelerator');
simWithMonitor('OCTModel')
cPV = logsout.getElement('closestPathVariable');
lapNumS = logsout.getElement('lapNumS');
tsc = signalcontainer(logsout);

vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,'TracerDuration',20,...
    'GifTimeStep',.00001,'PlotTracer',false,'FontSize',12,'Pause',1==0,...
    'ZoomIn',1==0,'SaveGif',1==1,'GifFile','really.gif')