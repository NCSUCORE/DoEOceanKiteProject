% clear;clc;close all
simParams = SIM.simParams;
simParams.setDuration(2000,'s');
dynamicCalc = '';

flwSpd = .5;
thrLength = 200;
if thrLength == 125
    a = 0.6;    b = 1.0;
elseif thrLength == 200
    a = 0.4;    b = 1.0;
else
    a = 1.0;    b = 2.2;
end
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
% loadComponent('JohnfullScale1thr');

% Environment
% loadComponent('CNAPsNoTurbJosh');
% loadComponent('CNAPsTurbJames');
% loadComponent('CNAPsTurbMitchell');
loadComponent('ConstXYZT');

%% Environment IC's and dependant properties
env.water.setflowVec([flwSpd 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
% hiLvlCtrl.basisParams.setValue([0.6,1.0,.36,0*pi/180,125],'[rad rad rad rad m]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([a,b,.36,0*pi/180,thrLength],'[rad rad rad rad m]') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    .05,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.posVec.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value))   % Initial speed
% vhcl.setTurbDiam(.4859,'m');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
% fltCtrl.setFirstSpoolLap(1000,'');

%% Run Simulation
% vhcl.setFlowGradientDist(.01,'m')
% simWithMonitor('OCTModel')
% tsc = signalcontainer(logsout);


simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
%     fprintf("Mean central angle = %g deg\n",180/pi*mean(tsc.centralAngle.Data))
%     disp(hiLvlCtrl.basisParams.Value)
%     %[y, Fs] = audioread('Ding-sound-effect.mp3'); %https://www.freesoundslibrary.com/ding-sound-effect/
%     %sound(y*.2, Fs, 16)
%     fprintf("min Z = %4.2f\n",min(tsc.positionVec.Data(3,1,:)))

if vhcl.turbines.diameter.Value > 0
    save(sprintf('Turb_V-%.1f_Thr-%d_a-%.1f_b-%.1f.mat',flwSpd,thrLength,a,b),'tsc')
elseif vhcl.turbines(1).diameter.Value == 0 && fltCtrl.firstSpoolLap.Value == 1
    save(sprintf('Winch_V-%.1f_Thr-%d_a-%.1f_b-%.1f.mat',flwSpd,thrLength,a,b),'tsc')
else
    save(sprintf('DOE_a-%.1f_b-%.1f.mat',a,b),'tsc')
end

%%
filename = sprintf('DOE_SF%.1f_TL%d_FS%.2f.gif',1,200,.5);
vhcl.animateSim(tsc,2,'PathFunc',fltCtrl.fcnName.Value,...
    'GifTimeStep',.1,'PlotTracer',true,'FontSize',12,...
    'Pause',false,'ZoomIn',false,'SaveGif',true,'GifFile',filename);
