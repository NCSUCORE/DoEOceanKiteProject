clear
clc
format compact
close all

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
iniX = 0.1904;
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
wnch.winch1.initLength.setValue(0.3900,'m');
wnch.winch2.initLength.setValue(0.4155,'m');
wnch.winch3.initLength.setValue(0.3900,'m');


dynamicCalc = '';

%% Set up controller
load('ayazThreeTetCtrl.mat');

altitudeCtrlShutOffDelay = 0;
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

%% adjust parameters
iniCLWing = vhcl.portWing.CL.Value;
iniCDWing = vhcl.portWing.CD.Value;

iniCLHs = vhcl.hStab.CL.Value;
iniCDHs = vhcl.hStab.CD.Value;

iniCLVs = vhcl.vStab.CL.Value;
iniCDVs = vhcl.vStab.CD.Value;

iniAddedMass = vhcl.addedMass.Value;



%% Run the simulation
simWithMonitor('OCTModel')
parseLogsout

plotAyaz
compPlots

% fullKitePlot

