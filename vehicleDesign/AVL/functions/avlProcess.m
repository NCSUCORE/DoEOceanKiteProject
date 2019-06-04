function avlProcess(obj,type,varargin)

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
    fprintf('Creating output directory\n')
    mkdir(outputDirectory);
else
    fprintf('Deleting and recreating output directory\n')
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
fprintf('Creating .run files\n')
runFileNames = cell([1 batchNums(end)]);
for ii = 1:length(runFileNames)
    runFileName  = strrep(obj.run_file_name,'.run','');
    runFileName  = strcat(runFileName,sprintf('_Batch%d.run',ii));
    runFileName  = fullfile('.','output',runFileName);
    runFileNames{ii} = runFileName;
end

for ii = 1:length(runFileNames)
    fid = fopen(runFileNames{ii},'w');
    fclose(fid);
end

fprintf('Filling in .run files\n')
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
fclose('all');

% Create exe file for each .run batch file
rsltFiles = dir('output');
rsltFiles = rsltFiles(~[rsltFiles.isdir]);
for ii = 1:length(rsltFiles)
    runFileName = rsltFiles(ii).name;
    runFileName = strrep(runFileName,'.run','_exe');
    runFileName = fullfile('.','output',runFileName);
    inputFileName = obj.input_file_name;
    runFileName = fullfile('.','output',rsltFiles(ii).name);
    avlCreateExeFile(runFileName,inputFileName,runFileName)
end

% run each _exe file on each .run file
exeFiles = dir(fullfile('output','*_exe'));
if p.Results.Parallel % Then run in parallel
    parfor ii = 1:length(exeFiles)
        % Form the relative path to the exe file
        runFileName = ['.',filesep,'output',filesep,exeFiles(ii).name];
        cmd_str = strcat('avl.exe','<',runFileName);
        
        % Run AVL
        [~,raw] = system(cmd_str);
        
        % Cleanup messy text output, put into structure
        clean = avlOutputCleanup(obj,raw);
        
        % Apply stall modelling corrections
        aero = avlStallCorrection(obj,clean);
        
        % Save the results
        parsave(['.',filesep,'output',filesep, strrep(exeFiles(ii).name,'_exe','.mat')],aero)
        delete(runFileName);
    end
else % Else run in series
    for ii = 1:length(exeFiles)
        % Form the relative path to the exe file
        runFileName = ['.',filesep,'output',filesep,exeFiles(ii).name];
        cmd_str = strcat('avl.exe','<',runFileName);
        
        % Run AVL
        [~,raw] = system(cmd_str);
        
        % Cleanup messy text output, put into structure
        clean = avlOutputCleanup(obj,raw);
        
        % Apply stall modelling corrections
        aero = avlStallCorrection(obj,clean);
        
        % Save the results
        parsave(['.',filesep,'output',filesep, strrep(exeFiles(ii).name,'_exe','.mat')],aero)
        delete(runFileName);
    end
end


% Concatenate all the resulting output files
rsltFiles = dir([outputDirectory,filesep,'*.mat']);
for ii = 1:length(rsltFiles)
    load(fullfile(rsltFiles(ii).folder,rsltFiles(ii).name))
    batchNum = regexp(regexp(rsltFiles(ii).name,'Batch\d*.mat','match'),'\d*','match');
    batchNum = str2double(batchNum{1});
    results{batchNum} = aero;
end
save(obj.result_file_name,'results')

rmdir(outputDirectory,'s') % Delete temporary directory
end
