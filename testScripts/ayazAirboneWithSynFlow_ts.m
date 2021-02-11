clear;
clc;

cd(fileparts(mfilename('fullpath')));

simParams = SIM.simParams;
simParams.setDuration(1*60*60,'s');
dynamicCalc = '';
flowSpeed = 6.2;
thrLength = 1000;
% rad - Mean elevation angle
initElev = 30*pi/180;
% rad - Path width/height
w = 28*pi/180;
h = w/5;
% h = 8*pi/180;
% Path basis parameters
[a,b] = boothParamConversion(w,h);

%% simulation scenarioes
% column description
% 1 - choose vehicle design. 1 for unrealistic, 2 for realistic
% 2 - choose high level controller.
%       1 for constantLem,
%       2 for elevation angle optimization,
%       3 for for GPKF altitude optimization controller
% 3 - choose environment. 1 for constant flow, 2 for varying flow.
% 4 - choose path following controller. 1 for usual, 2 for guidance law one
% 5 - save simulation results. Figures and such.

simScenario = [2 3 2 1 false];
thrDrag = false;

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
    case 1 % unrealistically light weight
        loadComponent('ayazAirborneVhcl');
    case 2 % realistic
        loadComponent('realisticAirborneVhcl');
end

% select High level controller based on sim scenario
switch simScenario(2)
    case 1 % constant path shape
        loadComponent('constBoothLem');
        hiLvlCtrl.basisParams.setValue([a,b,initElev,...
            0*pi/180,thrLength],'[rad rad rad rad m]');
        hiLvlCtrl.maxNumberOfSimulatedLaps.setValue(5,'');
    case 2 % only the high level control of mean elevation angle
        loadComponent('gpkfPathOptAirborne');
        % hiLvlCtrl.maxStepChange        = (800/thrLength)*180/pi;
        hiLvlCtrl.maxStepChange         = 6;
        hiLvlCtrl.minVal                = 5;
        hiLvlCtrl.maxVal                = 50;
        hiLvlCtrl.basisParams.Value     = [a,b,initElev,0*pi/180,thrLength]';
        hiLvlCtrl.initVals              = hiLvlCtrl.basisParams.Value(3)*180/pi;
        hiLvlCtrl.rateLimit             = 1*0.15;
        hiLvlCtrl.kfgpTimeStep          = 10/60;
        hiLvlCtrl.mpckfgpTimeStep       = 3;
        hiLvlCtrl.predictionHorz        = 6;
        hiLvlCtrl.exploitationConstant  = 1;
        hiLvlCtrl.explorationConstant   = 2^6;
    case 3 % altitude optimization
        loadComponent('gpkfAltitudeOptimization');
        hiLvlCtrl.basisParams.Value     = [a,b,initElev,0*pi/180,thrLength]';
        hiLvlCtrl.initVals              = thrLength*sin(initElev);

end

% select Environment based on sim scenario
switch simScenario(3)
    case 1 % constant flow field
        loadComponent('ayazAirborneFlow.mat');
        env.water.flowVec.setValue([flowSpeed;0;0],'m/s');
    case 2 % synthetically generated flow field
        loadComponent('ayazAirborneSynFlow');
end

% plot radius of curvature
cIn = maneuverabilityAdvanced(vhcl);
cIn.meanElevationInRadians = initElev;
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

thr.tether1.dragEnable.setValue(thrDrag,'');
%% Winches IC's and dependant properties
wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,[flowSpeed;0;0]);

%% path following controller
% select path following controller based on sim scenario
switch simScenario(4)
    case 1 % usual path following controller
        loadComponent('ayazPathFollowingAirborne');
    case 2 % guidance law based path following controller
        loadComponent('guidanceLawPathFollowingAir');
end
fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
    hiLvlCtrl.basisParams.Value,...
    gndStn.posVec.Value);

fltCtrl.elevatorReelInDef.setValue(0,'deg');

%% Run Simulation
keyboard
simWithMonitor('OCTModel','minRate',0);

tscKFGP = signalcontainer(logsout);
statKFGP = computeSimLapStats(tscKFGP);
trackKFGP = statKFGP{2,3}/cIn.pathLength;

% run omniscient simulation
[synFlow,synAlt] = env.water.generateData();
keyboard
altSPTraj = calculateOmniAltitudeSPTraj(synAlt,synFlow,hiLvlCtrl,...
    hiLvlCtrl.initVals,simParams.duration.Value);

hiLvlCtrl.altSPTraj = altSPTraj;
HILVLCONTROLLER = 'omniscientAltitudeOpt';

simWithMonitor('OCTModel','minRate',0);

tscOmni = signalcontainer(logsout);
statOmni = computeSimLapStats(tscOmni);
trackOmni = statOmni{2,3}/cIn.pathLength;

%% omniscient
switch simScenario(2)
    
    case 2
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
        
    case 3
        
        omniFunc = @(z,hl,zD,fD) hl.powerGrid(interp1(zD,fD,z),z);
        options = optimoptions('fmincon','algorithm','sqp');

        
        [synFlow,synAlt] = env.water.generateData();
        omniAlts = unique(hiLvlCtrl.altVals);
        
        tSamp = 0:hiLvlCtrl.mpckfgpTimeStep:simParams.duration.Value/60;
        altSimSP = resample(tscKFGP.altitudeSP,tSamp*60);
        omniSP   = resample(tscOmni.altitudeSP,tSamp*60);

        fValOmni = nan(1,length(tSamp));
        omniAlt = nan(1,length(tSamp));
        runAvgOmni = nan(1,length(tSamp));
        for ii = 1:length(tSamp)
            % measure flow at xSamp(ii) at tSamp(ii)
            fData = resample(synFlow,tSamp(ii)*60).Data;
            hData = resample(synAlt,tSamp(ii)*60).Data;
            
            % simulation           
            simPower(ii) = omniFunc(altSimSP.Data(ii),hiLvlCtrl,hData,fData);
            simPower(ii) = max(simPower(ii),0);
            simMean(ii)  = mean(simPower(1:ii));
            
            omniPower(ii) = omniFunc(omniSP.Data(ii),hiLvlCtrl,hData,fData);
            omniPower(ii) = max(omniPower(ii),0);
            omniMean(ii)  = mean(omniPower(1:ii));
            
        end
        
    otherwise
        
end

%% plot figures
switch simScenario(2)
    case 1
        plotFigs = {'Tangent roll','Speed','Apparent vel. in x cubed',...
            'Turbine power','Kite speed by flow speed cubed'};
    case 2
        plotFigs = {'Tangent roll','Speed','Apparent vel. in x cubed',...
            'Turbine power','Kite speed by flow speed cubed',...
            'Flow at kite','Path elevation angle'};
    case 3
        plotFigs = {'Tangent roll','Speed','Apparent vel. in x cubed',...
            'Turbine power','Kite speed by flow speed cubed','Altitude SP',...
            'Turbine energy'};
end

for ii = 1:length(plotFigs)
    plotSomethingAyaz(tscKFGP,plotFigs{ii},'s');
end

for ii = 1:length(plotFigs)
    plotSomethingAyaz(tscOmni,plotFigs{ii},'s');
end

switch simScenario(2)
    case 2
        fh = findobj('Type','Figure','Name','Path elevation angle');
        figure(fh);
        plot(tSamp*60,omniElev,'r-');
        legend('Simulation','Omniscient offline');
    case 3
        figure;
        stairs(tSamp*60,altSimSP.Data(:),'b-');        
        hold on;
        stairs(tSamp*60,omniSP.Data(:),'r-');
        legend('Simulation','Omniscient offline','location','best');
        xlabel('Time [s]');
        ylabel('Altitude [m]');
        grid on;
        
        
        figure;
        plot(tSamp*60,simMean,'b-');        
        hold on;
        plot(tSamp*60,omniMean,'r-');
        legend('Simulation','Omniscient offline','location','best');
        xlabel('Time [s]');
        ylabel('Power [kW]');
        grid on;
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

%% write data to table
headers = {'Mean elevation','Path width','Path height',...
    'Path length',...
    'Lap no.','Lap time','Dist. traveled','Avg. P','(V_app,x)^3',...
    '(V_app,x/V_w)^3','(V_k/V_w)^3','Avg. V_cm',...
    'Avg. AoA','Max roll','Tracking','Mass'};
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
baseTable(1,5:end) = {statKFGP{2,:}, trackKFGP, vhcl.mass.Value};

if simScenario(5)
    writetable(baseTable,'manualMode.xlsx',"WriteMode","append");
end

writetable(baseTable,'simDat.txt',"WriteMode","append");

%% animations
GG.saveGifs = true;
GG.timeStep = 1;
GG.gifTimeStep = 0.1;
switch simScenario(4)
    case 1
        GG.plotTarget = false;
    case 2
        GG.plotTarget = true;
end
if GG.timeStep < 5
    GG.plotTracer = true;
else
    GG.plotTracer = false;
end

switch simScenario(2)
    case 1
        vhcl.animateSim(tscKFGP,GG.timeStep,...
            'PathFunc',fltCtrl.fcnName.Value,'pause',false,'plotTarget',GG.plotTarget,...
            'SaveGif',GG.saveGifs,'GifTimeStep',GG.gifTimeStep,...
            'GifFile','AirGif.gif','plotFlowShearProfile',false,...
            'plotTracer',GG.plotTracer);
    case 2
        vhcl.animateSim(tscKFGP,GG.timeStep,...
            'PathFunc',fltCtrl.fcnName.Value,'pause',false,'plotTarget',GG.plotTarget,...
            'SaveGif',GG.saveGifs,'GifTimeStep',GG.gifTimeStep,...
            'GifFile','AirGifGPKF.gif','plotFlowShearProfile',true,...
            'plotTracer',GG.plotTracer);
    case 3
        vhcl.animateSim(tscKFGP,GG.timeStep,...
            'PathFunc',fltCtrl.fcnName.Value,'pause',false,'plotTarget',GG.plotTarget,...
            'SaveGif',GG.saveGifs,'GifTimeStep',GG.gifTimeStep,...
            'GifFile','AirGifGPKF.gif','plotFlowShearProfile',true,...
            'plotTracer',GG.plotTracer);
end

%% save the file
if simScenario(5)
    filename = strcat(cd,'\',sprintf('SynFlowRes_Date-'),...
        strrep(datestr(datetime),':','-'),'.mat');
    save(filename,'tscOld','vhcl','thr','fltCtrl','env','simParams','gndStn',...
        'hiLvlCtrl');
end





