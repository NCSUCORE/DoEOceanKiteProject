% clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(1000,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
% loadComponent('pathFollowingCtrlAddedMass');
loadComponent('pathFollowingCtrlForILC');
fltCtrl.rudderGain.setValue(0,'')
% SPOOLINGCONTROLLER = 'netZeroSpoolingControllerEllipsePath';
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
% loadComponent('constEllipse');
loadComponent('constBoothLem');
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
% loadComponent('pathFollowingVhclForComp')
% loadComponent('sensitivityAnalysis');              %   Load vehicle 

% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');

%% Environment IC's and dependant properties
env.water.setflowVec([-2 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1.5,2.3,-.3,180*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 200],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .05,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm([ 1 0 0 ])) % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
 wnch.winch1.initLength.setValue(1.240302277935769e+02,'m')
%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
%% Run Simulation
% vhcl.setFlowGradientDist(.01,'m')
% simWithMonitor('OCTModel')
% tsc = signalcontainer(logsout);


simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
tsc1 = tsc.resample(1);
%%
tsc.plotFlightResults(vhcl,env,'plot1Lap',1==1,'plotS',true,'plotBeta',false,'lapNum',max(tsc.lapNumS.Data)-1)

%     x =  squeeze(tsc1.tc.Data);
%     y = squeeze(tsc1.wd.Data);
%     hist2d(y,x)
%     title('2.0 M/S Flow Speed')
%     zlabel('Occurences')
%     xlabel('Drum Velocity (rad/s)')
%     ylabel('Torque (Nm)')
%     set(gca,'FontSize',15);

%     fprintf("Mean central angle = %g deg\n",180/pi*mean(tsc.centralAngle.Data))
%     disp(hiLvlCtrl.basisParams.Value)
%     %[y, Fs] = audioread('Ding-sound-effect.mp3'); %https://www.freesoundslibrary.com/ding-sound-effect/
%     %sound(y*.2, Fs, 16)
%     fprintf("min Z = %4.2f\n",min(tsc.positionVec.Data(3,1,:)))
% 
 vhcl.animateSim(tsc,1,'PathFunc',fltCtrl.fcnName.Value,...
     'PlotTracer',true,'FontSize',18)