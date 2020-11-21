clear;
clc;
close all;

cd(fileparts(mfilename('fullpath')));

simParams = SIM.simParams;
simParams.setDuration(0.1*60*60,'s');
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

%% simulation scenarioes
simScenario = [2 1 1 1 false];

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

% select vehicle based on sim scenario
switch simScenario(1)
    % Vehicle
    case 1
        loadComponent('ayazAirborneVhcl');
    case 2
        loadComponent('realisticAirborneVhcl');
end

% select High level controller based on sim scenario
switch simScenario(2)
    case 1 % constant path shape
        loadComponent('constBoothLem');
        hiLvlCtrl.basisParams.setValue([a,b,initElevation,...
            0*pi/180,thrLength],'[rad rad rad rad m]');
    case 2 % only the high level control of mean elevation angle
        loadComponent('gpkfPathOptAirborne');
        % hiLvlCtrl.maxStepChange        = (800/thrLength)*180/pi;
        hiLvlCtrl.maxStepChange        = 6;
        hiLvlCtrl.minVal               = 5;
        hiLvlCtrl.maxVal               = 50;
        hiLvlCtrl.basisParams.Value = [a,b,initElevation,0*pi/180,thrLength]';
        hiLvlCtrl.initVals          = hiLvlCtrl.basisParams.Value(3)*180/pi;
        hiLvlCtrl.rateLimit         = 1*0.15;
        hiLvlCtrl.kfgpTimeStep      = 10/60;
        hiLvlCtrl.mpckfgpTimeStep   = 3;
        predictionHorz  = 6;
        exploitationConstant = 1;
        explorationConstant  = 2^6;
    case 3 % both mean elevation angle and path shape optimization
        loadComponent('gpkfPathOptWithRGPAirborne');
        % hiLvlCtrl.maxStepChange        = (800/thrLength)*180/pi;
        hiLvlCtrl.maxStepChange        = 6;
        hiLvlCtrl.minVal               = 5;
        hiLvlCtrl.maxVal               = 50;
        hiLvlCtrl.basisParams.Value = [a,b,initElevation,0*pi/180,thrLength]';
        hiLvlCtrl.initVals          = hiLvlCtrl.basisParams.Value(3)*180/pi;
        hiLvlCtrl.rateLimit         = 1*0.15;
        hiLvlCtrl.kfgpTimeStep      = 10/60;
        hiLvlCtrl.mpckfgpTimeStep   = 3;
        predictionHorz  = 6;
        exploitationConstant = 1;
        explorationConstant  = 2^6;
end

% select Environment based on sim scenario
switch simScenario(3)
    case 1
        loadComponent('ayazAirborneFlow.mat');
        env.water.flowVec.setValue([flowSpeed;0;0],'m/s');
    case 2
        loadComponent('ayazAirborneSynFlow');
end

cIn = maneuverabilityAdvanced(vhcl);
cIn.meanElevationInRadians = initElevation;
cIn.pathWidth = w*180/pi;
cIn.pathHeight = h*180/pi;
cIn.tetherLength = thrLength;
minCur = cIn.calcMinCurvature;
pLength = cIn.pathLength;

% figure(10);
% pR = cIn.plotPathRadiusOfCurvature;

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

%% path following controller
% select path following controller based on sim scenario
switch simScenario(4)
    case 1
        loadComponent('ayazPathFollowingAirborne');
end
fltCtrl.setFcnName(PATHGEOMETRY,'');
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);

fltCtrl.elevatorReelInDef.setValue(0,'deg');
fltCtrl.rudderGain.setValue(0,'');
fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');

%% Run Simulation
keyboard
simWithMonitor('OCTModel');

tscOld = signalcontainer(logsout);
statOld = computeSimLapStats(tscOld);
trackOld = statOld{2,3}/cIn.pathLength;

%% omniscient
if ismember(simScenario(2),[2,3])
    [synFlow,synAlt] = env.water.generateData();
    elevsAtAllAlts = min(max(hiLvlCtrl.minVal,...
        asin(env.water.zGridPoints.Value/thrLength)*180/pi),hiLvlCtrl.maxVal);
    omniAlts = thrLength*sind(elevsAtAllAlts);
    cosElevAtAllAlts = cosd(elevsAtAllAlts);
    
    tSamp = 0:hiLvlCtrl.mpckfgpTimeStep:simParams.duration.Value/60;
    
    for ii = 1:length(tSamp)
        % measure flow at xSamp(ii) at tSamp(ii)
        fData = resample(synFlow,tSamp(ii)*60).Data;
        hData = resample(synAlt,tSamp(ii)*60).Data;
        % calculate pseudo power
        % omniscient, uncontrained controller
        omnifData = interp1(hData,fData,omniAlts);
        [fValOmni(ii),omniIdx] = max(cosineFlowCubed(omnifData,...
            cosElevAtAllAlts));
        runAvgOmni(ii) = mean(fValOmni(1:ii));
        omniElev(ii) = elevsAtAllAlts(omniIdx);
    end
    
end

%% plot figures
switch simScenario(2)
    case 1
        plotFigs = {'Tangent roll','Speed','Apparent vel. in x cubed',...
            'Turbine power','Kite speed by flow speed cubed',...
            'Flow at kite','Lap stats'};
    case 2
        plotFigs = {'Tangent roll','Speed','Apparent vel. in x cubed',...
            'Turbine power','Kite speed by flow speed cubed',...
            'Flow at kite','Path elevation angle'};
end

for ii = 1:length(plotFigs)
    plotSomething(tscOld,plotFigs{ii},1);
end

if ismember(simScenario(2),[2,3])
    fh = findobj('Type','Figure','Name','Path elevation angle');
    figure(fh);
    plot(tSamp*60,omniElev,'r-');
    legend('Simulation','Omniscient offline');
end

allAxes = findall(0,'type','axes');
allPlots = findall(0,'type','Line');

set(allPlots,'linewidth',1);
set(allAxes,'FontSize',12);

%% save figures
if simScenario(5)
    for ii = 1:length(plotFigs)
        figure(ii);
        exportgraphics(gcf,[plotFigs{ii},'.png'],'Resolution',600);
    end
end


%% animations
GG.saveGifs = true;
GG.timeStep = 1;
GG.gifTimeStep = 0.1;

switch simScenario(2)
    case 1
        vhcl.animateSim(tscOld,GG.timeStep,...
            'PathFunc',fltCtrl.fcnName.Value,'pause',false,'plotTarget',false,...
            'SaveGif',GG.saveGifs,'GifTimeStep',GG.gifTimeStep,...
            'GifFile','AirGif.gif','plotFlowShearProfile',false,'plotTracer',false);
    case 2
        vhcl.animateSim(tscOld,GG.timeStep,...
            'PathFunc',fltCtrl.fcnName.Value,'pause',false,'plotTarget',false,...
            'SaveGif',GG.saveGifs,'GifTimeStep',GG.gifTimeStep,...
            'GifFile','AirGifGPKF.gif','plotFlowShearProfile',true,'plotTracer',false);
end

%% write data to table
headers = {'Mean elevation','Path width','Path height',...
    'Path length',...
    'Lap no.','Lap time','Dist. traveled','Avg. P','(V_app,x)^3',...
    '(V_app,x/V_w)^3','(V_k/V_w)^3','Avg. V_cm',...
    'Avg. AoA','Max roll','Tracking'};
nHeaders = numel(headers);
% variable types
varTypes = cell(1,nHeaders);
varTypes(1:end) = {'double'};

% make the table
baseTable = table('Size',[1,nHeaders],'VariableTypes',varTypes);
baseTable.Properties.VariableNames = headers;

baseTable(1,1).("Mean elevation") = cIn.meanElevationInRadians*180/pi;
baseTable(1,2).("Path width") = cIn.pathWidth;
baseTable(1,3).("Path height") = cIn.pathHeight;
baseTable(1,4).("Path length") = cIn.pathLength;
baseTable(1,5:end) = {statOld{2,:}, trackOld};

if simScenario(5)
    writetable(baseTable,'manualMode.xlsx',"WriteMode","append");
end

%% save the file
if simScenario(5)
    filename = strcat(cd,'\',sprintf('SynFlowRes_Date-'),...
        strrep(datestr(datetime),':','-'),'.mat');
    save(filename,'tscOld','vhcl','thr','fltCtrl','env','simParams','gndStn',...
        'hiLvlCtrl');
end





