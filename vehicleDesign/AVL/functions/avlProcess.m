function avlProcess(obj,type)

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
end

% If the run file does exist, close and delete
if isfile(obj.run_file_name)
    fclose('all');
    delete(obj.run_file_name)
end

% If the results file does exist, close and delete
if isfile(obj.result_file_name)
    fclose('all');
    delete(obj.result_file_name)
end

% Open files
runFileID    = fopen(obj.run_file_name,'a');

% Run nested loops for every combination of angles
caseNumber = 1;
numCases = length(alphas)*length(betas)*length(flaps)*...
    length(ailerons)*length(elevators)*length(rudders);
count = 0;
total = 0;
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
                        total = total+1;
                        % Append case number to run file
                        avlAppendRunFile(runFileID,caseNumber,...
                            alpha,beta,flap,aileron,elevator,rudder)
                        
                        if caseNumber == 25 ||...
                                strcmpi(type,'single') ||...
                                total == numCases
                            
                            % Print status update for user
                            fprintf('\nRunning %d - %d',...
                                25*count+1, 25*count+caseNumber)
                            
                            % Run AVL
                            raw = avlRunFile(obj);
                            
                            % Post-process text output into structure
                            clean = avlOutputCleanup(obj,raw);
                            
                            % Apply stall modelling corrections
                            corrected = avlStallCorrection(clean);
                            
                            % Save struct into file
                            fileName = obj.result_file_name;
                            if strcmpi(type,'sweep')
                                fileName = [obj.result_file_name sprintf('_%dTo%d',...
                                25*count+1, 25*count+caseNumber)];
                            end
                            save(fullfile(outputDirectory,fileName),'corrected');
                            % Reset the output file
                            fclose(runFileID);
                            delete(obj.run_file_name)
                            runFileID = fopen(obj.run_file_name,'a');
                            count = count+1;
                        end
                        % Increment case number
                        caseNumber = caseNumber + 1;
                        
                        if caseNumber == 26
                            caseNumber = 1;
                        end
                        
                    end
                end
            end
        end
    end
end
% Concatenate all the output files
files = dir(fullfile(outputDirectory,'*.mat'));
for ii = 1:length(files)
    load(fullfile(files(ii).folder,files(ii).name))
    indices = regexp(files(ii).name,'_\d*To\d*','match');
    indices = strrep(indices,'_','');
    indices = str2double(strsplit(indices{1},'To'));
    results(indices(1):indices(2)) = corrected;
end
save(obj.result_file_name,'results')
rmdir(outputDirectory,'s') % Delete temporary directory
end