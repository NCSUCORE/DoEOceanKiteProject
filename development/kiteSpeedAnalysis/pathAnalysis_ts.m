clear;clc;
% close all;
cd(fileparts(mfilename('fullpath')));

fIdx = 1;

%% initailize
% load vehicle
load('ayazFullScaleOneThrVhcl.mat');

% initialize class
cIn = maneuverabilityAdvanced(vhcl);
cIn.wingOswaldEff = 0.3;
cIn.hstabOswaldEff = 0.6;
cIn.hstabZerAoADrag = 0.1*cIn.hstabZerAoADrag;
cIn.vstabOswaldEff = 0.3;

% tether length
cIn.tetherLength = 100;

%% analysis conditions
% path shapes
meanElevations = 10:5:40;
widths = 10:5:60;
heights = 2:2:16;

% flow speed
flows = 0.25:0.25:2;

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
    'Path length','Avg. V_cm','Avg. (V_app,x)^3','Lap time','Avg. AoA',...
    'Max tangent roll','Run Completed?'};
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
[status,msg,msgID] = mkdir(pwd,'steadySweepOutputs');
folderName = [pwd,'\steadySweepOutputs\'];



%% path param
nPoints = 41;
pathParam = linspace(0,2*pi,nPoints);

% tangent pitch angle
tgtPitch = 6*pi/180;
elevatorDeflection = 0;

%% path analysis
kk = 1;
% pre-allocate important matrices
pathSpeeds     = NaN(numPathShapes,nPoints,nFlows);
pathRoll       = NaN(numPathShapes,nPoints,nFlows);
avgSpeed       = NaN(numPathShapes,nFlows);
avgV_appxCubed = NaN(numPathShapes,nFlows);
lapTime        = NaN(numPathShapes,nFlows);
avgAoA         = NaN(numPathShapes,nFlows);
maxTangentRoll = NaN(numPathShapes,nFlows);

failedSim = 0;

for ii = 1:nFlows
    % create a temporary table
    T = baseTable;
    
    for jj = 1:numPathShapes
        
        tic
        
        % Path basis parameters
        cIn.meanElevationInRadians = allPathMeanElevs(jj)*pi/180;
        cIn.pathWidth              = allPathWidths(jj);
        cIn.pathHeight             = allPathHeights(jj);
        
        try
            % run the calculation
            solVals = cIn.getAttainableVelocityOverPath(flows(ii),...
                tgtPitch,pathParam);
            
            % calc relevant results
            pathSpeeds(jj,:,ii)   = solVals.vH_path;
            pathRoll(jj,:,ii)     = solVals.roll_path;
            avgSpeed(jj,ii)       = mean(solVals.vH_path);
            avgV_appxCubed(jj,ii) = mean(max(0,-solVals.B_Vapp_path(1,:)).^3);
            lapTime(jj,ii)        = allpathLengths(jj)/avgSpeed(jj,ii);
            avgAoA(jj,ii)         = mean(cIn.calcAngleOfAttackInRadians(...
                solVals.B_Vapp_path))*180/pi;
            maxTangentRoll(jj,ii) = max(abs(pathRoll(jj,:,ii)))*180/pi;
            % store data in table
            stats = {avgSpeed(jj,ii) avgV_appxCubed(jj,ii) lapTime(jj,ii)...
                avgAoA(jj,ii) maxTangentRoll(jj,ii) true};
            T(jj,6:11) = stats;
        catch
            failedSim = failedSim+1;
        end
        toc
        
    end
    
    filename = strcat(folderName,sprintf('flowSpeed-%.2f Date-',flows(ii)),...
        strrep(datestr(datetime),':','-'),'.xlsx');
    writetable(T,filename,'Sheet',1);
end

%% acheivable velocity calcualtion
% find max of average speed
[~,maxIdx] = max(avgSpeed);


%% save res
dataFileName = strcat(folderName,'steadyPathSweepRes Date-',...
    strrep(datestr(datetime),':','-'));
save(dataFileName);


%% plotting functions
% fIdx = fIdx+1;
% figure(fIdx);
% set(gcf,'Position',[0 0 2*560 2*420]);
% cIn.plotAeroCoefficients;

%% animation functions
% fIdx = fIdx+1;
% figure(fIdx);
% set(gcf,'Position',[0 0 560*2.5 420*2]);
% F = cIn.makeFancyAnimation(pathParam,'animate',true,...
%     'addKiteTrajectory',true,...
%     'rollInRad',-pathAnalysisRes(maxIdx).rollAng,...
%     'headingVel',pathAnalysisRes(maxIdx).pathSpeed,...
%     'waitForButton',true);

%% % video settings
% video = VideoWriter(strcat(fName,'_video'),'Motion JPEG AVI');
% video.FrameRate = 1;
% set(gca,'nextplot','replacechildren');
%
% open(video)
% for ii = 1:length(F)
%     writeVideo(video, F(ii));
% end
% close(video)
