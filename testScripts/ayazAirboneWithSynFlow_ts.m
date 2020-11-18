clear;
clc;
% close all;

cd(fileparts(mfilename('fullpath')));

simParams = SIM.simParams;
simParams.setDuration(40*60,'s');
dynamicCalc = '';
flowSpeed = 10;
thrLength = 1000;
% rad - Mean elevation angle
initElevation = 30*pi/180;    
% rad - Path width/height
w = 40*pi/180;          
h = 8*pi/180;  
% Path basis parameters
[a,b] = boothParamConversion(w,h);      

%% Load components
% Spooling controller
SPOOLINGCONTROLLER = 'netZeroSpoolingController';
% Ground station controller
loadComponent('oneDoFGSCtrlBasic');
% Ground station
loadComponent('pathFollowingGndStn');
% Winches
loadComponent('ayazFullScaleOneThrWinch');
% Tether
loadComponent('ayazAirborneThr');
% Sensors
loadComponent('idealSensors');
% Sensor processing
loadComponent('idealSensorProcessing');
% Vehicle
loadComponent('ayazAirborneVhcl');

% High level controller
% loadComponent('constBoothLem');
% hiLvlCtrl.basisParams.setValue([a,b,initElevation,0*pi/180,thrLength],'[rad rad rad rad m]');

loadComponent('gpkfPathOptWithRGPAirborne');
hiLvlCtrl.maxStepChange        = (800/thrLength)*180/pi;
hiLvlCtrl.minVal               = 10;
hiLvlCtrl.maxVal               = 50;
hiLvlCtrl.basisParams.Value = [a,b,initElevation,0*pi/180,thrLength]';
hiLvlCtrl.initVals          = hiLvlCtrl.basisParams.Value(3)*180/pi;
hiLvlCtrl.rateLimit         = 0.15;
hiLvlCtrl.kfgpTimeStep      = 10/60;
hiLvlCtrl.mpckfgpTimeStep   = 3;
predictionHorz  = 6;
exploitationConstant = 1;
explorationConstant  = 2^6;

% Environment
loadComponent('ayazAirborneSynFlow');

% loadComponent('ayazAirborneFlow.mat');
% env.water.flowVec.setValue([flowSpeed;0;0],'m/s');

cIn = maneuverabilityAdvanced(vhcl);
cIn.meanElevationInRadians = initElevation;
cIn.pathWidth = w*180/pi;
cIn.pathHeight = h*180/pi;
cIn.tetherLength = thrLength;
minCur = cIn.calcMinCurvature;
pLength = cIn.pathLength;

figure(10);
pR = cIn.plotPathRadiusOfCurvature;

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
    (11/2)*norm(flowSpeed))   % Initial speed

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
    +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');

thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');

thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');

%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[flowSpeed;0;0]);

%% Run Simulation
loadComponent('ayazPathFollowingAirborne');
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);

fltCtrl.elevatorReelInDef.setValue(0,'deg');
fltCtrl.rudderGain.setValue(0,'');
fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');

keyboard
simWithMonitor('OCTModel');

tscOld = signalcontainer(logsout);
statOld = computeSimLapStats(tscOld);
trackOld = statOld{2,3}/cIn.pathLength;

%%
close all
fn = 1;
figure(fn)
pOSP = plot(tscOld.tanRollDes.Time,tscOld.tanRollDes.Data(:)*180/pi,'b-');
hold on
plot(tscOld.tanRoll.Time,tscOld.tanRoll.Data*180/pi,'b--');
ylabel('Tangent roll [deg]');
legend('Roll SP','Roll');

fn = fn+1;
figure(fn);
plot(tscOld.tanRoll.Time,squeeze(vecnorm(tscOld.velCMvec.Data)),'b-');
hold on;
ylabel('Speed [m/s]');

fn = fn+1;
figure(fn);
plot(tscOld.tanRoll.Time,tscOld.vhclVapp.Data(1,:).^3,'b-');
hold on;
ylabel('Apparent vel. in x cubed [$m^3/s^3$]');

fn = fn+1;
figure(fn);
plot(tscOld.tanRoll.Time,tscOld.turbPow.Data(:)./1e3,'b-');
hold on;
ylabel('Power [kW]');

fn = fn+1;
figure(fn);
plot(tscOld.tanRoll.Time,(squeeze(vecnorm(tscOld.velCMvec.Data))./...
    squeeze(tscOld.vWindFuseGnd.Data(1,1,:))).^3,'b-');
hold on;
ylabel('$(V_{k}/V_{w})^3$ [-]');

fn = fn+1;
figure(fn);
plot(tscOld.tanRoll.Time,squeeze(tscOld.vWindFuseGnd.Data(1,1,:)),'b-');
hold on;
ylabel('Flow speed at kite [m/s]');

fn = fn+1;
figure(fn);
plot(tscOld.tanRoll.Time,squeeze(tscOld.elevationAngle.Data(:)),'r');
hold on;
plot(tscOld.tanRoll.Time,squeeze(tscOld.basisParams.Data(:,3)*180/pi),'b-');
ylabel('Path mean elevation angle [m/s]');
legend('Actual','SP')

allAxes = findall(0,'type','axes');
allPlots = findall(0,'type','Line');
xlabel(allAxes,'Time [sec]');
grid(allAxes,'on');


set(allPlots,'linewidth',1);
set(allAxes,'FontSize',12);
xlim(allAxes,[0 tscOld.tanRoll.Time(end)]);
figNames = {'desTanRoll','speed','pSurrog','pTurb','flowAtKite'};

% for ii = 1:fn
%     figure(ii);
%     exportgraphics(gca,[figNames{ii},'.png'],'Resolution',600);
% end



%%
GG.saveGifs = true;
GG.timeStep = 1;
GG.gifTimeStep = 0.1;

vhcl.animateSim(tscOld,GG.timeStep,...
    'PathFunc',fltCtrl.fcnName.Value,'pause',false,'plotTarget',false,...
    'SaveGif',GG.saveGifs,'GifTimeStep',GG.gifTimeStep,...
    'GifFile','AirOldGif.gif','plotFlowShearProfile',false,'plotTracer',false);

filename = strcat(cd,'\',sprintf('SynFlowRes_Date-'),...
    strrep(datestr(datetime),':','-'),'.mat');
%%
% save(filename,'tscOld','vhcl','thr','fltCtrl','env','simParams','gndStn',...
%     'hiLvlCtrl');



