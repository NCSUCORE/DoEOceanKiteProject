% %% Script to run ILC path optimization
clear;clc;close all
sim = SIM.sim;
sim.setDuration(100,'s');
dynamicCalc = '';
%% Variables to be put into a takeoff controller object
pitchSP=-1*pi/180; %degrees
kpPitch=1e5/2; %N*M per degree
kpYaw=5.7296e+03;
%% Load components
% Flight Controller
loadComponent('firstBuildTakeoff');
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% High level controller
loadComponent('constBoothLem')
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('oneDOFWnch');
% Tether
loadComponent('pathFollowingTether');
% Vehicle
loadComponent('pathFollowingVhcl');
% Environment
loadComponent('constXYZT');
% loadComponent('CNAPsTurbJames');
%  loadComponent('CNAPsMitchell');
%% Environment IC's and dependant properties
 env.water.setflowVec([1 0 0],'m/s')

%% Set basis parameters for high level controller
% hiLvlCtrl.initBasisParams.setValue([0.8,1.4,-20*pi/180,0*pi/180,125],'[]') % Lemniscate of Booth
hiLvlCtrl.basisParams.setValue([1,1.4,.36,0,125],'') % Lemniscate of Booth
%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Set vehicle initial conditions
% vhcl.setICsOnPath(...
%     0,... % Initial path position
%     PATHGEOMETRY,... % Name of path function
%     hiLvlCtrl.initBasisParams.Value,... % Geometry parameters
%     gndStn.posVec.Value,... % Center point of path sphere
%     (11/2)*norm(env.water.flowVec.Value)) % Initial speed
% vhcl.setAddedMISwitch(false,'');
vhcl.setInitAngVelVec([.1 .1 .1],'rad/s')
vhcl.setInitEulAng([10*pi/180 80*pi/180 0],'rad')
vhcl.setInitPosVecGnd([125/sqrt(2),0,125/sqrt(2)],'m')
vhcl.setInitVelVecBdy([-.5 0 0],'m/s')
% vhcl.setICsOnPath(...
%     .25,... % Initial path position
%     PATHGEOMETRY,... % Name of path function
%     hiLvlCtrl.basisParams.Value,... % Geometry parameters
%     gndStn.posVec.Value,... % Center point of path sphere
%     .1*(11/2)*norm([ 1 0 0 ])) % Initial speed
vhcl.setAddedMISwitch(false,'');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
%% Winches IC's and dependant properties
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[ 1 0 0]);

%% Controller User Def. Parameters and dependant properties
fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
% Set initial conditions
% fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
%     hiLvlCtrl.initBasisParams.Value,...
%     gndStn.posVec.Value);

fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);
simWithMonitor('OCTModel')
parseLogsout
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