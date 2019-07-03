function avlProcessPart(obj,inputFileName,type,varargin)

p = inputParser;
addRequired(p,'Type',@(x) any(validatestring(x,{'single','sweep'})));
addParameter(p,'Parallel',true,@islogical);
parse(p,type,varargin{:})

alphas      = obj.([type 'Case']).alpha;
betas       = obj.([type 'Case']).beta;
flaps       = obj.([type 'Case']).flap;
elevators   = obj.([type 'Case']).elevator;
ailerons    = obj.([type 'Case']).aileron;
rudders     = obj.([type 'Case']).rudder;

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
numCases = length(alphas)*length(betas)*length(flaps)*...
    length(ailerons)*length(elevators)*length(rudders);

% Vectors of all numbers
% iterNums = 1:numCases;                  % Number to track which iteration we're on
batchNums = 1:ceil(numCases/25);        % Number to track which batch we're on
batchNums = repmat(batchNums,[25,1]);
batchNums = reshape(batchNums,[numel(batchNums),1]);
caseNums = repmat(1:25,[1 batchNums(end)]);  % Number to track which case within the batch
caseNums = caseNums(1:numCases);

% Counter to work through each vector
cnt = 0;

% Preallocate vector to hold run file IDs
% runFileID = zeros([1 max(batchNums)]);

% Preallocate vector to hold run file names and open all those files\
runFileNames = cell([1 batchNums(end)]);
for ii = 1:length(runFileNames)
    exeFileName  = strrep(obj.run_file_name,'.run','');
    exeFileName  = strcat(exeFileName,sprintf('_Batch%d.run',ii));
    exeFileName  = fullfile('.','output',exeFileName);
    runFileNames{ii} = exeFileName;
end

for ii = 1:length(runFileNames)
    fid = fopen(runFileNames{ii},'w');
    fclose(fid);
end

fprintf('Running AVL...\n')
for ii = 1:length(alphas)
    alpha = alphas(ii);
    for jj = 1:length(betas)
        beta = betas(jj);
        for kk = 1:length(flaps)
            flap = flaps(kk);
            for mm = 1:length(ailerons)
                aileron = ailerons(mm);
                for nn = 1:length(elevators)
                    elevator = elevators(nn);
                    for pp = 1:length(rudders)
                        rudder = rudders(pp);
                        cnt = cnt+1;
                        
                        
                        fid = fopen(runFileNames{batchNums(cnt)},'a');
                        avlAppendRunFile(fid,caseNums(cnt),...
                            alpha,beta,flap,aileron,elevator,rudder)
                        fclose(fid);
                        
                    end
                end
            end
        end
    end
end
% fclose('all');
% Create exe file for each .run batch file
runFiles = dir('output'); % Gets all files in output folder
runFiles = runFiles(~[runFiles.isdir]); % Removes . and .. from list
for ii = 1:length(runFiles)
    exeFileName = runFiles(ii).name; % Get the file name
    exeFileName = strrep(exeFileName,'.run','_exe'); % Replace the file extension
    exeFileName = fullfile('.','output',exeFileName); % Concatenate relative path to exe file
    runFileName = fullfile('.','output',runFiles(ii).name); % Concatenate relative path to run file
    avlCreateExeFile(exeFileName,inputFileName,runFileName)
end

% run each _exe file on each .run file
exeFiles = dir(fullfile('output','*_exe'));
if p.Results.Parallel % Then run in parallel
    parfor ii = 1:length(exeFiles)
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
else % Else run in series
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
end


% Concatenate all the resulting output files
runFiles = dir([outputDirectory,filesep,'*.mat']);
for ii = 1:length(runFiles)
    load(fullfile(runFiles(ii).folder,runFiles(ii).name))
    batchNum = regexp(regexp(runFiles(ii).name,'Batch\d*.mat','match'),'\d*','match');
    batchNum = str2double(batchNum{1});
    results{batchNum} = aero;
end
save(obj.result_file_name,'results')

rmdir(outputDirectory,'s') % Delete temporary directory
end
