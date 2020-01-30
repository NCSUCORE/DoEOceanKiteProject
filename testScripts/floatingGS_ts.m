%% Test script to test the floating ground station simulation and animation
clear;clc;close all
sim = SIM.sim;
sim.setDuration(100,'s');
dynamicCalc = '';

%% Load components
% Flight Controller
loadComponent('pathFollowingCtrlForILC');
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('oneThrThreeAnchGndStn001');
% Winches
loadComponent('oneDOFWnchPTO');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('constXYZT');

%% Environment IC's and dependant properties
env.water.setflowVec([1 0 0],'m/s')

%% Set basis parameters for high level controller
hiLvlCtrl.basisParams.setValue([1,1.4,-20*pi/180,0*pi/180,125],'') % Lemniscate of Booth

%% Ground Station IC's and dependant properties
gndStn.setInitPosVec([0 0 200],'m')
gndStn.setInitVel([0 0 0],'m/s')
gndStn.setInitEulAngs([0 0 0],'rad');
gndStn.initAngVel.setValue([0 0 0],'rad/s');

%% Set vehicle initial conditions
vhcl.setICsOnPath(...
    0,... % Initial path position
    PATHGEOMETRY,... % Name of path function
    hiLvlCtrl.basisParams.Value,... % Geometry parameters
    gndStn.initPosVec.Value,... % Center point of path sphere
    (11/2)*norm(env.water.flowVec.Value)) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.initPosVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.setTetherInitLength(vhcl,gndStn.initPosVec.Value,env,thr,[ 1 0 0]);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
% fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
%     hiLvlCtrl.initBasisParams.Value,...
%     gndStn.posVec.Value);
vhcl.addedMass.setValue(zeros(3,3),'kg')
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.initPosVec.Value);
simWithMonitor('OCTModel')
tsc = signalcontainer(logsout);
% LUT = Simulink.LookupTable;
% timeVec = linspace(0,1);
% LUT.Table.Value = env.waterTurb.frequencyDomainEqParams.Value.Data(:,:,:,:,[],:);
% LUT.Breakpoints(1).Value = env.water.xGridPoints.Value;
% LUT.Breakpoints(2).Value = env.water.yGridPoints.Value;
% LUT.Breakpoints(3).Value = env.water.zGridPoints.Value;
% LUT.Breakpoints(4).Value = 1:size(LUT.Table.Value,4);
% LUT.Breakpoints(5).Value = 1:size(LUT.Table.Value,5);
% LUT.Breakpoints(6).Value = env.waterTurb.frequencyDomainEqParams.Value.Time;
% LUT.StructTypeInfo.Name = 'LUT';
%%
vhcl.animateSim(tsc,1,...
    'PathFunc',fltCtrl.fcnName.Value,...
    'PlotTracer',true,...
    'FontSize',24,...
    'PowerBar',false,...
    'PlotAxes',false,...
    'TracerDuration',10,...
    'GroundStation',gndStn,...
    'SaveGif',false)