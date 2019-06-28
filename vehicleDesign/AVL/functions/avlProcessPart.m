function results = avlProcessPart(obj,alphas,ctrlDefls)

cd(fileparts(which('avl.exe')))

outputDirectory = fullfile(pwd,'output');

% If the output directory doesn't exist, create it
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
else
    rmdir(outputDirectory,'s');
    mkdir(outputDirectory);
end

% Calculate total number of cases
numCases = length(alphas)*length(ctrlDefls);

% Vectors of all numbers
% iterNums = 1:numCases;                  % Number to track which iteration we're on
batchNums = 1:ceil(numCases/25);        % Number to track which batch we're on
batchNums = repmat(batchNums,[25,1]);
batchNums = reshape(batchNums,[numel(batchNums),1]);
caseNums = repmat(1:25,[1 batchNums(end)]);  % Number to track which case within the batch
caseNums = caseNums(1:numCases);

% Counter to work through each vector
cnt = 0;

% Preallocate vector to hold run file names and open all those files\
runFileNames = cell([1 batchNums(end)]);
for ii = 1:length(runFileNames)
    exeFileName  = sprintf('RunFile_Batch%d.run',ii);
    exeFileName  = fullfile('.','output',exeFileName);
    runFileNames{ii} = exeFileName;
end

for ii = 1:length(alphas)
    alpha = alphas(ii);
    for pp = 1:length(ctrlDefls)
        cnt = cnt+1;
        fid = fopen(runFileNames{batchNums(cnt)},'a');
        avlAppendRunFile(fid,caseNums(cnt),...
            alpha,0,ctrlDefls(pp))
        fclose(fid);
        
    end
end


% Create exe file for each .run batch file
runFiles = dir(['output' filesep '*.run']); % Gets all files in output folder

for ii = 1:length(runFiles)
    exeFileName = runFiles(ii).name; % Get the file name
    exeFileName = strrep(exeFileName,'.run','_exe'); % Replace the file extension
    exeFileName = fullfile('.','output',exeFileName); % Concatenate relative path to exe file
    runFileName = fullfile('.','output',runFiles(ii).name); % Concatenate relative path to run file
    avlCreateExeFile(exeFileName,'input.avl',runFileName)
end

% run each _exe file on each .run file
exeFiles = dir(fullfile('output','*_exe'));
for ii = 1:length(exeFiles)
    % Form the relative path to the exe file
    exeFileName = ['.',filesep,'output',filesep,exeFiles(ii).name];
    cmd_str = strcat('avl.exe','<',exeFileName);
    
    % Run AVL
    [~,raw] = system(cmd_str);
    
    % Cleanup messy text output, put into structure
    clean = avlOutputCleanup(obj,raw);
    
    % Apply stall modelling corrections
    aero = avlStallCorrectionPart(obj,clean);
    
    % Save the results
    parsave(['.',filesep,'output',filesep, strrep(exeFiles(ii).name,'_exe','.mat')],aero)
    delete(exeFileName);
end


% Concatenate all the resulting output files
runFiles = dir([outputDirectory,filesep,'*.mat']);
for ii = 1:length(runFiles)
    load(fullfile(runFiles(ii).folder,runFiles(ii).name))
    batchNum = regexp(regexp(runFiles(ii).name,'Batch\d*.mat','match'),'\d*','match');
    batchNum = str2double(batchNum{1});
    results{batchNum} = aero;
end
% save(obj.result_file_name,'results')

rmdir(outputDirectory,'s') % Delete temporary directory
end
