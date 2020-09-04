clear
clc

cd(fileparts(mfilename('fullpath')));


%% flow speeds
flowSpeeds = 1.25;
nFlows = numel(flowSpeeds);

%% path parameters
% path mean elevation
meanElevs = 20:4:40;
% path widths
pathWidths = 8:4:40;
% path heights
pathHeights = 2:2:16;

meanElevs = 20;
% path widths
pathWidths = 8:2:10;
% path heights
pathHeights = 10;

% thr length
thrLength = 100;
% path length equation
pLequation = pathLengthEquation;


%% loops
% number of sims
numSims = numel(meanElevs)*numel(pathWidths)*numel(pathHeights)*numel(thrLength);
% make array of simulation scenarios
cc = 1;
simConditions = NaN(numSims,8);
for ii = 1:numel(meanElevs)
    for jj = 1:numel(pathWidths)
        for kk = 1:numel(pathHeights)
            for hh = 1:numel(thrLength)
                
                simConditions(cc,1) = cc;
                simConditions(cc,2:5) = [meanElevs(ii) pathWidths(jj) ...
                    pathHeights(kk) thrLength(hh)];
                [a,b] = boothParamConversion(pathWidths(jj)*pi/180,...
                    pathHeights(kk)*pi/180);
                simConditions(cc,6:7) = [a,b];
                simConditions(cc,8) = integral(@(x) ...
                    pLequation(a,b,meanElevs(ii)*pi/180,x,thrLength(hh)),0,2*pi);
                
                cc = cc + 1;
            end
        end
    end
end

% extract values to make parfor more efficient
allMeanElev  = simConditions(:,2)*pi/180;
allThrLength = simConditions(:,5);
allaBooth    = simConditions(:,6);
allbBooth    = simConditions(:,7);

%% data collection
% table headers
headers = {'Sim no','Mean elevation','Path width','Path height','Tether length',...
    'aBooth','bBooth','Path length','Laps','Lap time','Distance travelled','Avg. (V_app,x)^3',...
    'Avg. V_cm','Avg. tangent pitch','Avg. AoA','Garbage results?',...
    'Max tanRoll?','Max dv/dp','Max dtPitch/dp','Max dtRoll/dp'};
nHeaders = numel(headers);
% variable types
varTypes = cell(1,nHeaders);
varTypes(1:end) = {'double'};
varTypes(end-4) = {'logical'};

% default stats
defaultStats = cell(1,nHeaders-4);
defaultStats(1:end-5) = {0};
defaultStats(end-4:end-3) = {true};

% make the table
baseTable = table('Size',[numSims,nHeaders],'VariableTypes',varTypes);
baseTable.Properties.VariableNames = headers;
for ii = 1:size(simConditions,2)
    baseTable(:,ii).(convertCharsToStrings(headers{ii})) = simConditions(:,ii);
end

% directory to save data
folderName = [pwd,'\simSweepOutputs',strrep(datestr(datetime),':','-')];
[status, msg, msgID] = mkdir(folderName);

%% Load components
simParams = SIM.simParams;
simParams.setDuration(600,'s');
dynamicCalc = '';
% Flight Controller
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
loadComponent('ayazFullScaleOneThrWinch');
% Tether
loadComponent('ayazFullScaleOneThrTether');
% Sensors
loadComponent('idealSensors');
% Sensor processing
loadComponent('idealSensorProcessing');
% Vehicle
loadComponent('ayazFullScaleOneThrVhcl');
% Environment
loadComponent('ConstXYZT');

%% setup parfor loop
% spmd
%     currDir = pwd;
%     addpath(currDir);
%     tmpDir = tempname;
%     mkdir(tmpDir);
%     cd(tmpDir);
%     load_system('OCTModel');
% end

failedSim = 0;
for ii = 1:nFlows
    localFlowSpeed = flowSpeeds(ii);
    subfolderName = [folderName,sprintf('\\flowSpeed-%.2f',flowSpeeds(ii))];
    [status, msg, msgID] = mkdir(subfolderName);

    T = baseTable;
    
    for jj = 1: numSims
                
        % Environment IC's and dependant properties
        env.water.setflowVec([localFlowSpeed 0 0],'m/s')
        
        % Set basis parameters for high level controller
        % Lemniscate of Booth
        hiLvlCtrl.basisParams.setValue([allaBooth(jj),allbBooth(jj),...
            allMeanElev(jj),...
            0*pi/180,allThrLength(jj)],'[rad rad rad rad m]');
        
        % Ground Station IC's and dependant properties
        gndStn.setPosVec([0 0 0],'m')
        gndStn.initAngPos.setValue(0,'rad');
        gndStn.initAngVel.setValue(0,'rad/s');
        
        % Set vehicle initial conditions
        vhcl.setICsOnPath(...
            .05,... % Initial path position
            PATHGEOMETRY,... % Name of path function
            hiLvlCtrl.basisParams.Value,... % Geometry parameters
            gndStn.posVec.Value,... % Center point of path sphere
            (11/2)*norm(env.water.flowVec.Value))   % Initial speed
        
        % Tethers IC's and dependant properties
        thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
            +gndStn.posVec.Value(:),'m');
        thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
            +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
        
        thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
        thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
        
        thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');
        
        % Winches IC's and dependant properties
        wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
        
        % Controller User Def. Parameters and dependant properties
        fltCtrl.setFcnName(PATHGEOMETRY,''); % PATHGEOMETRY is defined in fig8ILC_bs.m
        fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
            hiLvlCtrl.basisParams.Value,...
            gndStn.posVec.Value);
        
        fltCtrl.elevatorReelInDef.setValue(0,'deg');
        
        % Run Simulation
        presentSimCon = num2cell(simConditions(jj,:));
        try
%             sim('OCTModel','SrcWorkspace','current');
            simWithMonitor('OCTModel');
            tsc = signalcontainer(logsout);
            compStats = computeSimLapStats(tsc);
            stats = [presentSimCon, compStats(2,:)];
            T(jj,:) = stats;
            save([subfolderName,sprintf('\\SimNo_%03d.mat',jj)],'tsc');
        catch
            failedSim = failedSim+1;
        end
        
    end
    
    filename = strcat(subfolderName,'\resExcel',...
        sprintf(' flowSpeed-%.2f',flowSpeeds(ii)),'.xlsx');
    writetable(T,filename,'Sheet',1);
    
end

% spmd
%     cd(currDir);
%     rmdir(tmpDir,'s');
%     rmpath(currDir);
%     close_system(model, 0);
% end

%% compute basis statics with logouts data
clc
fprintf('Sim complete. Number of failed sims = %d.\n',failedSim);


