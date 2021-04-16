clear;clc;
% close all;
cd(fileparts(mfilename('fullpath')));

%% initailize
simParams = SIM.simParams;
simParams.setDuration(10*60,'s');
dynamicCalc = '';
thrLength = 1000;

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
loadComponent('constBoothLem');
% Environment
loadComponent('ayazAirborneFlow.mat');

%% Ground Station IC's and dependant properties
gndStn.setPosVec([0 0 0],'m')
gndStn.initAngPos.setValue(0,'rad');
gndStn.initAngVel.setValue(0,'rad/s');

%% Tethers IC's and dependant properties
thr.tether1.initGndNodePos.setValue(gndStn.thrAttch1.posVec.Value(:)...
    +gndStn.posVec.Value(:),'m');
thr.tether1.initGndNodeVel.setValue([0 0 0]','m/s');
thr.tether1.vehicleMass.setValue(vhcl.mass.Value,'kg');


%% load flight controller
loadComponent('ayazPathFollowingAirborne');

fltCtrl.elevatorReelInDef.setValue(0,'deg');
fltCtrl.rudderGain.setValue(0,'');
fltCtrl.yawMoment.kp.setValue(0,'(N*m)/(rad)');

%% analysis conditions
cIn = maneuverabilityAdvanced(vhcl);
% tether length
cIn.tetherLength = thrLength;
% path shapes
meanElevations = 10:5:45;
widths = 15:5:50;
heights = 6:2:16;

% flow speed
flows = 6:2:12;

% number of path shapes
numPathShapes = numel(meanElevations)*numel(widths)*numel(heights);

% number of flows
nFlows = numel(flows);

% make combination of path shapes
allPathWidths    = NaN(numPathShapes,1);
allPathMeanElevs = NaN(numPathShapes,1);
allPathHeights   = NaN(numPathShapes,1);
allpathLengths   = NaN(numPathShapes,1);
cc = 1;
for ii = 1:numel(meanElevations)
    for jj = 1:numel(widths)
        for kk = 1:numel(heights)
            
            allPathMeanElevs(cc) = meanElevations(ii);
            allPathWidths(cc) = widths(jj);
            allPathHeights(cc) = heights(kk);
            % calculate path length
            cIn.meanElevationInRadians = allPathMeanElevs(cc)*pi/180;
            cIn.pathWidth = allPathWidths(cc);
            cIn.pathHeight = allPathHeights(cc);
            allpathLengths(cc) = cIn.pathLength;
            
            cc = cc+1;
        end
    end
end

%% data collection
% table headers
headers = {'Sim no','Mean elevation','Path width','Path height',...
    'Path length',...
    'Lap no.','Lap time','Dist. traveled','Avg. P','(V_app,x)^3',...
    '(V_app,x/V_w)^3','(V_k/V_w)^3','Avg. V_cm',...
    'Avg. AoA','Max roll',...
    'Run Completed?'};
nHeaders = numel(headers);
% variable types
varTypes = cell(1,nHeaders);
varTypes(1:end-1) = {'double'};
varTypes(end) = {'logical'};

% make the table
baseTable = table('Size',[numPathShapes,nHeaders],'VariableTypes',varTypes);
baseTable.Properties.VariableNames = headers;
baseTable(:,1).("Sim no") = [1:numPathShapes]';
baseTable(:,2).("Mean elevation") = allPathMeanElevs;
baseTable(:,3).("Path width") = allPathWidths;
baseTable(:,4).("Path height") = allPathHeights;
baseTable(:,5).("Path length") = allpathLengths;

% directory to save data
[status,msg,msgID] = mkdir(pwd,'airborneSimSweep');
folderName = [pwd,'\airborneSimSweep\'];


%% path analysis
failedSim = 0;

filename = strcat(folderName,sprintf('AirborneSimSweep Date-'),...
    strrep(datestr(datetime),':','-'),'.xlsx');

for ii = 1:nFlows
    % create a temporary table
    T = baseTable;
    % set flow speed
    env.water.flowVec.setValue([flows(ii);0;0],'m/s');
    
    for jj = 1:numPathShapes
        
        tic
        
        % Path basis parameters
        cIn.meanElevationInRadians = allPathMeanElevs(jj)*pi/180;
        cIn.pathWidth              = allPathWidths(jj);
        cIn.pathHeight             = allPathHeights(jj);
        
        [a,b] = boothParamConversion(allPathWidths(jj)*pi/180,...
            allPathHeights(jj)*pi/180);
        hiLvlCtrl.basisParams.setValue([a,b,allPathMeanElevs(jj)*pi/180,...
            0*pi/180,thrLength],'[rad rad rad rad m]');
        
        
        try
            % Set vehicle initial conditions
            vhcl.setICsOnPath(...
                .05,... % Initial path position
                PATHGEOMETRY,... % Name of path function
                hiLvlCtrl.basisParams.Value,... % Geometry parameters
                gndStn.posVec.Value,... % Center point of path sphere
                (11/11)*norm(env.water.flowVec.Value))   % Initial speed
            
            % set tether initial conditions
            thr.tether1.initAirNodePos.setValue(vhcl.initPosVecGnd.Value(:)...
                +rotation_sequence(vhcl.initEulAng.Value)*vhcl.thrAttchPts_B.posVec.Value,'m');
            thr.tether1.initAirNodeVel.setValue(vhcl.initVelVecBdy.Value(:),'m/s');
            % set winch initial conditions
            wnch.setTetherInitLength(vhcl,gndStn.posVec.Value,env,thr,env.water.flowVec.Value);
            % set flight controller initial conditions
            fltCtrl.setFcnName(PATHGEOMETRY,'');
            fltCtrl.setInitPathVar(vhcl.initPosVecGnd.Value,...
                hiLvlCtrl.basisParams.Value,...
                gndStn.posVec.Value);
            % run the simulation
            simWithMonitor('OCTModel');
            % compute simulation statistics
            tscOld = signalcontainer(logsout);
            statOld = computeSimLapStats(tscOld);
            
            % store data in table
            T(jj,6:end) = {statOld{2,:}, true};
            
        catch
            failedSim = failedSim+1;
        end
        toc
        
    end
    
    writetable(T,filename,'Sheet',ii);
end


%% save res
save(filename);



