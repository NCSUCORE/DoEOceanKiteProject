clear
clc
format compact
% close all

cd(fileparts(mfilename('fullpath')));

lengthScaleFactor = 1;
densityScaleFactor = 1/1;

simTime = 60;
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

altiSP = 34.5e-2;
iniX = 0.2276;
pitchSP = 11;

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
wnch.winch1.initLength.setValue(0.4061,'m');
wnch.winch2.initLength.setValue(0.4369,'m');
wnch.winch3.initLength.setValue(0.4061,'m');


dynamicCalc = '';

%% Set up controller
load('ayazThreeTetCtrl.mat');

altitudeCtrlShutOffDelay = 0*800;
% expOffset = 7.7+2.5;
expOffset = 0;
expDelay = 20.61;
initialDelay = altitudeCtrlShutOffDelay + expDelay;
expOffset = altitudeCtrlShutOffDelay + expOffset;

% switching values
fltCtrl.ySwitch.setValue(0,'m'); % set to 0 to execute simple square wave tracking
fltCtrl.rollAmp.setValue(12,'deg');
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
% load file
load 'data_19_Nov_2019_19_08_19.mat' 

% extract values
tscExp = tsc;
timeExp = tscExp.roll_rad.Time;

% filter bad data
badData = find(tscExp.yaw_rad.Data>100);
tscExp.yaw_rad.Data(badData) = 0.5*(tscExp.yaw_rad.Data(badData-1) + tscExp.yaw_rad.Data(badData+1));
windowSize = 20; 
b = (1/windowSize)*ones(1,windowSize);
tscExp.roll_rad.Data = filter(b,1,tscExp.roll_rad.Data);
tscExp.pitch_rad.Data = filter(b,1,tscExp.pitch_rad.Data);
tscExp.yaw_rad.Data = filter(b,1,tscExp.yaw_rad.Data);

tscExp.CoMPosVec_cm.Data = tscExp.CoMPosVec_cm.Data./100;

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
initVals.buoyFactor = vhcl.buoyFactor.Value;

initVals.wnchMaxReleaseSpeed = wnch.winch1.maxSpeed.Value;

initVals.thrDragCoeff = thr.tether1.dragCoeff.Value;


%% run optimization
initCoeffs = ones(13,1);
% initCoeffs = [0.8836    1.1571    0.6642    1.4724    0.2740    1.4610    0.9725...
%     0.5495    0.9937 1 1 1]';

% initCoeffs(11) = 0.55;
% initCoeffs(12) = 0.55;
% initCoeffs(13) = 0.55;

% lowLims = [repmat([0.25;1],3,1); 0.9; 0.5; 0.7; 0.9; 0.9; 0.9];
% hiLims = [repmat([1;1.75],3,1); 1.1; 1.5; 1.3; 1.1; 1.1; 1.1];

lowLims = [repmat([0.8;1],3,1); 0.8; 0.8; 0.8; 0.75;0.45;0.45;0.45];
hiLims = [repmat([1;1.2],3,1); 1.2; 1.2; 1.1; 1;0.65;0.65;0.65];
    
dataRange = [30 60];

% options = optimoptions(@fmincon,'MaxIterations',40,'MaxFunctionEvaluations',2000);
% [optDsgn,maxF] = fmincon(@(coeffs) simOptFunction(vhcl,thr,wnch,fltCtrl,...
%     initVals,coeffs,tscExp,dataRange),...
%     initCoeffs,[],[],[],[],lowLims,hiLims,[],options);

% [optDsgn,minF] = particleSwarmMinimization(...
%     @(coeffs) simOptFunction(vhcl,thr,wnch,fltCtrl,...
%     initVals,coeffs,tscExp,dataRange),initCoeffs,lowLims,hiLims,...
%     'swarmSize',25,'maxIter',20,'cognitiveLR',0.4,'socialLR',0.2);


%%
optDsgn = [0.9253 1.0000 0.9995 1.0000 0.9120 1.0000 1.0858 0.9676 1.0208 0.9515 0.5707 0.5246 0.5971  ]';
% optDsgn = initCoeffs;

objF = simOptFunction(vhcl,thr,wnch,fltCtrl,...
    initVals,optDsgn,tscExp,dataRange);


%% Run the simulation
% simWithMonitor('OCTModel')
% parseLogsout

plotAyaz
compPlots

% fullKitePlot


% % % % % % % tscSim.tetherLengths.Data(:,end)
% % % % % % % sol_Rcm_o(:,end)
% % % % % % % sol_euler(:,end)*180/pi

