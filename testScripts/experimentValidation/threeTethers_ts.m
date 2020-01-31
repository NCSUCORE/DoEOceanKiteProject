clear
clc
format compact
% close all

cd(fileparts(mfilename('fullpath')));

lengthScaleFactor = 1;
densityScaleFactor = 1/1;

simTime = 1*140;
sim = SIM.sim;
sim.setDuration(simTime*sqrt(lengthScaleFactor),'s');

%% Set up simulation
GNDSTNCONTROLLER      = 'oneDoF';

%% common parameters
numTurbines = 2;

load('constXYZT.mat')
% Set Values
vfdValue = 20;
flowSpeed = vfdInputToFlowSpeed(vfdValue);
env.water.flowVec.setValue([flowSpeed 0 0]','m/s');

%% lifiting body
load('ayazThreeTetVhcl.mat')

altiSP = 35e-2;
iniX = 0.2943;
pitchSP = 14;

% % % initial conditions
vhcl.setInitPosVecGnd([iniX;0;altiSP],'m');
vhcl.setInitVelVecBdy([0;0;0],'m/s');
vhcl.setInitEulAng([0;pitchSP;0]*pi/180,'rad');
vhcl.setInitAngVelVec([0;0;0],'rad/s');

% % % plot
% vhcl.plot
% vhcl.plotCoeffPolars

% High Level controller
loadComponent('constBoothLem.mat')


%% Ground Station
load('ayazThreeTetGndStn.mat')

gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Tethers
load('ayazThreeTetTethers.mat')

% set initial conditions
for ii = 1:3
    
    thr.(strcat('tether',num2str(ii))).initGndNodePos.setValue...
        (gndStn.posVec.Value + ...
        gndStn.(strcat('thrAttch',num2str(ii))).posVec.Value(:),'m');
    thr.(strcat('tether',num2str(ii))).initAirNodePos.setValue...
        (vhcl.initPosVecGnd.Value(:)+rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts(ii).posVec.Value,'m');
    thr.(strcat('tether',num2str(ii))).initGndNodeVel.setValue([0 0 0]','m/s');
    thr.(strcat('tether',num2str(ii))).initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
    thr.(strcat('tether',num2str(ii))).vehicleMass.setValue(vhcl.mass.Value,'kg');
    
end
% thr.designTetherDiameter(vhcl,env);

%% winches
load('ayazThreeTetWnch.mat');
% set initial conditions
% wnch.setTetherInitLength(vhcl,env,thr);
% wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
wnch.winch1.initLength.setValue(0.4458,'m');
wnch.winch2.initLength.setValue(0.4814,'m');
wnch.winch3.initLength.setValue(0.4458,'m');

dynamicCalc = '';

%% Set up controller
load('ayazThreeTetCtrl.mat');

altitudeCtrlShutOffDelay = 0*800;
% expOffset = 7.7+2.5;
expOffset = 0;
expDelay = 54.19;
% altitudeCtrlShutOffDelay = 0.75*expDelay;
initialDelay = 1*altitudeCtrlShutOffDelay + expDelay;
expOffset = 1*altitudeCtrlShutOffDelay + expOffset;

% switching values
fltCtrl.ySwitch.setValue(0,'m'); % set to 0 to execute simple square wave tracking
fltCtrl.rollAmp.setValue(13,'deg');
fltCtrl.rollPeriod.setValue(5,'s');

% set setpoints
timeVec = 0:0.005*sqrt(lengthScaleFactor):simTime;
fltCtrl.altiSP.setValue(altiSP*ones(size(timeVec)),'m',timeVec);
fltCtrl.pitchSP.setValue(pitchSP*ones(size(timeVec)),'deg',timeVec);
fltCtrl.yawSP.setValue(0*ones(size(timeVec)),'deg',timeVec);

%% scale 
% scale environment
% env.scale(lengthScaleFactor,densityScaleFactor);
% scale vehicle
% vhcl.scale(lengthScaleFactor,densityScaleFactor);
% scale ground station
% gndStn.scale(lengthScaleFactor,densityScaleFactor);
% scale tethers
% thr.scale(lengthScaleFactor,densityScaleFactor);
% scale winches
% wnch.scale(lengthScaleFactor,densityScaleFactor);
% scale controller
% fltCtrl.scale(lengthScaleFactor,densityScaleFactor);

%% process experimental data
datFileName = 'data_24_Jan_2020_15_50_38.mat';
fullFileName = strcat(cd,'\Jan24DataFiles\',datFileName);

tscExp = processExpData(fullFileName,...
    'Ro_c_in_meters',[23;-0.74;-4.1]./100,...
    'yawOffset',1*2.67,...
    'rollOffset',1*0.2505);


%% adjust parameters
initVals.CLWing = vhcl.portWing.CL.Value;
initVals.CDWing = vhcl.portWing.CD.Value;

initVals.CLhStab = vhcl.hStab.CL.Value;
initVals.CDhStab = vhcl.hStab.CD.Value;

initVals.CLvStab = vhcl.vStab.CL.Value;
initVals.CDvStab = vhcl.vStab.CD.Value;

initVals.fuseEndDrag = vhcl.fuseEndDragCoeff.Value;
initVals.fuseSideDrag = vhcl.fuseSideDragCoeff.Value;

initVals.addedMass = vhcl.addedMass.Value;
initVals.addedInertia = vhcl.addedInertia.Value;
initVals.buoyFactor = vhcl.buoyFactor.Value;

initVals.wnchMaxReleaseSpeed = wnch.winch1.maxSpeed.Value;

initVals.thrDragCoeff = thr.tether1.dragCoeff.Value;


%% run optimization
initCoeffs = ones(12,1);

initCoeffs(10:12) = [1;1;1];

initCoeffs = [0.800 1.200 0.921 1.200 0.873 1.000 1.122 0.200 1.800 0.200 1.800 1.800]';

lowLims = [repmat([0.8;1],3,1); 0.2*ones(3,1); 0.2*ones(3,1)];
hiLims =  [repmat([1;1.2],3,1); 1.8*ones(3,1); 1.8*ones(3,1)];
    
dataRange = [80 140];
% 
% % % % % optimize using PSO
% [optDsgn,minFCoarse] = particleSwarmMinimization(...
%     @(coeffs) simOptFunction(vhcl,thr,wnch,fltCtrl,...
%     initVals,coeffs,tscExp,dataRange),initCoeffs,lowLims,hiLims,...
%     'swarmSize',20,'maxIter',10,'cognitiveLR',0.4,'socialLR',0.2);
% 
% % % % gradient based opt
% options = optimoptions(@fmincon,'Algorithm','sqp',...
% 'MaxIterations',15,...
% 'Display','final',...
% 'OptimalityTolerance',1e-4);
% % 'MaxFunctionEvaluations',200,...
% 
% [optDsgn2,minFfine] = fmincon(@(coeffs) simOptFunction(vhcl,thr,wnch,fltCtrl,...
%     initVals,coeffs,tscExp,dataRange),...
%     optDsgn,[],[],[],[],0.75.*optDsgn,1.25.*optDsgn,[],options);


% 
% 
%%
% optDsgn = [0.900 1.100 0.952 1.100 0.900 1.000 0.500 0.500 1.500 0.500 0.500 0.500 ]';
% optDsgn = initCoeffs;
optDsgn2 = initCoeffs;

objF = simOptFunction(vhcl,thr,wnch,fltCtrl,...
    initVals,optDsgn2,tscExp,dataRange);


%% Run the simulation
% simWithMonitor('OCTModel')
% parseLogsout

plotAyaz
compPlots

% fullKitePlot


% % % % % % % tscSim.tetherLengths.Data(:,end)
% % % % % % % sol_Rcm_o(:,end)
% % % % % % % sol_euler(:,end)*180/pi

